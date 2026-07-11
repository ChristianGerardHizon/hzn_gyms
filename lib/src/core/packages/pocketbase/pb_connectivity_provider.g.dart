// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pb_connectivity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Polls PocketBase `/api/health` to determine whether the server is reachable.
///
/// Returns `true` when online, `false` when offline.
/// Polls every 15s while online and every 5s while offline for faster recovery.

@ProviderFor(PbConnectivity)
final pbConnectivityProvider = PbConnectivityProvider._();

/// Polls PocketBase `/api/health` to determine whether the server is reachable.
///
/// Returns `true` when online, `false` when offline.
/// Polls every 15s while online and every 5s while offline for faster recovery.
final class PbConnectivityProvider
    extends $AsyncNotifierProvider<PbConnectivity, bool> {
  /// Polls PocketBase `/api/health` to determine whether the server is reachable.
  ///
  /// Returns `true` when online, `false` when offline.
  /// Polls every 15s while online and every 5s while offline for faster recovery.
  PbConnectivityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pbConnectivityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pbConnectivityHash();

  @$internal
  @override
  PbConnectivity create() => PbConnectivity();
}

String _$pbConnectivityHash() => r'31f4be01061b2b3475b4f4feed9a799c585cde4a';

/// Polls PocketBase `/api/health` to determine whether the server is reachable.
///
/// Returns `true` when online, `false` when offline.
/// Polls every 15s while online and every 5s while offline for faster recovery.

abstract class _$PbConnectivity extends $AsyncNotifier<bool> {
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
