import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../pos/domain/sale.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../data/repositories/reports_repository.dart';
import '../../domain/report_aggregations.dart';
import '../../domain/sales_report.dart';
import 'report_period_controller.dart';

part 'sales_report_controller.g.dart';

/// Shared Day/Week/Month fetch so KPIs and extras do not download sales twice.
@Riverpod(keepAlive: true)
Future<ScopedSalesReportBundle?> scopedSalesReportBundle(Ref ref) async {
  final period = ref.watch(reportPeriodControllerProvider);
  if (!usesPeriodScopedSalesFetch(period.period)) return null;

  final branchId = ref.watch(currentBranchIdProvider);
  final repository = ref.read(reportsRepositoryProvider);
  final result = await repository.getScopedSalesReportBundle(
    period: period,
    branchId: branchId,
  );
  return result.fold((failure) => throw failure, (bundle) => bundle);
}

/// Sales KPIs and charts.
///
/// Day/Week/Month use period-scoped raw rows; Year/All Time use SQL views.
@Riverpod(keepAlive: true)
Future<SalesReport> salesReport(Ref ref) async {
  final period = ref.watch(reportPeriodControllerProvider);
  if (usesPeriodScopedSalesFetch(period.period)) {
    final bundle = await ref.watch(scopedSalesReportBundleProvider.future);
    return bundle?.report ?? SalesReport.empty;
  }

  final branchId = ref.watch(currentBranchIdProvider);
  final repository = ref.read(reportsRepositoryProvider);
  final result = await repository.getSalesReport(
    period: period,
    branchId: branchId,
  );
  return result.fold((failure) => throw failure, (report) => report);
}

/// Unpaid / staff / Day list.
///
/// Day/Week/Month reuse [scopedSalesReportBundleProvider]; Year/All Time fetch
/// unpaid rows only (full-period sales download is too expensive).
@Riverpod(keepAlive: true)
Future<SalesReportExtras> salesReportExtras(Ref ref) async {
  final period = ref.watch(reportPeriodControllerProvider);
  if (usesPeriodScopedSalesFetch(period.period)) {
    final bundle = await ref.watch(scopedSalesReportBundleProvider.future);
    return bundle?.extras ?? SalesReportExtras.empty;
  }

  final branchId = ref.watch(currentBranchIdProvider);
  final repository = ref.read(reportsRepositoryProvider);
  final result = await repository.getSalesReportExtras(
    period: period,
    branchId: branchId,
  );
  return result.fold((failure) => throw failure, (extras) => extras);
}

/// Sales that include at least one line of [itemType] for the selected period.
///
/// [itemType] is `membership` / `walkIn` / `product`. Used by the Sales report
/// KPI drill-down dialogs.
@riverpod
Future<List<Sale>> salesByItemType(Ref ref, String itemType) async {
  final period = ref.watch(reportPeriodControllerProvider);
  final branchId = ref.watch(currentBranchIdProvider);
  final repository = ref.read(reportsRepositoryProvider);
  final result = await repository.getSalesByItemType(
    period: period,
    itemType: itemType,
    branchId: branchId,
  );
  return result.fold((failure) => throw failure, (sales) => sales);
}
