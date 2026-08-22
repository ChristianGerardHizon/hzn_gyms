import 'package:kylie_gym/src/core/packages/storage/secure_storage_provider.dart';
import 'package:kylie_gym/src/core/packages/theme/app_themes.dart';
import 'package:kylie_gym/src/features/auth/domain/auth_state.dart';
import 'package:kylie_gym/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:kylie_gym/src/features/settings/domain/app_theme_mode.dart';
import 'package:kylie_gym/src/features/settings/presentation/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage storage;
  final Map<String, String> store = {};

  setUp(() {
    storage = MockFlutterSecureStorage();
    store.clear();
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((invocation) async {
      final key = invocation.namedArguments[#key] as String;
      return store[key];
    });
    when(
      () => storage.write(key: any(named: 'key'), value: any(named: 'value')),
    ).thenAnswer((invocation) async {
      final key = invocation.namedArguments[#key] as String;
      final value = invocation.namedArguments[#value] as String;
      store[key] = value;
    });
  });

  ProviderContainer createContainer({String? userId}) {
    return ProviderContainer(
      overrides: [
        secureStorageProvider.overrideWithValue(storage),
        currentAuthProvider.overrideWithValue(
          userId == null ? null : buildAuthState(userId: userId),
        ),
      ],
    );
  }

  test('no auth yields system theme', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    final mode = await container.read(themeControllerProvider.future);
    expect(mode, AppThemeMode.system);
  });

  test('loads user-scoped preference', () async {
    store[themePreferenceKeyForUser('user-a')] = AppThemeMode.dark.name;

    final container = createContainer(userId: 'user-a');
    addTearDown(container.dispose);

    final mode = await container.read(themeControllerProvider.future);
    expect(mode, AppThemeMode.dark);
  });

  test('stores preferences separately per user', () async {
    store[themePreferenceKeyForUser('user-a')] = AppThemeMode.dark.name;
    store[themePreferenceKeyForUser('user-b')] = AppThemeMode.light.name;

    final containerA = createContainer(userId: 'user-a');
    addTearDown(containerA.dispose);
    expect(
      await containerA.read(themeControllerProvider.future),
      AppThemeMode.dark,
    );

    final containerB = createContainer(userId: 'user-b');
    addTearDown(containerB.dispose);
    expect(
      await containerB.read(themeControllerProvider.future),
      AppThemeMode.light,
    );
  });

  test('setThemeMode writes the user-scoped key', () async {
    final container = createContainer(userId: 'user-1');
    addTearDown(container.dispose);

    await container.read(themeControllerProvider.future);
    await container
        .read(themeControllerProvider.notifier)
        .setThemeMode(AppThemeMode.dark);

    expect(store[themePreferenceKeyForUser('user-1')], AppThemeMode.dark.name);
    expect(
      container.read(themeControllerProvider).value,
      AppThemeMode.dark,
    );
  });

  test('setThemeMode is a no-op when unauthenticated', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    await container.read(themeControllerProvider.future);
    await container
        .read(themeControllerProvider.notifier)
        .setThemeMode(AppThemeMode.dark);

    expect(store, isEmpty);
    expect(
      container.read(themeControllerProvider).value,
      AppThemeMode.system,
    );
  });

  test('migrates legacy global key into user-scoped key', () async {
    store['THEME_PREFERENCE'] = AppThemeMode.dark.name;

    final container = createContainer(userId: 'user-1');
    addTearDown(container.dispose);

    final mode = await container.read(themeControllerProvider.future);
    expect(mode, AppThemeMode.dark);
    expect(store[themePreferenceKeyForUser('user-1')], AppThemeMode.dark.name);
    // Legacy key left in place.
    expect(store['THEME_PREFERENCE'], AppThemeMode.dark.name);
  });

  test('user-scoped key takes precedence over legacy key', () async {
    store['THEME_PREFERENCE'] = AppThemeMode.dark.name;
    store[themePreferenceKeyForUser('user-1')] = AppThemeMode.light.name;

    final container = createContainer(userId: 'user-1');
    addTearDown(container.dispose);

    final mode = await container.read(themeControllerProvider.future);
    expect(mode, AppThemeMode.light);
  });

  test('defaults to system when no preference is stored', () async {
    final container = createContainer(userId: 'user-1');
    addTearDown(container.dispose);

    final mode = await container.read(themeControllerProvider.future);
    expect(mode, AppThemeMode.system);
  });

  test('reloads preference when auth user switches', () async {
    store[themePreferenceKeyForUser('user-a')] = AppThemeMode.dark.name;
    store[themePreferenceKeyForUser('user-b')] = AppThemeMode.light.name;

    var auth = buildAuthState(userId: 'user-a');
    final container = ProviderContainer(
      overrides: [
        secureStorageProvider.overrideWithValue(storage),
        currentAuthProvider.overrideWith((ref) => auth),
      ],
    );
    addTearDown(container.dispose);

    expect(
      await container.read(themeControllerProvider.future),
      AppThemeMode.dark,
    );

    auth = buildAuthState(userId: 'user-b');
    container.invalidate(currentAuthProvider);

    // Previous user's mode must not drive effective theme during reload.
    expect(
      container
          .read(themeControllerProvider.notifier)
          .getEffectiveThemeId(Brightness.light),
      AppThemes.lightId,
    );

    expect(
      await container.read(themeControllerProvider.future),
      AppThemeMode.light,
    );
  });

  test('sign-out does not keep prior user theme as effective id', () async {
    store[themePreferenceKeyForUser('user-a')] = AppThemeMode.dark.name;

    AuthState? auth = buildAuthState(userId: 'user-a');
    final container = ProviderContainer(
      overrides: [
        secureStorageProvider.overrideWithValue(storage),
        currentAuthProvider.overrideWith((ref) => auth),
      ],
    );
    addTearDown(container.dispose);

    expect(
      await container.read(themeControllerProvider.future),
      AppThemeMode.dark,
    );

    auth = null;
    container.invalidate(currentAuthProvider);

    expect(
      container
          .read(themeControllerProvider.notifier)
          .getEffectiveThemeId(Brightness.light),
      AppThemes.lightId,
    );
    expect(
      await container.read(themeControllerProvider.future),
      AppThemeMode.system,
    );
  });
}
