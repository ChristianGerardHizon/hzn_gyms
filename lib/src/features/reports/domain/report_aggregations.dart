import 'package:intl/intl.dart';

import 'period_bucket.dart';
import 'report_period.dart';

/// Pure aggregation helpers for report calculations (unit-testable).

/// Formats a local calendar date as `yyyy-MM-dd` for PocketBase view filters.
///
/// Report views must bucket with SQLite `localtime` (e.g.
/// `DATE(s.created, 'localtime')`) so these local dates align with Manila
/// business days — UTC `DATE(s.created)` shifts overnight sales to yesterday.
String formatViewDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Formats a month key as `yyyy-MM`.
String formatViewMonth(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  return '$y-$m';
}

String formatViewYear(DateTime date) => date.year.toString();

DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);

/// Monday 00:00 of the week containing [date] (ISO-style Mon–Sun).
DateTime startOfWeekMonday(DateTime date) {
  final day = startOfDay(date);
  // Dart weekday: Mon=1 … Sun=7
  return day.subtract(Duration(days: day.weekday - 1));
}

/// Sunday 23:59:59.999 of the week containing [date].
DateTime endOfWeekSunday(DateTime date) {
  final monday = startOfWeekMonday(date);
  return DateTime(monday.year, monday.month, monday.day + 6, 23, 59, 59, 999);
}

DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month);

DateTime endOfMonth(DateTime date) =>
    DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);

DateTime startOfYear(DateTime date) => DateTime(date.year);

DateTime endOfYear(DateTime date) =>
    DateTime(date.year, 12, 31, 23, 59, 59, 999);

/// Builds a PocketBase filter for a date-like view field.
///
/// Year fields (`sale_year`, `checkin_year`) are JSON numbers from
/// `strftime('%Y', …)` — compare without quotes. Month/day keys are strings.
String? buildViewDateRangeFilter({
  required String field,
  required DateTime startDate,
  required DateTime endDate,
  String? branchId,
  bool asMonth = false,
  bool asYear = false,
}) {
  final List<String> parts;
  if (asYear) {
    // Numeric JSON year — quoted strings match nothing in PocketBase.
    final start = formatViewYear(startDate);
    final end = formatViewYear(endDate);
    parts = <String>['$field >= $start', '$field <= $end'];
  } else if (asMonth) {
    final start = formatViewMonth(startDate);
    final end = formatViewMonth(endDate);
    parts = <String>["$field >= '$start'", "$field <= '$end'"];
  } else {
    final start = formatViewDate(startDate);
    final end = formatViewDate(endDate);
    parts = <String>["$field >= '$start'", "$field <= '$end'"];
  }
  if (branchId != null && branchId.isNotEmpty) {
    parts.add('branch = "$branchId"');
  }
  return parts.join(' && ');
}

/// Builds a PocketBase filter for view `sale_date` fields (DATE strings).
String? buildSaleDateViewFilter({
  required DateTime startDate,
  required DateTime endDate,
  String? branchId,
}) {
  return buildViewDateRangeFilter(
    field: 'sale_date',
    startDate: startDate,
    endDate: endDate,
    branchId: branchId,
  );
}

/// Axis label for a trend bucket.
String trendLabel(DateTime periodStart, TrendGranularity grain) {
  switch (grain) {
    case TrendGranularity.day:
      return DateFormat('EEE').format(periodStart);
    case TrendGranularity.week:
      return DateFormat('MMM d').format(periodStart);
    case TrendGranularity.month:
      return DateFormat('MMM').format(periodStart);
    case TrendGranularity.year:
      return periodStart.year.toString();
  }
}

