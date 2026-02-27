// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for performing check-ins and managing today's check-in list.

@ProviderFor(CheckInController)
final checkInControllerProvider = CheckInControllerProvider._();

/// Controller for performing check-ins and managing today's check-in list.
final class CheckInControllerProvider
    extends $AsyncNotifierProvider<CheckInController, List<CheckIn>> {
  /// Controller for performing check-ins and managing today's check-in list.
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

String _$checkInControllerHash() => r'e1f5d44878fd53d9da4ff36c7dfff77fc98c25bc';

/// Controller for performing check-ins and managing today's check-in list.

abstract class _$CheckInController extends $AsyncNotifier<List<CheckIn>> {
  FutureOr<List<CheckIn>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<CheckIn>>, List<CheckIn>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<CheckIn>>, List<CheckIn>>,
        AsyncValue<List<CheckIn>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
