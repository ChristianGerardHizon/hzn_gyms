// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_period_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the currently selected report period across all reports.

@ProviderFor(ReportPeriodController)
final reportPeriodControllerProvider = ReportPeriodControllerProvider._();

/// Manages the currently selected report period across all reports.
final class ReportPeriodControllerProvider
    extends $NotifierProvider<ReportPeriodController, ReportPeriod> {
  /// Manages the currently selected report period across all reports.
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
  Override overrideWithValue(ReportPeriod value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReportPeriod>(value),
    );
  }
}

String _$reportPeriodControllerHash() =>
    r'15814a8e9dd52ef745836ce694dd45779b8aea97';

/// Manages the currently selected report period across all reports.

abstract class _$ReportPeriodController extends $Notifier<ReportPeriod> {
  ReportPeriod build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ReportPeriod, ReportPeriod>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReportPeriod, ReportPeriod>,
              ReportPeriod,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