/// Expected bucket starts for zero-fill (inclusive range).
List<DateTime> expectedBucketStarts({
  required DateTime rangeStart,
  required DateTime rangeEnd,
  required TrendGranularity grain,
}) {
  final starts = <DateTime>[];
  switch (grain) {
    case TrendGranularity.day:
      var cursor = startOfDay(rangeStart);
      final end = startOfDay(rangeEnd);
      while (!cursor.isAfter(end)) {
        starts.add(cursor);
        cursor = cursor.add(const Duration(days: 1));
      }
    case TrendGranularity.week:
      var cursor = startOfWeekMonday(rangeStart);
      final end = startOfWeekMonday(rangeEnd);
      while (!cursor.isAfter(end)) {
        starts.add(cursor);
        cursor = cursor.add(const Duration(days: 7));
      }
    case TrendGranularity.month:
      var cursor = startOfMonth(rangeStart);
      final end = startOfMonth(rangeEnd);
      while (!cursor.isAfter(end)) {
        starts.add(cursor);
        cursor = DateTime(cursor.year, cursor.month + 1);
      }
    case TrendGranularity.year:
      var year = rangeStart.year;
      final endYear = rangeEnd.year;
      while (year <= endYear) {
        starts.add(DateTime(year));
        year++;
      }
  }
  return starts;
}

/// Merges sparse [values] into a full zero-filled trend series.
List<PeriodBucket> zeroFillBuckets({
  required Map<DateTime, num> values,
  required DateTime rangeStart,
  required DateTime rangeEnd,
  required TrendGranularity grain,
}) {
  final expected = expectedBucketStarts(
    rangeStart: rangeStart,
    rangeEnd: rangeEnd,
    grain: grain,
  );
  return expected
      .map(
        (start) => PeriodBucket(
          periodStart: start,
          value: values[start] ?? 0,
          label: trendLabel(start, grain),
        ),
      )
      .toList();
}

/// Parses a view period key into a bucket start DateTime.
DateTime? parseBucketStart(String raw, TrendGranularity grain) {
  if (raw.isEmpty) return null;
  switch (grain) {
    case TrendGranularity.day:
    case TrendGranularity.week:
      final parsed = DateTime.tryParse(raw)?.toLocal();
      if (parsed == null) return null;
      return grain == TrendGranularity.week
          ? startOfWeekMonday(parsed)
          : startOfDay(parsed);
    case TrendGranularity.month:
      if (raw.length >= 7 && raw[4] == '-') {
        final y = int.tryParse(raw.substring(0, 4));
        final m = int.tryParse(raw.substring(5, 7));
        if (y != null && m != null) return DateTime(y, m);
      }
      final parsed = DateTime.tryParse(raw)?.toLocal();
      return parsed == null ? null : startOfMonth(parsed);
    case TrendGranularity.year:
      final y = int.tryParse(raw.length >= 4 ? raw.substring(0, 4) : raw);
      return y == null ? null : DateTime(y);
  }
}

/// Aggregates item-type revenue from sale line items.
Map<String, num> aggregateRevenueByItemType(
  Iterable<({String? itemType, num subtotal})> items,
) {
  final result = <String, num>{};
  for (final item in items) {
    final type = (item.itemType == null || item.itemType!.isEmpty)
        ? 'product'
        : item.itemType!;
    result[type] = (result[type] ?? 0) + item.subtotal;
  }
  return result;
}

/// Display label for item type keys.
String itemTypeLabel(String type) {
  switch (type) {
    case 'membership':
      return 'Membership';
    case 'addon':
      return 'Add-on';
    case 'product':
      return 'Product';
    case 'walkIn':
      return 'Walk-in';
    default:
      return type;
  }
}

/// Normalizes empty/null sale line types to `product`.
String normalizeSalesItemType(String? itemType) {
  if (itemType == null || itemType.isEmpty) return 'product';
  return itemType;
}

/// Whether Day/Week/Month should fetch period-scoped raw rows instead of
/// all-history SQL views.
///
/// PocketBase views re-aggregate the full sales table (~100k+ rows) on every
/// request, then filter — Month is fast when scoped to that month's sales.
/// Year/All Time stay on views (scoped fetch of 10k–100k rows is slower).
bool usesPeriodScopedSalesFetch(ReportPeriod period) =>
    period == ReportPeriod.day ||
    period == ReportPeriod.weekly ||
    period == ReportPeriod.monthly;

