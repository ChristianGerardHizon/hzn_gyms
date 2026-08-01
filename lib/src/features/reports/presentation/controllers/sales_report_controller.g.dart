// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_report_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Shared Day/Week/Month fetch so KPIs and extras do not download sales twice.

@ProviderFor(scopedSalesReportBundle)
final scopedSalesReportBundleProvider = ScopedSalesReportBundleProvider._();

/// Shared Day/Week/Month fetch so KPIs and extras do not download sales twice.

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
  /// Shared Day/Week/Month fetch so KPIs and extras do not download sales twice.
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
    r'ee65ffb8cc44dab6c53f226964f8e322ea876719';

/// Sales KPIs and charts.
///
/// Day/Week/Month use period-scoped raw rows; Year/All Time use SQL views.

@ProviderFor(salesReport)
final salesReportProvider = SalesReportProvider._();

/// Sales KPIs and charts.
///
/// Day/Week/Month use period-scoped raw rows; Year/All Time use SQL views.

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
  /// Day/Week/Month use period-scoped raw rows; Year/All Time use SQL views.
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

String _$salesReportHash() => r'c2abfd3d15d90b7e989db179ca61cde455a569df';

/// Unpaid / staff / Day list.
///
/// Day/Week/Month reuse [scopedSalesReportBundleProvider]; Year/All Time fetch
/// unpaid rows only (full-period sales download is too expensive).

@ProviderFor(salesReportExtras)
final salesReportExtrasProvider = SalesReportExtrasProvider._();

/// Unpaid / staff / Day list.
///
/// Day/Week/Month reuse [scopedSalesReportBundleProvider]; Year/All Time fetch
/// unpaid rows only (full-period sales download is too expensive).

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
  /// Day/Week/Month reuse [scopedSalesReportBundleProvider]; Year/All Time fetch
  /// unpaid rows only (full-period sales download is too expensive).
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

String _$salesReportExtrasHash() => r'37482ccf8377ef1dfa2a7efbc11b4b5e7753cffe';
