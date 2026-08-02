import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/storage/secure_storage_provider.dart';
import '../../../../core/packages/theme/app_themes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/app_theme_mode.dart';

part 'theme_controller.g.dart';

/// Legacy device-wide storage key (pre per-user theme).
const _legacyThemePreferenceKey = 'THEME_PREFERENCE';

/// Storage key prefix for per-user theme preference.
const _themePreferenceKeyPrefix = 'THEME_PREFERENCE_';

/// Builds the secure-storage key for a user's theme preference.
String themePreferenceKeyForUser(String userId) =>
    '$_themePreferenceKeyPrefix$userId';

/// Controller for managing app theme mode.
///
/// Handles light/dark/system theme switching with per-user persistence.
@Riverpod(keepAlive: true)
class ThemeController extends _$ThemeController {
  @override
  Future<AppThemeMode> build() async {
    final auth = ref.watch(currentAuthProvider);
    final userId = auth?.user.id;
    if (userId == null || userId.isEmpty) {
      return AppThemeMode.system;
    }
    return await _loadPersistedTheme(userId) ?? AppThemeMode.system;
  }

  /// Gets the current effective theme ID based on mode and system brightness.
  String getEffectiveThemeId(Brightness systemBrightness) {
    final mode = state.value ?? AppThemeMode.system;

    switch (mode) {
      case AppThemeMode.light:
        return AppThemes.lightId;
      case AppThemeMode.dark:
        return AppThemes.darkId;
      case AppThemeMode.system:
        return systemBrightness == Brightness.dark
            ? AppThemes.darkId
            : AppThemes.lightId;
    }
  }

  /// Sets the theme mode and persists the preference for the signed-in user.
  Future<void> setThemeMode(AppThemeMode mode) async {
    final userId = ref.read(currentAuthProvider)?.user.id;
    if (userId == null || userId.isEmpty) return;

    state = const AsyncLoading();
    await _persistTheme(userId, mode);
    state = AsyncData(mode);
  }

  Future<AppThemeMode?> _loadPersistedTheme(String userId) async {
    final storage = ref.read(secureStorageProvider);
    final userKey = themePreferenceKeyForUser(userId);
    final value = await storage.read(key: userKey);

    if (value != null) {
      return _parseThemeMode(value);
    }

    // One-time migrate from legacy device-wide key.
    final legacyValue = await storage.read(key: _legacyThemePreferenceKey);
    if (legacyValue == null) return null;

    final mode = _parseThemeMode(legacyValue);
    if (mode != null) {
      await storage.write(key: userKey, value: mode.name);
    }
    return mode;
  }

  Future<void> _persistTheme(String userId, AppThemeMode mode) async {
    final storage = ref.read(secureStorageProvider);
    await storage.write(
      key: themePreferenceKeyForUser(userId),
      value: mode.name,
    );
  }

  AppThemeMode? _parseThemeMode(String value) {
    return AppThemeMode.values.cast<AppThemeMode?>().firstWhere(
          (m) => m?.name == value,
          orElse: () => null,
        );
  }
}

/// Convenience provider for current theme mode.
@Riverpod(keepAlive: true)
AppThemeMode currentThemeMode(Ref ref) {
  return ref.watch(themeControllerProvider).value ?? AppThemeMode.system;
}
