// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing app theme mode.
///
/// Handles light/dark/system theme switching with per-user persistence.

@ProviderFor(ThemeController)
final themeControllerProvider = ThemeControllerProvider._();

/// Controller for managing app theme mode.
///
/// Handles light/dark/system theme switching with per-user persistence.
final class ThemeControllerProvider
    extends $AsyncNotifierProvider<ThemeController, AppThemeMode> {
  /// Controller for managing app theme mode.
  ///
  /// Handles light/dark/system theme switching with per-user persistence.
  ThemeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeControllerHash();

  @$internal
  @override
  ThemeController create() => ThemeController();
}

String _$themeControllerHash() => r'726bae944ba1c1ce98535550d3b0b1fb2f339d57';

/// Controller for managing app theme mode.
///
/// Handles light/dark/system theme switching with per-user persistence.

abstract class _$ThemeController extends $AsyncNotifier<AppThemeMode> {
  FutureOr<AppThemeMode> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AppThemeMode>, AppThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppThemeMode>, AppThemeMode>,
              AsyncValue<AppThemeMode>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Convenience provider for current theme mode.

@ProviderFor(currentThemeMode)
final currentThemeModeProvider = CurrentThemeModeProvider._();

/// Convenience provider for current theme mode.

final class CurrentThemeModeProvider
    extends $FunctionalProvider<AppThemeMode, AppThemeMode, AppThemeMode>
    with $Provider<AppThemeMode> {
  /// Convenience provider for current theme mode.
  CurrentThemeModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentThemeModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentThemeModeHash();

  @$internal
  @override
  $ProviderElement<AppThemeMode> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppThemeMode create(Ref ref) {
    return currentThemeMode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppThemeMode>(value),
    );
  }
}

String _$currentThemeModeHash() => r'a08a64b83db39e01edcaf0b73018f110618f7fde';