/// Derives Day-period revenue KPIs from raw sales when the summary view is empty.
///
/// Counts `completed`/`paid` sales; revenue sums only paid sales so unpaid AR
/// does not inflate “cash collected.”
({num totalRevenue, int transactionCount}) daySalesKpisFromSales(
  Iterable<({String status, bool isPaid, num totalAmount})> sales,
) {
  var totalRevenue = 0.0;
  var transactionCount = 0;
  for (final sale in sales) {
    if (sale.status == 'voided' || sale.status == 'refunded') continue;
    if (!isReportableSaleStatus(sale.status)) continue;
    transactionCount++;
    if (sale.isPaid) totalRevenue += sale.totalAmount.toDouble();
  }
  return (totalRevenue: totalRevenue, transactionCount: transactionCount);
}

/// Net payment contribution (refunds subtract), matching POS paid totals.
num netPaymentAmount({required String type, required num amount}) {
  if (type.toLowerCase() == 'refund') return -amount;
  return amount;
}

/// Whether a sale status counts toward Day/Week revenue KPIs and charts.
///
/// Checkout marks fully paid sales as `paid`; older rows may still be
/// `completed`. Both are included so reports match the sales list.
bool isReportableSaleStatus(String status) =>
    status == 'completed' || status == 'paid';

/// Builds Day/Week KPIs from period-scoped sales + payments.
///
/// Revenue and payment-method totals come from payment rows linked to
/// `completed`/`paid` sales. Transaction count is distinct reportable sale IDs.
/// Trend buckets use each sale's local [created] date.
({
  num totalRevenue,
  int transactionCount,
  Map<DateTime, num> revenueByBucket,
  Map<String, num> revenueByPaymentMethod,
})
aggregateScopedSalesPayments({
  required Iterable<({String saleId, String status, DateTime? created})> sales,
  required Iterable<
    ({String saleId, String paymentMethod, String type, num amount})
  >
  payments,
  required TrendGranularity grain,
}) {
  final completedCreated = <String, DateTime>{};
  for (final sale in sales) {
    if (!isReportableSaleStatus(sale.status)) continue;
    final created = sale.created;
    if (created == null) continue;
    completedCreated[sale.saleId] = created;
  }

  var totalRevenue = 0.0;
  final revenueByBucket = <DateTime, num>{};
  final revenueByPaymentMethod = <String, num>{};

  for (final payment in payments) {
    final created = completedCreated[payment.saleId];
    if (created == null) continue;

    final net = netPaymentAmount(
      type: payment.type,
      amount: payment.amount,
    ).toDouble();
    totalRevenue += net;

    final DateTime bucket;
    switch (grain) {
      case TrendGranularity.day:
        bucket = startOfDay(created);
      case TrendGranularity.week:
        bucket = startOfWeekMonday(created);
      case TrendGranularity.month:
        bucket = startOfMonth(created);
      case TrendGranularity.year:
        bucket = DateTime(created.year);
    }
    revenueByBucket[bucket] = (revenueByBucket[bucket] ?? 0) + net;

    final method = payment.paymentMethod;
    if (method.isNotEmpty) {
      revenueByPaymentMethod[method] =
          (revenueByPaymentMethod[method] ?? 0) + net;
    }
  }

  // Match view semantics: count every reportable sale, even with no payments.
  return (
    totalRevenue: totalRevenue,
    transactionCount: completedCreated.length,
    revenueByBucket: revenueByBucket,
    revenueByPaymentMethod: revenueByPaymentMethod,
  );
}

/// Item-type revenue from period-scoped sale lines on reportable sales.
Map<String, num> aggregateScopedRevenueByItemType(
  Iterable<({String saleId, String? itemType, num subtotal})> items,
  Set<String> reportableSaleIds,
) {
  return aggregateRevenueByItemType(
    items
        .where((i) => reportableSaleIds.contains(i.saleId))
        .map((i) => (itemType: i.itemType, subtotal: i.subtotal)),
  );
}

