import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../pos/data/repositories/sales_repository.dart';
import '../../../pos/domain/sale.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/todays_sales_summary.dart';

export '../../domain/todays_sales_summary.dart';

part 'todays_sales_controller.g.dart';

/// Max sales fetched for dashboard recent transactions / breakdown lists.
/// KPI totals still come from [todaySalesSummary] (server aggregate view).
const int todaysSalesListLimit = 50;

/// Today's sales data.
/// Filtered by the current branch.
@riverpod
Future<List<Sale>> todaySales(Ref ref) async {
  final branchId = ref.watch(currentBranchIdProvider);
  // Use local time to determine "today" for the user's timezone
  final today = DateTime.now().toLocal();
  final result = await ref.read(salesRepositoryProvider).getSales(
    branchId: branchId,
    date: today,
    limit: todaysSalesListLimit,
  );
  return result.fold(
    (failure) => [],
    (sales) => sales,
  );
}

/// Today's sales summary (count and total amount).
/// Uses vw_todays_sales view for optimized query.
/// Filtered by the current branch.
@riverpod
Future<TodaySalesSummary> todaySalesSummary(Ref ref) async {
  final branchId = ref.watch(currentBranchIdProvider);
  final pb = ref.read(pocketbaseProvider);
  final records = await pb
      .collection(PocketBaseCollections.vwTodaysSales)
      .getFullList(
        filter: branchId != null ? 'branch = "$branchId"' : null,
      );

  final rows = records.map(
    (record) => TodaysSalesBranchRow(
      transactionCount: record.getIntValue('transaction_count'),
      totalRevenue: record.getDoubleValue('total_revenue'),
    ),
  );
  return aggregateTodaysSalesSummary(rows);
}
