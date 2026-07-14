// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_records_date_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Selected calendar day for the Check-In Records page.

@ProviderFor(CheckInRecordsDateController)
final checkInRecordsDateControllerProvider =
    CheckInRecordsDateControllerProvider._();

/// Selected calendar day for the Check-In Records page.
final class CheckInRecordsDateControllerProvider
    extends $NotifierProvider<CheckInRecordsDateController, DateTime> {
  /// Selected calendar day for the Check-In Records page.
  CheckInRecordsDateControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkInRecordsDateControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkInRecordsDateControllerHash();

  @$internal
  @override
  CheckInRecordsDateController create() => CheckInRecordsDateController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$checkInRecordsDateControllerHash() =>
    r'31cbad0a937c4f0545cb91eb17607eb5aff8ad80';

/// Selected calendar day for the Check-In Records page.

abstract class _$CheckInRecordsDateController extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