/// Counts unpaid / AR sales (excludes voided and refunded).
({int unpaidCount, num unpaidBalance}) aggregateUnpaidSales(
  Iterable<({String status, bool isPaid, num totalAmount})> sales,
) {
  var unpaidCount = 0;
  num unpaidBalance = 0;
  for (final sale in sales) {
    if (sale.status == 'voided' || sale.status == 'refunded') continue;
    if (!sale.isPaid && sale.totalAmount > 0) {
      unpaidCount++;
      unpaidBalance += sale.totalAmount;
    }
  }
  return (unpaidCount: unpaidCount, unpaidBalance: unpaidBalance);
}

/// Aggregates cashier performance from lean sale rows.
///
/// [staffNames] maps cashier id → display name. Missing names become `Unknown`.
List<({String staffId, String staffName, int transactionCount, num revenue})>
aggregateStaffPerformance(
  Iterable<({String status, String cashierId, num totalAmount})> sales, {
  Map<String, String> staffNames = const {},
}) {
  final staffMap = <String, ({String name, int count, num revenue})>{};
  for (final sale in sales) {
    if (sale.status == 'voided' || sale.status == 'refunded') continue;
    final cashierId = sale.cashierId;
    if (cashierId.isEmpty) continue;
    final name = staffNames[cashierId] ?? 'Unknown';
    final amount = sale.totalAmount;
    final existing = staffMap[cashierId];
    if (existing != null) {
      staffMap[cashierId] = (
        name: existing.name,
        count: existing.count + 1,
        revenue: existing.revenue + amount,
      );
    } else {
      staffMap[cashierId] = (name: name, count: 1, revenue: amount);
    }
  }
  return staffMap.entries
      .map(
        (e) => (
          staffId: e.key,
          staffName: e.value.name,
          transactionCount: e.value.count,
          revenue: e.value.revenue,
        ),
      )
      .toList()
    ..sort((a, b) => b.revenue.compareTo(a.revenue));
}

/// Aggregates view rows into ranked top-selling items (all sale line types).
///
/// Rows are keyed by name + item type so a product and membership with the
/// same name stay separate. Every non-empty named line is included.
List<({String name, String itemType, num quantity, num revenue})>
aggregateTopSellingItems(
  Iterable<({String name, String? itemType, num quantity, num revenue})> rows,
) {
  final map =
      <String, ({String name, String itemType, num quantity, num revenue})>{};
  for (final row in rows) {
    if (row.name.isEmpty) continue;
    final type = normalizeSalesItemType(row.itemType);
    final key = '${row.name}\u0000$type';
    final existing = map[key];
    if (existing != null) {
      map[key] = (
        name: existing.name,
        itemType: existing.itemType,
        quantity: existing.quantity + row.quantity,
        revenue: existing.revenue + row.revenue,
      );
    } else {
      map[key] = (
        name: row.name,
        itemType: type,
        quantity: row.quantity,
        revenue: row.revenue,
      );
    }
  }
  return map.values.toList()..sort((a, b) => b.revenue.compareTo(a.revenue));
}

/// Normalizes a sale line into the Sales revenue-by-type bucket.
///
/// Walk-in / guest day-pass lines ([hasLinkedMember] false with membership or
/// addon type) are reported as `walkIn` so they stay visible in Sales while
/// remaining excluded from the Memberships report.
String salesItemTypeBucket({
  required String? itemType,
  required bool hasLinkedMember,
}) {
  final type = normalizeSalesItemType(itemType);
  if (!hasLinkedMember && (type == 'membership' || type == 'addon')) {
    return 'walkIn';
  }
  return type;
}

/// Whether a sale line should count toward the Memberships report.
///
/// Walk-in / guest day-pass sales ([saleHasLinkedMember] false) and plans with
/// [planMemberNotRequired] belong in the Sales report only — they create no
/// member subscription lifecycle.
bool includeInMembershipReport({
  required bool saleHasLinkedMember,
  bool planMemberNotRequired = false,
}) {
  if (!saleHasLinkedMember) return false;
  if (planMemberNotRequired) return false;
  return true;
}

