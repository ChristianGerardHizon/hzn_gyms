// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_records_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads check-in history for the selected date and branch.

@ProviderFor(CheckInRecordsController)
final checkInRecordsControllerProvider = CheckInRecordsControllerProvider._();

/// Loads check-in history for the selected date and branch.
final class CheckInRecordsControllerProvider
    extends $AsyncNotifierProvider<CheckInRecordsController, List<CheckIn>> {
  /// Loads check-in history for the selected date and branch.
  CheckInRecordsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkInRecordsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkInRecordsControllerHash();

  @$internal
  @override
  CheckInRecordsController create() => CheckInRecordsController();
}

String _$checkInRecordsControllerHash() =>
    r'885bc34c5756a8a00335105f27ad06cee30c3ad2';

/// Loads check-in history for the selected date and branch.

abstract class _$CheckInRecordsController
    extends $AsyncNotifier<List<CheckIn>> {
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
