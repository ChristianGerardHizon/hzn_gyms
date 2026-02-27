import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/top_selling_item.dart';

part 'top_selling_controller.g.dart';

/// Top 5 selling products (all-time, aggregated from date-grouped view).
///
/// Queries [PocketBaseCollections.vwTopSellingProducts], aggregates rows
/// by product (since the view groups by date), sorts by revenue descending,
/// and returns the top 5.
@riverpod
Future<List<TopSellingItem>> topSellingProducts(Ref ref) async {
  final branchId = ref.watch(currentBranchIdProvider);
  final pb = ref.read(pocketbaseProvider);

  final records = await pb
      .collection(PocketBaseCollections.vwTopSellingProducts)
      .getFullList(
        filter: branchId != null ? 'branch = "$branchId"' : null,
      );

  return _aggregateAndSort(
    records,
    nameField: 'productName',
    idField: 'product_id',
  );
}

/// Aggregates date-grouped view records by item, sums quantities/revenue/
/// transactions, sorts by total revenue descending, and returns top 5.
List<TopSellingItem> _aggregateAndSort(
  List<RecordModel> records, {
  required String nameField,
  required String idField,
}) {
  final Map<String, _AggregatedData> aggregated = {};

  for (final record in records) {
    final itemId = record.getStringValue(idField);
    final name = record.getStringValue(nameField);
    final key = itemId.isNotEmpty ? itemId : name;

    final existing = aggregated[key];
    final qty = record.get<num>('total_quantity_sold').toInt();
    final revenue = record.get<num>('total_revenue').toDouble();
    final txCount = record.getIntValue('transaction_count');

    if (existing != null) {
      existing.totalQuantitySold += qty;
      existing.totalRevenue += revenue;
      existing.transactionCount += txCount;
    } else {
      aggregated[key] = _AggregatedData(
        name: name,
        itemId: itemId,
        totalQuantitySold: qty,
        totalRevenue: revenue,
        transactionCount: txCount,
      );
    }
  }

  final sorted = aggregated.values.toList()
    ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));

  return sorted.take(5).map((data) {
    return TopSellingItem(
      name: data.name,
      itemId: data.itemId,
      totalQuantitySold: data.totalQuantitySold,
      totalRevenue: data.totalRevenue,
      transactionCount: data.transactionCount,
    );
  }).toList();
}

class _AggregatedData {
  _AggregatedData({
    required this.name,
    required this.itemId,
    required this.totalQuantitySold,
    required this.totalRevenue,
    required this.transactionCount,
  });

  final String name;
  final String itemId;
  int totalQuantitySold;
  double totalRevenue;
  int transactionCount;
}
