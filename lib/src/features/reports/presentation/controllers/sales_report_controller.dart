import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../data/repositories/reports_repository.dart';
import '../../domain/report_aggregations.dart';
import '../../domain/sales_report.dart';
import 'report_period_controller.dart';

part 'sales_report_controller.g.dart';

/// Shared Day/Week fetch so KPIs and extras do not download sales twice.
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
/// Day/Week use period-scoped raw rows; longer periods use SQL views.
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
/// Day/Week reuse [scopedSalesReportBundleProvider]; longer periods fetch lean
/// sales separately after the view-based KPIs.
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
