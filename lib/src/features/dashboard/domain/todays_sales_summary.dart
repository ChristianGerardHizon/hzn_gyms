import '../../reports/domain/report_aggregations.dart';

/// Aggregated today's sales KPI (count + revenue).
class TodaySalesSummary {
  const TodaySalesSummary({
    required this.count,
    required this.total,
    this.byBranch = const [],
    this.membershipTotal = 0,
    this.walkInTotal = 0,
  });

  final int count;
  final num total;

  /// Per-branch rows from `vw_todays_sales` (populated when viewing All).
  final List<TodaysSalesBranchRow> byBranch;

  /// Line-item revenue for `membership` from `vw_revenue_by_item_type`.
  final num membershipTotal;

  /// Line-item revenue for `walkIn` from `vw_revenue_by_item_type`.
  final num walkInTotal;
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
  });

  final String itemType;
  final num totalRevenue;
}

/// Sums all branch rows. Used when viewing All branches (and is a no-op for a
/// single filtered branch row).
TodaySalesSummary aggregateTodaysSalesSummary(
  Iterable<TodaysSalesBranchRow> rows, {
  num membershipTotal = 0,
  num walkInTotal = 0,
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
  );
}

/// Sums membership and walk-in line revenue from item-type view rows.
({num membershipTotal, num walkInTotal}) aggregateTodaysItemTypeRevenue(
  Iterable<TodaysItemTypeRevenueRow> rows,
) {
  num membershipTotal = 0;
  num walkInTotal = 0;
  for (final row in rows) {
    final type = normalizeSalesItemType(row.itemType);
    if (type == 'membership') {
      membershipTotal += row.totalRevenue;
    } else if (type == 'walkIn') {
      walkInTotal += row.totalRevenue;
    }
  }
  return (membershipTotal: membershipTotal, walkInTotal: walkInTotal);
}
