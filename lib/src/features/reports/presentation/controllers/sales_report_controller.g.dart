// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_report_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Shared Day/Week fetch so KPIs and extras do not download sales twice.

@ProviderFor(scopedSalesReportBundle)
final scopedSalesReportBundleProvider = ScopedSalesReportBundleProvider._();

/// Shared Day/Week fetch so KPIs and extras do not download sales twice.

final class ScopedSalesReportBundleProvider
    extends
        $FunctionalProvider<
          AsyncValue<ScopedSalesReportBundle?>,
          ScopedSalesReportBundle?,
          FutureOr<ScopedSalesReportBundle?>
        >
    with
        $FutureModifier<ScopedSalesReportBundle?>,
        $FutureProvider<ScopedSalesReportBundle?> {
  /// Shared Day/Week fetch so KPIs and extras do not download sales twice.
  ScopedSalesReportBundleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scopedSalesReportBundleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scopedSalesReportBundleHash();

  @$internal
  @override
  $FutureProviderElement<ScopedSalesReportBundle?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ScopedSalesReportBundle?> create(Ref ref) {
    return scopedSalesReportBundle(ref);
  }
}

String _$scopedSalesReportBundleHash() =>
    r'a1b2c3d4e5f60718293a4b5c6d7e8f90a1b2c3d4';

/// Sales KPIs and charts.
///
/// Day/Week use period-scoped raw rows; longer periods use SQL views.

@ProviderFor(salesReport)
final salesReportProvider = SalesReportProvider._();

/// Sales KPIs and charts.
///
/// Day/Week use period-scoped raw rows; longer periods use SQL views.

final class SalesReportProvider
    extends
        $FunctionalProvider<
          AsyncValue<SalesReport>,
          SalesReport,
          FutureOr<SalesReport>
        >
    with $FutureModifier<SalesReport>, $FutureProvider<SalesReport> {
  /// Sales KPIs and charts.
  ///
  /// Day/Week use period-scoped raw rows; longer periods use SQL views.
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

String _$salesReportHash() => r'b2c3d4e5f60718293a4b5c6d7e8f90a1b2c3d4e5';

/// Unpaid / staff / Day list.
///
/// Day/Week reuse [scopedSalesReportBundleProvider]; longer periods fetch lean
/// sales separately after the view-based KPIs.

@ProviderFor(salesReportExtras)
final salesReportExtrasProvider = SalesReportExtrasProvider._();

/// Unpaid / staff / Day list.
///
/// Day/Week reuse [scopedSalesReportBundleProvider]; longer periods fetch lean
/// sales separately after the view-based KPIs.

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
  /// Unpaid / staff / Day list.
  ///
  /// Day/Week reuse [scopedSalesReportBundleProvider]; longer periods fetch lean
  /// sales separately after the view-based KPIs.
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

String _$salesReportExtrasHash() => r'c3d4e5f60718293a4b5c6d7e8f90a1b2c3d4e5f6';
