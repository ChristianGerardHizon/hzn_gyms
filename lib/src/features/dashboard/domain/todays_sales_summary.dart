/// Aggregated today's sales KPI (count + revenue).
class TodaySalesSummary {
  const TodaySalesSummary({
    required this.count,
    required this.total,
  });

  final int count;
  final num total;
}

/// One per-branch row from `vw_todays_sales`.
class TodaysSalesBranchRow {
  const TodaysSalesBranchRow({
    required this.transactionCount,
    required this.totalRevenue,
  });

  final int transactionCount;
  final num totalRevenue;
}

/// Sums all branch rows. Used when viewing All branches (and is a no-op for a
/// single filtered branch row).
TodaySalesSummary aggregateTodaysSalesSummary(
  Iterable<TodaysSalesBranchRow> rows,
) {
  var count = 0;
  num total = 0;
  for (final row in rows) {
    count += row.transactionCount;
    total += row.totalRevenue;
  }
  return TodaySalesSummary(count: count, total: total);
}
