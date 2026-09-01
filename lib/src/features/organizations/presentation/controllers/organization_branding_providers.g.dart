// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_branding_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The seed color driving the app's [ColorScheme] — the current
/// organization's `seedColor` when set, else [AppThemes.defaultSeedColor].

@ProviderFor(effectiveSeedColor)
final effectiveSeedColorProvider = EffectiveSeedColorProvider._();

/// The seed color driving the app's [ColorScheme] — the current
/// organization's `seedColor` when set, else [AppThemes.defaultSeedColor].

final class EffectiveSeedColorProvider
    extends $FunctionalProvider<Color, Color, Color>
    with $Provider<Color> {
  /// The seed color driving the app's [ColorScheme] — the current
  /// organization's `seedColor` when set, else [AppThemes.defaultSeedColor].
  EffectiveSeedColorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'effectiveSeedColorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$effectiveSeedColorHash();

  @$internal
  @override
  $ProviderElement<Color> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Color create(Ref ref) {
    return effectiveSeedColor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Color value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Color>(value),
    );
  }
}

String _$effectiveSeedColorHash() =>
    r'c202d4b4372a00f44d61116cb40972361047fe14';

/// The app title shown in the app bar/browser tab — the current
/// organization's display name when resolved, else the env-aware fallback
/// from [appTitle].

@ProviderFor(effectiveAppTitle)
final effectiveAppTitleProvider = EffectiveAppTitleProvider._();

/// The app title shown in the app bar/browser tab — the current
/// organization's display name when resolved, else the env-aware fallback
/// from [appTitle].

final class EffectiveAppTitleProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// The app title shown in the app bar/browser tab — the current
  /// organization's display name when resolved, else the env-aware fallback
  /// from [appTitle].
  EffectiveAppTitleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'effectiveAppTitleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$effectiveAppTitleHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return effectiveAppTitle(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$effectiveAppTitleHash() => r'cc08c24892cb19e61ef4b18c730b3367f716efae';

/// The transparent-background logo URL for the current organization, or
/// null when unresolved/unset — callers should fall back to the bundled
/// default asset (e.g. via `CachedImage`'s built-in placeholder).

@ProviderFor(effectiveLogoUrl)
final effectiveLogoUrlProvider = EffectiveLogoUrlProvider._();

/// The transparent-background logo URL for the current organization, or
/// null when unresolved/unset — callers should fall back to the bundled
/// default asset (e.g. via `CachedImage`'s built-in placeholder).

final class EffectiveLogoUrlProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// The transparent-background logo URL for the current organization, or
  /// null when unresolved/unset — callers should fall back to the bundled
  /// default asset (e.g. via `CachedImage`'s built-in placeholder).
  EffectiveLogoUrlProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'effectiveLogoUrlProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$effectiveLogoUrlHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return effectiveLogoUrl(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$effectiveLogoUrlHash() => r'b186b0a2795f36aabd2b6ec3c198ecc3049f446c';

/// Background color for the in-app/web post-boot loading screen.
///
/// Native OS splash (`flutter_native_splash.yaml`) is baked at build time
/// and cannot reflect this — see `OrgLoadingSplash`.

@ProviderFor(effectiveSplashBackgroundColor)
final effectiveSplashBackgroundColorProvider =
    EffectiveSplashBackgroundColorProvider._();

/// Background color for the in-app/web post-boot loading screen.
///
/// Native OS splash (`flutter_native_splash.yaml`) is baked at build time
/// and cannot reflect this — see `OrgLoadingSplash`.

final class EffectiveSplashBackgroundColorProvider
    extends $FunctionalProvider<Color, Color, Color>
    with $Provider<Color> {
  /// Background color for the in-app/web post-boot loading screen.
  ///
  /// Native OS splash (`flutter_native_splash.yaml`) is baked at build time
  /// and cannot reflect this — see `OrgLoadingSplash`.
  EffectiveSplashBackgroundColorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'effectiveSplashBackgroundColorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$effectiveSplashBackgroundColorHash();

  @$internal
  @override
  $ProviderElement<Color> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Color create(Ref ref) {
    return effectiveSplashBackgroundColor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Color value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Color>(value),
    );
  }
}

String _$effectiveSplashBackgroundColorHash() =>
    r'67edf247d3f48b710e728941718c7d73fb77c8e6';
