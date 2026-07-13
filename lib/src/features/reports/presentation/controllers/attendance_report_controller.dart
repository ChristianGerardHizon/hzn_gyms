import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../data/repositories/reports_repository.dart';
import '../../domain/attendance_report.dart';
import 'report_period_controller.dart';

part 'attendance_report_controller.g.dart';

/// Fetches and caches attendance report data.
@Riverpod(keepAlive: true)
Future<AttendanceReport> attendanceReport(Ref ref) async {
  final period = ref.watch(reportPeriodControllerProvider);
  final branchId = ref.watch(currentBranchIdProvider);
  final repository = ref.read(reportsRepositoryProvider);

  final result = await repository.getAttendanceReport(
    period: period,
    branchId: branchId,
  );

  return result.fold(
    (failure) => throw failure,
    (report) => report,
  );
}
