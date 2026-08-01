// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for performing check-ins and managing today's check-in list.
///
/// After first open, stays alive for the session and keeps a PocketBase
/// realtime subscription so other devices' check-ins appear automatically.

@ProviderFor(CheckInController)
final checkInControllerProvider = CheckInControllerProvider._();

/// Controller for performing check-ins and managing today's check-in list.
///
/// After first open, stays alive for the session and keeps a PocketBase
/// realtime subscription so other devices' check-ins appear automatically.
final class CheckInControllerProvider
    extends $AsyncNotifierProvider<CheckInController, List<CheckIn>> {
  /// Controller for performing check-ins and managing today's check-in list.
  ///
  /// After first open, stays alive for the session and keeps a PocketBase
  /// realtime subscription so other devices' check-ins appear automatically.
  CheckInControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkInControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkInControllerHash();

  @$internal
  @override
  CheckInController create() => CheckInController();
}

String _$checkInControllerHash() => r'e09469636e4232d814d7ad71d6aadbbb45cf8e71';

/// Controller for performing check-ins and managing today's check-in list.
///
/// After first open, stays alive for the session and keeps a PocketBase
/// realtime subscription so other devices' check-ins appear automatically.

abstract class _$CheckInController extends $AsyncNotifier<List<CheckIn>> {
  FutureOr<List<CheckIn>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<CheckIn>>, List<CheckIn>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<CheckIn>>, List<CheckIn>>,
              AsyncValue<List<CheckIn>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