/// Sums membership vs add-on plan value for the Memberships report.
///
/// Skips walk-in / guest lines ([hasLinkedMember] false).
({num membershipRevenue, num addOnRevenue}) sumMembershipReportSaleRevenue(
  Iterable<({String? itemType, num subtotal, bool hasLinkedMember})> items,
) {
  num membershipRevenue = 0;
  num addOnRevenue = 0;
  for (final item in items) {
    if (!includeInMembershipReport(saleHasLinkedMember: item.hasLinkedMember)) {
      continue;
    }
    final type = item.itemType;
    if (type == 'walkIn') continue;
    if (type == 'addon') {
      addOnRevenue += item.subtotal;
    } else if (type == 'membership') {
      membershipRevenue += item.subtotal;
    }
  }
  return (membershipRevenue: membershipRevenue, addOnRevenue: addOnRevenue);
}

/// Classifies period memberships as new subscriptions vs renewals.
({int newSubscriptions, int renewals}) classifyNewVsRenewals(
  List<({String id, String memberId, DateTime created})> periodMemberships,
  Map<String, List<DateTime>> priorMembershipCreatedByMember,
) {
  var newCount = 0;
  var renewCount = 0;
  for (final mm in periodMemberships) {
    final priors = priorMembershipCreatedByMember[mm.memberId] ?? const [];
    final hadPrior = priors.any((c) => c.isBefore(mm.created));
    if (hadPrior) {
      renewCount++;
    } else {
      newCount++;
    }
  }
  return (newSubscriptions: newCount, renewals: renewCount);
}

/// Counts memberships that ended in period with no follow-on renewal.
int countLapsedMemberships({
  required List<({String memberId, DateTime endDate})> endedInPeriod,
  required Map<String, List<DateTime>> laterStartsByMember,
}) {
  var count = 0;
  for (final ended in endedInPeriod) {
    final later = laterStartsByMember[ended.memberId] ?? const [];
    final renewed = later.any(
      (start) =>
          !start.isBefore(ended.endDate) ||
          start.difference(ended.endDate).inDays.abs() <= 1,
    );
    if (!renewed) count++;
  }
  return count;
}

/// Builds OR filter chunks for relation IDs.
List<String> buildIdOrFilters(
  String field,
  List<String> ids, {
  int chunkSize = 50,
}) {
  if (ids.isEmpty) return const [];
  final filters = <String>[];
  for (var i = 0; i < ids.length; i += chunkSize) {
    final chunk = ids.skip(i).take(chunkSize);
    final or = chunk.map((id) => '$field = "$id"').join(' || ');
    filters.add('($or)');
  }
  return filters;
}

/// Aggregates check-ins by hour label (`00`–`23`).
Map<String, num> aggregateCheckInsByHour(Iterable<DateTime> times) {
  final byHour = <String, num>{};
  for (final t in times) {
    final key = t.hour.toString().padLeft(2, '0');
    byHour[key] = (byHour[key] ?? 0) + 1;
  }
  return Map.fromEntries(
    byHour.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );
}

/// Buckets timestamps into a map keyed by [TrendGranularity] start.
Map<DateTime, num> bucketTimestamps(
  Iterable<DateTime> times,
  TrendGranularity grain,
) {
  final map = <DateTime, num>{};
  for (final t in times) {
    final DateTime key;
    switch (grain) {
      case TrendGranularity.day:
        key = startOfDay(t);
      case TrendGranularity.week:
        key = startOfWeekMonday(t);
      case TrendGranularity.month:
        key = startOfMonth(t);
      case TrendGranularity.year:
        key = DateTime(t.year);
    }
    map[key] = (map[key] ?? 0) + 1;
  }
  return map;
}

