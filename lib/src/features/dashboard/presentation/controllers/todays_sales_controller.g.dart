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

String _$todaySalesHash() => r'463641acfebbfe000e0aaa7a232ad38f4f0c2293';

/// Today's sales summary (count and total amount).
/// Uses [PocketBaseCollections.vwTodaysSales] (Manila-day UTC range on server).
/// Must match [todaySales] day boundaries — view uses fixed UTC+8, not server TZ.
/// Membership / walk-in / product totals come from [PocketBaseCollections.vwRevenueByItemType].
/// Payment-method totals come from [PocketBaseCollections.vwSalesDailySummary].
/// Filtered by the current branch.

@ProviderFor(todaySalesSummary)
final todaySalesSummaryProvider = TodaySalesSummaryProvider._();

/// Today's sales summary (count and total amount).
/// Uses [PocketBaseCollections.vwTodaysSales] (Manila-day UTC range on server).
/// Must match [todaySales] day boundaries — view uses fixed UTC+8, not server TZ.
/// Membership / walk-in / product totals come from [PocketBaseCollections.vwRevenueByItemType].
/// Payment-method totals come from [PocketBaseCollections.vwSalesDailySummary].
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
  /// Uses [PocketBaseCollections.vwTodaysSales] (Manila-day UTC range on server).
  /// Must match [todaySales] day boundaries — view uses fixed UTC+8, not server TZ.
  /// Membership / walk-in / product totals come from [PocketBaseCollections.vwRevenueByItemType].
  /// Payment-method totals come from [PocketBaseCollections.vwSalesDailySummary].
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

String _$todaySalesSummaryHash() => r'997c6dc0caa75138670c5cc13908ba8ecb509f80';

/// Today's open unpaid sales for the effective write branch.

@ProviderFor(todayUnpaidSales)
final todayUnpaidSalesProvider = TodayUnpaidSalesProvider._();

/// Today's open unpaid sales for the effective write branch.

final class TodayUnpaidSalesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Sale>>,
          List<Sale>,
          FutureOr<List<Sale>>
        >
    with $FutureModifier<List<Sale>>, $FutureProvider<List<Sale>> {
  /// Today's open unpaid sales for the effective write branch.
  TodayUnpaidSalesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayUnpaidSalesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayUnpaidSalesHash();

  @$internal
  @override
  $FutureProviderElement<List<Sale>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Sale>> create(Ref ref) {
    return todayUnpaidSales(ref);
  }
}

String _$todayUnpaidSalesHash() => r'd2942f3bc57e24d675014d7283e5e729b3799a35';
