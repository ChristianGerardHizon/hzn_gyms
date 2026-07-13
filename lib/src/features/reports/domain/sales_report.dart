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

  /// Number of unpaid or partially paid sales (accounts receivable).
  final int unpaidSalesCount;

  /// Total outstanding balance across unpaid sales.
  final num unpaidBalance;

  /// Staff / cashier sales performance for the period.
  final List<StaffSalesSummary> staffPerformance;

  /// Individual sales in the selected range (newest first).
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
