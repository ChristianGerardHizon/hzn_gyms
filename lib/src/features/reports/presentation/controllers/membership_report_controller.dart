import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../data/repositories/reports_repository.dart';
import '../../domain/membership_report.dart';
import 'report_period_controller.dart';

part 'membership_report_controller.g.dart';

/// Fetches and provides membership report data.
@riverpod
Future<MembershipReport> membershipReport(Ref ref) async {
  final period = ref.watch(reportPeriodControllerProvider);
  final branchId = ref.watch(currentBranchIdProvider);
  final repository = ref.read(reportsRepositoryProvider);

  final result = await repository.getMembershipReport(
    startDate: period.startDate,
    endDate: period.endDate,
    branchId: branchId,
  );

  return result.fold(
    (failure) => throw failure,
    (report) => report,
  );
}
