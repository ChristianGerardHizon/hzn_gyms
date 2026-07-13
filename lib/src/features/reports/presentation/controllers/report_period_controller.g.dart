// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_period_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the selected report period grain and start/end range.

@ProviderFor(ReportPeriodController)
final reportPeriodControllerProvider = ReportPeriodControllerProvider._();

/// Manages the selected report period grain and start/end range.
final class ReportPeriodControllerProvider
    extends $NotifierProvider<ReportPeriodController, ReportPeriodSelection> {
  /// Manages the selected report period grain and start/end range.
  ReportPeriodControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportPeriodControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportPeriodControllerHash();

  @$internal
  @override
  ReportPeriodController create() => ReportPeriodController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReportPeriodSelection value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReportPeriodSelection>(value),
    );
  }
}

String _$reportPeriodControllerHash() =>
    r'2315e3ce95f4cc24c3054be8ff0ad0efb7e02c12';

/// Manages the selected report period grain and start/end range.

abstract class _$ReportPeriodController
    extends $Notifier<ReportPeriodSelection> {
  ReportPeriodSelection build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ReportPeriodSelection, ReportPeriodSelection>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReportPeriodSelection, ReportPeriodSelection>,
              ReportPeriodSelection,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
