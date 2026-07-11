// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_redirect_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Stores the URL user intended to visit before auth resolved.
///
/// Used to redirect back after successful authentication on web,
/// where users can directly access deep links.

@ProviderFor(PendingRedirect)
final pendingRedirectProvider = PendingRedirectProvider._();

/// Stores the URL user intended to visit before auth resolved.
///
/// Used to redirect back after successful authentication on web,
/// where users can directly access deep links.
final class PendingRedirectProvider
    extends $NotifierProvider<PendingRedirect, String?> {
  /// Stores the URL user intended to visit before auth resolved.
  ///
  /// Used to redirect back after successful authentication on web,
  /// where users can directly access deep links.
  PendingRedirectProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingRedirectProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingRedirectHash();

  @$internal
  @override
  PendingRedirect create() => PendingRedirect();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$pendingRedirectHash() => r'8adadcc2dbad6c37eb148a9f5101c423cecda7e9';

/// Stores the URL user intended to visit before auth resolved.
///
/// Used to redirect back after successful authentication on web,
/// where users can directly access deep links.

abstract class _$PendingRedirect extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
