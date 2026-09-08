import '../../reports/domain/report_aggregations.dart';

/// Aggregated today's sales KPI (count + revenue).
class TodaySalesSummary {
  const TodaySalesSummary({
    required this.count,
    required this.total,
    this.byBranch = const [],
    this.membershipTotal = 0,
    this.walkInTotal = 0,
    this.productTotal = 0,
    int membershipCount = 0,
    int walkInCount = 0,
    int productCount = 0,
    Map<String, num> revenueByPaymentMethod = const {},
    Map<String, int> transactionCountByPaymentMethod = const {},
  })  : _membershipCount = membershipCount,
        _walkInCount = walkInCount,
        _productCount = productCount,
        _revenueByPaymentMethod = revenueByPaymentMethod,
        _transactionCountByPaymentMethod = transactionCountByPaymentMethod;

  final int count;
  final num total;

  /// Per-branch rows from `vw_todays_sales` (populated when viewing All).
  final List<TodaysSalesBranchRow> byBranch;

  /// Line-item revenue for `membership` from `vw_revenue_by_item_type`.
  final num membershipTotal;

  /// Line-item revenue for `walkIn` from `vw_revenue_by_item_type`.
  final num walkInTotal;

  /// Line-item revenue for `product` from `vw_revenue_by_item_type`.
  final num productTotal;

  // Stored as nullable so hot-reloaded in-memory instances (created before
  // these fields existed) read as 0 instead of throwing on web/DDC.
  final int? _membershipCount;
  final int? _walkInCount;
  final int? _productCount;
  final Map<String, num>? _revenueByPaymentMethod;
  final Map<String, int>? _transactionCountByPaymentMethod;

  /// Distinct sales with `membership` lines today.
  int get membershipCount => _membershipCount ?? 0;

  /// Distinct sales with `walkIn` lines today.
  int get walkInCount => _walkInCount ?? 0;

  /// Distinct sales with `product` lines today.
  int get productCount => _productCount ?? 0;

  /// Payment revenue by method key (`cash` / `card` / …) from daily summary.
  Map<String, num> get revenueByPaymentMethod =>
      _revenueByPaymentMethod ?? const {};

  /// Distinct sale counts by payment method from daily summary.
  Map<String, int> get transactionCountByPaymentMethod =>
      _transactionCountByPaymentMethod ?? const {};
}

/// One per-branch row from `vw_todays_sales`.
class TodaysSalesBranchRow {
  const TodaysSalesBranchRow({
    required this.branchId,
    required this.transactionCount,
    required this.totalRevenue,
  });

  final String branchId;
  final int transactionCount;
  final num totalRevenue;
}

/// One item-type revenue row from `vw_revenue_by_item_type`.
class TodaysItemTypeRevenueRow {
  const TodaysItemTypeRevenueRow({
    required this.itemType,
    required this.totalRevenue,
    int transactionCount = 0,
  }) : _transactionCount = transactionCount;

  final String itemType;
  final num totalRevenue;

  // Nullable storage: hot-reloaded rows created before this field existed.
  final int? _transactionCount;

  int get transactionCount => _transactionCount ?? 0;
}

/// Sums all branch rows. Used when viewing All branches (and is a no-op for a
/// single filtered branch row).
TodaySalesSummary aggregateTodaysSalesSummary(
  Iterable<TodaysSalesBranchRow> rows, {
  num membershipTotal = 0,
  num walkInTotal = 0,
  num productTotal = 0,
  int membershipCount = 0,
  int walkInCount = 0,
  int productCount = 0,
  Map<String, num> revenueByPaymentMethod = const {},
  Map<String, int> transactionCountByPaymentMethod = const {},
}) {
  final byBranch = rows.toList();
  var count = 0;
  num total = 0;
  for (final row in byBranch) {
    count += row.transactionCount;
    total += row.totalRevenue;
  }
  return TodaySalesSummary(
    count: count,
    total: total,
    byBranch: byBranch,
    membershipTotal: membershipTotal,
    walkInTotal: walkInTotal,
    productTotal: productTotal,
    membershipCount: membershipCount,
    walkInCount: walkInCount,
    productCount: productCount,
    revenueByPaymentMethod: revenueByPaymentMethod,
    transactionCountByPaymentMethod: transactionCountByPaymentMethod,
  );
}

/// Sums membership, walk-in, and product line revenue + transaction counts.
///
/// Add-on lines are excluded from these primary KPI totals (still appear in
/// sales report pie charts).
({
  num membershipTotal,
  num walkInTotal,
  num productTotal,
  int membershipCount,
  int walkInCount,
  int productCount,
})
aggregateTodaysItemTypeRevenue(Iterable<TodaysItemTypeRevenueRow> rows) {
  num membershipTotal = 0;
  num walkInTotal = 0;
  num productTotal = 0;
  var membershipCount = 0;
  var walkInCount = 0;
  var productCount = 0;
  for (final row in rows) {
    final type = normalizeSalesItemType(row.itemType);
    if (type == 'membership') {
      membershipTotal += row.totalRevenue;
      membershipCount += row.transactionCount;
    } else if (type == 'walkIn') {
      walkInTotal += row.totalRevenue;
      walkInCount += row.transactionCount;
    } else if (type == 'product') {
      productTotal += row.totalRevenue;
      productCount += row.transactionCount;
    }
  }
  return (
    membershipTotal: membershipTotal,
    walkInTotal: walkInTotal,
    productTotal: productTotal,
    membershipCount: membershipCount,
    walkInCount: walkInCount,
    productCount: productCount,
  );
}
