import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../data/repositories/reports_repository.dart';
import '../../domain/sales_report.dart';
import 'report_period_controller.dart';

part 'sales_report_controller.g.dart';

/// View-based sales KPIs and charts (fast path).
@Riverpod(keepAlive: true)
Future<SalesReport> salesReport(Ref ref) async {
  final period = ref.watch(reportPeriodControllerProvider);
  final branchId = ref.watch(currentBranchIdProvider);
  final repository = ref.read(reportsRepositoryProvider);

  final result = await repository.getSalesReport(
    period: period,
    branchId: branchId,
  );

  return result.fold((failure) => throw failure, (report) => report);
}

/// Lean unpaid / staff / Day list — loads after [salesReportProvider].
@Riverpod(keepAlive: true)
Future<SalesReportExtras> salesReportExtras(Ref ref) async {
  final period = ref.watch(reportPeriodControllerProvider);
  final branchId = ref.watch(currentBranchIdProvider);
  final repository = ref.read(reportsRepositoryProvider);

  final result = await repository.getSalesReportExtras(
    period: period,
    branchId: branchId,
  );

  return result.fold((failure) => throw failure, (extras) => extras);
}