/// Effective stock quantity for inventory views.
num effectiveStockQuantity({
  required bool trackByLot,
  required num quantity,
  required num lotTotalQuantity,
}) {
  return trackByLot ? lotTotalQuantity : quantity;
}

/// Stock status bucket for inventory reporting.
String stockStatusLabel({required num qty, required num threshold}) {
  if (qty <= 0) return 'Out of Stock';
  if (threshold > 0 && qty <= threshold) return 'Low Stock';
  return 'In Stock';
}

/// Which sales summary view + date field to use for [period].
({String collection, String dateField, bool asMonth, bool asYear})
salesSummaryViewFor(ReportPeriod period) {
  switch (period) {
    case ReportPeriod.day:
    case ReportPeriod.weekly:
      return (
        collection: 'vw_sales_daily_summary',
        dateField: 'sale_date',
        asMonth: false,
        asYear: false,
      );
    case ReportPeriod.monthly:
      return (
        collection: 'vw_sales_weekly_summary',
        dateField: 'week_start',
        asMonth: false,
        asYear: false,
      );
    case ReportPeriod.yearly:
      return (
        collection: 'vw_sales_monthly_summary',
        dateField: 'sale_month',
        asMonth: true,
        asYear: false,
      );
    case ReportPeriod.allTime:
      return (
        collection: 'vw_sales_yearly_summary',
        dateField: 'sale_year',
        asMonth: false,
        asYear: true,
      );
  }
}

({String collection, String dateField, bool asMonth, bool asYear})
revenueByItemTypeViewFor(ReportPeriod period) {
  switch (period) {
    case ReportPeriod.day:
    case ReportPeriod.weekly:
      return (
        collection: 'vw_revenue_by_item_type',
        dateField: 'sale_date',
        asMonth: false,
        asYear: false,
      );
    case ReportPeriod.monthly:
      return (
        collection: 'vw_revenue_by_item_type_weekly',
        dateField: 'week_start',
        asMonth: false,
        asYear: false,
      );
    case ReportPeriod.yearly:
      return (
        collection: 'vw_revenue_by_item_type_yearly',
        dateField: 'sale_year',
        asMonth: false,
        asYear: true,
      );
    case ReportPeriod.allTime:
      return (
        collection: 'vw_revenue_by_item_type_yearly',
        dateField: 'sale_year',
        asMonth: false,
        asYear: true,
      );
  }
}

({String collection, String dateField, bool asMonth, bool asYear})
topSellingViewFor(ReportPeriod period) {
  switch (period) {
    case ReportPeriod.day:
    case ReportPeriod.weekly:
      return (
        collection: 'vw_top_selling_products',
        dateField: 'sale_date',
        asMonth: false,
        asYear: false,
      );
    case ReportPeriod.monthly:
      return (
        collection: 'vw_top_selling_products_monthly',
        dateField: 'sale_month',
        asMonth: true,
        asYear: false,
      );
    case ReportPeriod.yearly:
    case ReportPeriod.allTime:
      return (
        collection: 'vw_top_selling_products_yearly',
        dateField: 'sale_year',
        asMonth: false,
        asYear: true,
      );
  }
}

({String collection, String dateField, bool asMonth, bool asYear})
checkinsViewFor(ReportPeriod period) {
  switch (period) {
    case ReportPeriod.day:
    case ReportPeriod.weekly:
      return (
        collection: 'vw_checkins_daily_summary',
        dateField: 'checkin_date',
        asMonth: false,
        asYear: false,
      );
    case ReportPeriod.monthly:
      return (
        collection: 'vw_checkins_weekly_summary',
        dateField: 'week_start',
        asMonth: false,
        asYear: false,
      );
    case ReportPeriod.yearly:
      return (
        collection: 'vw_checkins_monthly_summary',
        dateField: 'checkin_month',
        asMonth: true,
        asYear: false,
      );
    case ReportPeriod.allTime:
      return (
        collection: 'vw_checkins_yearly_summary',
        dateField: 'checkin_year',
        asMonth: false,
        asYear: true,
      );
  }
}
