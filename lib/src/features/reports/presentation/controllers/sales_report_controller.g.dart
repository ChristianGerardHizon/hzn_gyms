// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_report_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches and provides sales report data.

@ProviderFor(salesReport)
final salesReportProvider = SalesReportProvider._();

/// Fetches and provides sales report data.

final class SalesReportProvider
    extends
        $FunctionalProvider<
          AsyncValue<SalesReport>,
          SalesReport,
          FutureOr<SalesReport>
        >
    with $FutureModifier<SalesReport>, $FutureProvider<SalesReport> {
  /// Fetches and provides sales report data.
  SalesReportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'salesReportProvider',
        isAutoDispose: true,
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

String _$salesReportHash() => r'a7a3da9f8f7b6081da9730afdc955cd5b4379448';
