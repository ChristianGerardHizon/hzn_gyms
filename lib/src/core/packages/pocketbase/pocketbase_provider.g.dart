// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pocketbase_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for toggling between dev and production PocketBase instances.
///
/// Stores the preference in secure storage and provides methods to toggle.

@ProviderFor(PbDebugController)
final pbDebugControllerProvider = PbDebugControllerProvider._();

/// Controller for toggling between dev and production PocketBase instances.
///
/// Stores the preference in secure storage and provides methods to toggle.
final class PbDebugControllerProvider
    extends $AsyncNotifierProvider<PbDebugController, bool> {
  /// Controller for toggling between dev and production PocketBase instances.
  ///
  /// Stores the preference in secure storage and provides methods to toggle.
  PbDebugControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pbDebugControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pbDebugControllerHash();

  @$internal
  @override
  PbDebugController create() => PbDebugController();
}

String _$pbDebugControllerHash() => r'5a7431672b4eaf881e60b270a4428df4014186db';

/// Controller for toggling between dev and production PocketBase instances.
///
/// Stores the preference in secure storage and provides methods to toggle.

abstract class _$PbDebugController extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provides a singleton PocketBase instance.
///
/// The instance uses the URL resolved from --dart-define=ENV or falls back
/// to kDebugMode-based selection.
///
/// Uses [PocketBase.reuseHTTPClient] so the SDK does not call [http.Client.close]
/// after every request. Without that, our shared [TimeoutHttpClient] inner
/// client would be closed on the first API call and all later requests (including
/// `/api/health` polling) would fail — showing "Offline" on the login screen.
///
/// Every request is wrapped with [ApiConstants.requestTimeout] so a dead or
/// very slow connection fails fast with an error instead of leaving the UI
/// spinning indefinitely.

@ProviderFor(pocketbase)
final pocketbaseProvider = PocketbaseProvider._();

/// Provides a singleton PocketBase instance.
///
/// The instance uses the URL resolved from --dart-define=ENV or falls back
/// to kDebugMode-based selection.
///
/// Uses [PocketBase.reuseHTTPClient] so the SDK does not call [http.Client.close]
/// after every request. Without that, our shared [TimeoutHttpClient] inner
/// client would be closed on the first API call and all later requests (including
/// `/api/health` polling) would fail — showing "Offline" on the login screen.
///
/// Every request is wrapped with [ApiConstants.requestTimeout] so a dead or
/// very slow connection fails fast with an error instead of leaving the UI
/// spinning indefinitely.

final class PocketbaseProvider
    extends $FunctionalProvider<PocketBase, PocketBase, PocketBase>
    with $Provider<PocketBase> {
  /// Provides a singleton PocketBase instance.
  ///
  /// The instance uses the URL resolved from --dart-define=ENV or falls back
  /// to kDebugMode-based selection.
  ///
  /// Uses [PocketBase.reuseHTTPClient] so the SDK does not call [http.Client.close]
  /// after every request. Without that, our shared [TimeoutHttpClient] inner
  /// client would be closed on the first API call and all later requests (including
  /// `/api/health` polling) would fail — showing "Offline" on the login screen.
  ///
  /// Every request is wrapped with [ApiConstants.requestTimeout] so a dead or
  /// very slow connection fails fast with an error instead of leaving the UI
  /// spinning indefinitely.
  PocketbaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pocketbaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pocketbaseHash();

  @$internal
  @override
  $ProviderElement<PocketBase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PocketBase create(Ref ref) {
    return pocketbase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PocketBase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PocketBase>(value),
    );
  }
}

String _$pocketbaseHash() => r'82c2822f7dba07d2f2814689a8122294a6a825e7';
