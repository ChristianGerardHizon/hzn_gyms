// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_report_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// View-based sales KPIs and charts (fast path).

@ProviderFor(salesReport)
final salesReportProvider = SalesReportProvider._();

/// View-based sales KPIs and charts (fast path).

final class SalesReportProvider
    extends
        $FunctionalProvider<
          AsyncValue<SalesReport>,
          SalesReport,
          FutureOr<SalesReport>
        >
    with $FutureModifier<SalesReport>, $FutureProvider<SalesReport> {
  /// View-based sales KPIs and charts (fast path).
  SalesReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'salesReportProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$salesReportHash();

  @$internal
  @override
  $FutureProviderElement<SalesReport> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SalesReport> create(Ref ref) {
    return salesReport(ref);
  }
}

String _$salesReportHash() => r'6f60843ad016bf0586d02b840eae1df248db9836';

/// Lean unpaid / staff / Day list — loads after [salesReportProvider].

@ProviderFor(salesReportExtras)
final salesReportExtrasProvider = SalesReportExtrasProvider._();

/// Lean unpaid / staff / Day list — loads after [salesReportProvider].

final class SalesReportExtrasProvider
    extends
        $FunctionalProvider<
          AsyncValue<SalesReportExtras>,
          SalesReportExtras,
          FutureOr<SalesReportExtras>
        >
    with
        $FutureModifier<SalesReportExtras>,
        $FutureProvider<SalesReportExtras> {
  /// Lean unpaid / staff / Day list — loads after [salesReportProvider].
  SalesReportExtrasProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'salesReportExtrasProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$salesReportExtrasHash();

  @$internal
  @override
  $FutureProviderElement<SalesReportExtras> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SalesReportExtras> create(Ref ref) {
    return salesReportExtras(ref);
  }
}

String _$salesReportExtrasHash() => r'f8e52173e962444ba3a6a5d69e05e177b50c5cd6';
