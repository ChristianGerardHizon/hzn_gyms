import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../pos/data/repositories/sales_repository.dart';
import '../../../pos/domain/sale.dart';
import '../../../reports/domain/report_aggregations.dart';
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
  // Match vw_todays_sales: completed/paid only (excludes voided/pending).
  final result = await ref.read(salesRepositoryProvider).getSales(
    branchId: branchId,
    date: today,
    limit: todaysSalesListLimit,
    statuses: const ['completed', 'paid'],
  );
  return result.fold(
    (failure) => [],
    (sales) => sales,
  );
}

/// Today's sales summary (count and total amount).
/// Uses [PocketBaseCollections.vwTodaysSales] (Manila-day UTC range on server).
/// Must match [todaySales] day boundaries — view uses fixed UTC+8, not server TZ.
/// Membership / walk-in totals come from [PocketBaseCollections.vwRevenueByItemType].
/// Filtered by the current branch.
@riverpod
Future<TodaySalesSummary> todaySalesSummary(Ref ref) async {
  final branchId = ref.watch(currentBranchIdProvider);
  final pb = ref.read(pocketbaseProvider);
  final today = DateTime.now().toLocal();
  final itemTypeFilter = buildSaleDateViewFilter(
    startDate: today,
    endDate: today,
    branchId: branchId,
  );

  final results = await Future.wait([
    pb.collection(PocketBaseCollections.vwTodaysSales).getFullList(
      filter: branchId != null ? 'branch = "$branchId"' : null,
    ),
    pb.collection(PocketBaseCollections.vwRevenueByItemType).getFullList(
      filter: itemTypeFilter,
    ),
  ]);

  final salesRecords = results[0];
  final itemTypeRecords = results[1];

  final rows = salesRecords.map(
    (record) => TodaysSalesBranchRow(
      branchId: record.getStringValue('branch'),
      transactionCount: record.getIntValue('transaction_count'),
      totalRevenue: record.getDoubleValue('total_revenue'),
    ),
  );
  final itemTypeTotals = aggregateTodaysItemTypeRevenue(
    itemTypeRecords.map(
      (record) => TodaysItemTypeRevenueRow(
        itemType: record.getStringValue('itemType'),
        totalRevenue: record.getDoubleValue('total_revenue'),
      ),
    ),
  );
  return aggregateTodaysSalesSummary(
    rows,
    membershipTotal: itemTypeTotals.membershipTotal,
    walkInTotal: itemTypeTotals.walkInTotal,
  );
}
