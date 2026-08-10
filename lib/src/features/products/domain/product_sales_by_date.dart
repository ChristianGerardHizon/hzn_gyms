import '../../../core/utils/date_utils.dart';
import '../../pos/domain/product_sale_line.dart';

/// Product sale lines for a single calendar day, with day totals.
class ProductSalesDayGroup {
  const ProductSalesDayGroup({
    required this.date,
    required this.lines,
  });

  /// Local midnight for the day, or null when [lines] have no [ProductSaleLine.created].
  final DateTime? date;

  /// Lines on this day, newest-first (same order as the source list).
  final List<ProductSaleLine> lines;

  /// Qty from lines that [ProductSaleLine.countsTowardSalesTotals].
  num get totalQty => lines.fold<num>(
        0,
        (sum, line) =>
            line.countsTowardSalesTotals ? sum + line.quantity : sum,
      );

  /// Revenue from lines that [ProductSaleLine.countsTowardSalesTotals].
  num get totalRevenue => lines.fold<num>(
        0,
        (sum, line) =>
            line.countsTowardSalesTotals ? sum + line.subtotal : sum,
      );
}

/// Qty + revenue for a product on a given calendar day.
class TodaysProductSalesSummary {
  const TodaysProductSalesSummary({
    required this.totalQty,
    required this.totalRevenue,
  });

  final num totalQty;
  final num totalRevenue;
}

/// Groups [lines] by local calendar day, newest day first.
///
/// Lines with a null [ProductSaleLine.created] are placed in a trailing
/// group with [ProductSalesDayGroup.date] == null.
List<ProductSalesDayGroup> groupProductSalesByDate(
  List<ProductSaleLine> lines,
) {
  if (lines.isEmpty) return const [];

  final orderedDates = <DateTime?>[];
  final byDate = <DateTime?, List<ProductSaleLine>>{};

  for (final line in lines) {
    final key =
        line.created != null ? toLocalDateOnly(line.created!) : null;
    if (!byDate.containsKey(key)) {
      orderedDates.add(key);
      byDate[key] = [];
    }
    byDate[key]!.add(line);
  }

  // Keep dated groups in first-seen (newest-first) order; unknown last.
  final dated = orderedDates.where((d) => d != null).toList();
  final result = <ProductSalesDayGroup>[
    for (final date in dated)
      ProductSalesDayGroup(date: date, lines: byDate[date]!),
  ];
  if (byDate.containsKey(null)) {
    result.add(ProductSalesDayGroup(date: null, lines: byDate[null]!));
  }
  return result;
}

/// Summarizes qty/revenue for lines on the same local calendar day as [now].
TodaysProductSalesSummary todaysProductSalesSummary(
  List<ProductSaleLine> lines, {
  DateTime? now,
}) {
  final today = toLocalDateOnly(now ?? DateTime.now());
  num qty = 0;
  num revenue = 0;

  for (final line in lines) {
    if (line.created == null) continue;
    if (toLocalDateOnly(line.created!) != today) continue;
    if (!line.countsTowardSalesTotals) continue;
    qty += line.quantity;
    revenue += line.subtotal;
  }

  return TodaysProductSalesSummary(totalQty: qty, totalRevenue: revenue);
}
