// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todays_sales_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Today's sales data.
/// Filtered by the current branch.

@ProviderFor(todaySales)
final todaySalesProvider = TodaySalesProvider._();

/// Today's sales data.
/// Filtered by the current branch.

final class TodaySalesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Sale>>,
          List<Sale>,
          FutureOr<List<Sale>>
        >
    with $FutureModifier<List<Sale>>, $FutureProvider<List<Sale>> {
  /// Today's sales data.
  /// Filtered by the current branch.
  TodaySalesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todaySalesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todaySalesHash();

  @$internal
  @override
  $FutureProviderElement<List<Sale>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Sale>> create(Ref ref) {
    return todaySales(ref);
  }
}

String _$todaySalesHash() => r'25356457bd9c2f927f6f64e4199b9346e78a3912';

/// Today's sales summary (count and total amount).
/// Uses vw_todays_sales view for optimized query.
/// Filtered by the current branch.

@ProviderFor(todaySalesSummary)
final todaySalesSummaryProvider = TodaySalesSummaryProvider._();

/// Today's sales summary (count and total amount).
/// Uses vw_todays_sales view for optimized query.
/// Filtered by the current branch.

final class TodaySalesSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<TodaySalesSummary>,
          TodaySalesSummary,
          FutureOr<TodaySalesSummary>
        >
    with
        $FutureModifier<TodaySalesSummary>,
        $FutureProvider<TodaySalesSummary> {
  /// Today's sales summary (count and total amount).
  /// Uses vw_todays_sales view for optimized query.
  /// Filtered by the current branch.
  TodaySalesSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todaySalesSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todaySalesSummaryHash();

  @$internal
  @override
  $FutureProviderElement<TodaySalesSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TodaySalesSummary> create(Ref ref) {
    return todaySalesSummary(ref);
  }
}

String _$todaySalesSummaryHash() => r'093ac4a116b2f9e8b8af16aa9ab7e071a85a6e97';
