import 'package:dart_mappable/dart_mappable.dart';

import '../../pos/domain/sale.dart';
import 'period_bucket.dart';

part 'sales_report.mapper.dart';

/// Aggregated sales data for a time period.
@MappableClass()
class SalesReport with SalesReportMappable {
  const SalesReport({
    required this.totalRevenue,
    required this.transactionCount,
    required this.averageTransactionValue,
    required this.revenueTrend,
    required this.revenueByPaymentMethod,
    required this.topSellingProducts,
    this.revenueByItemType = const {},
    this.transactionCountByItemType,
    this.transactionCountByPaymentMethod,
    this.unpaidSalesCount = 0,
    this.unpaidBalance = 0,
    this.staffPerformance = const [],
    this.sales = const [],
  });

  /// Total revenue in the period (cash collected from payments).
  final num totalRevenue;

  /// Number of transactions.
  final int transactionCount;

  /// Average transaction value.
  final num averageTransactionValue;

  /// Revenue trend buckets (day / week / month / year depending on period).
  final List<PeriodBucket> revenueTrend;

  /// Revenue grouped by payment method (for pie chart).
  final Map<String, num> revenueByPaymentMethod;

  /// Top selling items (products, memberships, walk-ins) with quantities.
  final List<ProductSalesSummary> topSellingProducts;

  /// Revenue split by sale item type: product / membership / walkIn / addon.
  final Map<String, num> revenueByItemType;

  /// Distinct sale counts by item type (same keys as [revenueByItemType]).
  ///
  /// Nullable so hot-reloaded in-memory instances (created before this field
  /// existed) do not throw on web/DDC; treat null as empty.
  final Map<String, int>? transactionCountByItemType;

  /// Sale / payment counts by payment method (same keys as [revenueByPaymentMethod]).
  ///
  /// Nullable for hot-reload safety; treat null as empty.
  final Map<String, int>? transactionCountByPaymentMethod;

  /// Number of unpaid or partially paid sales (accounts receivable).
  final int unpaidSalesCount;

  /// Total outstanding balance across unpaid sales.
  final num unpaidBalance;

  /// Staff / cashier sales performance for the period.
  final List<StaffSalesSummary> staffPerformance;

  /// Individual sales in the selected range (newest first).
  ///
  /// Populated for Day period only (list UI / PDF). Longer periods keep this
  /// empty so report load does not download every transaction.
  final List<Sale> sales;

  /// Empty report for initial/error states.
  static const empty = SalesReport(
    totalRevenue: 0,
    transactionCount: 0,
    averageTransactionValue: 0,
    revenueTrend: [],
    revenueByPaymentMethod: {},
    topSellingProducts: [],
  );

  /// Merges view-based [core] KPIs/charts with lean [extras] (unpaid, staff, day list).
  ///
  /// When core has no transactions and [SalesReportExtras.dayKpiOverride] is set
  /// (Day fallback), KPI totals come from the override.
  SalesReport mergeExtras(SalesReportExtras extras) {
    var totalRevenue = this.totalRevenue;
    var transactionCount = this.transactionCount;
    final override = extras.dayKpiOverride;
    if (transactionCount == 0 &&
        override != null &&
        override.transactionCount > 0) {
      totalRevenue = override.totalRevenue;
      transactionCount = override.transactionCount;
    }
    final avgValue = transactionCount > 0 ? totalRevenue / transactionCount : 0;
    return copyWith(
      totalRevenue: totalRevenue,
      transactionCount: transactionCount,
      averageTransactionValue: avgValue,
      // Explicit so hot-reload / copyWith never drops type / method counts.
      transactionCountByItemType: transactionCountByItemType,
      transactionCountByPaymentMethod: transactionCountByPaymentMethod,
      unpaidSalesCount: extras.unpaidSalesCount,
      unpaidBalance: extras.unpaidBalance,
      staffPerformance: extras.staffPerformance,
      sales: extras.sales,
    );
  }
}

/// Combined Day/Week sales payload from one period-scoped fetch.
class ScopedSalesReportBundle {
  const ScopedSalesReportBundle({required this.report, required this.extras});

  final SalesReport report;
  final SalesReportExtras extras;

  static const empty = ScopedSalesReportBundle(
    report: SalesReport.empty,
    extras: SalesReportExtras.empty,
  );
}

/// Secondary sales-report payload loaded after view-based KPIs/charts.
///
/// Built from lean `sales` rows (no `expand`) so unpaid / staff / Day list can
/// progress without blocking the first paint.
class SalesReportExtras {
  const SalesReportExtras({
    this.unpaidSalesCount = 0,
    this.unpaidBalance = 0,
    this.staffPerformance = const [],
    this.sales = const [],
    this.dayKpiOverride,
  });

  final int unpaidSalesCount;
  final num unpaidBalance;
  final List<StaffSalesSummary> staffPerformance;

  /// Day-period transaction list only; empty for longer periods.
  final List<Sale> sales;

  /// Optional Day KPI fallback when the summary view returned no rows.
  final ({num totalRevenue, int transactionCount})? dayKpiOverride;

  static const empty = SalesReportExtras();
}

/// Summary of a top-selling sale line (product, membership, walk-in, add-on).
@MappableClass()
class ProductSalesSummary with ProductSalesSummaryMappable {
  const ProductSalesSummary({
    required this.productName,
    required this.quantity,
    required this.revenue,
    this.itemType = 'product',
  });

  final String productName;
  final num quantity;
  final num revenue;

  /// Sale line type: product / membership / walkIn / addon.
  final String itemType;
}

/// Staff sales performance summary.
@MappableClass()
class StaffSalesSummary with StaffSalesSummaryMappable {
  const StaffSalesSummary({
    required this.staffId,
    required this.staffName,
    required this.transactionCount,
    required this.revenue,
  });

  final String staffId;
  final String staffName;
  final int transactionCount;
  final num revenue;
}
