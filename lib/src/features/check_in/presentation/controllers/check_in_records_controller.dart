import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../organizations/presentation/controllers/current_organization_controller.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../data/repositories/check_in_repository.dart';
import '../../domain/check_in.dart';
import 'check_in_records_date_controller.dart';

part 'check_in_records_controller.g.dart';

/// Loads check-in history for the selected date and branch.
@riverpod
class CheckInRecordsController extends _$CheckInRecordsController {
  CheckInRepository get _repository => ref.read(checkInRepositoryProvider);

  @override
  Future<List<CheckIn>> build() async {
    final date = ref.watch(checkInRecordsDateControllerProvider);
    final branchId = ref.watch(currentBranchIdProvider);
    final organizationId = ref.watch(currentOrganizationIdProvider);
    final result = await _repository.fetchByDate(
      date: date,
      branchId: branchId,
      organizationId: organizationId,
    );

    return result.fold((failure) => throw failure, (checkIns) => checkIns);
  }

  /// Reloads check-ins for the current date/branch.
  Future<void> refresh() async {
    state = const AsyncLoading();

    final date = ref.read(checkInRecordsDateControllerProvider);
    final branchId = ref.read(currentBranchIdProvider);
    final organizationId = ref.read(currentOrganizationIdProvider);
    final result = await _repository.fetchByDate(
      date: date,
      branchId: branchId,
      organizationId: organizationId,
    );

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (checkIns) => AsyncData(checkIns),
    );
  }
}
