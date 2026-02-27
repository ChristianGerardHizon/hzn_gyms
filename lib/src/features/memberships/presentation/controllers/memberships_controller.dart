import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../data/repositories/membership_repository.dart';
import '../../domain/membership.dart';

part 'memberships_controller.g.dart';

/// Controller for managing the list of membership plans.
@Riverpod(keepAlive: true)
class MembershipsController extends _$MembershipsController {
  MembershipRepository get _repository =>
      ref.read(membershipRepositoryProvider);

  @override
  Future<List<Membership>> build() async {
    final branchId = ref.watch(currentBranchIdProvider);

    final result = await _repository.fetchAll(branchId: branchId);

    return result.fold(
      (failure) => throw failure,
      (memberships) => memberships,
    );
  }

  /// Refreshes the membership list.
  Future<void> refresh() async {
    _repository.invalidateCache();
    state = const AsyncLoading();

    final branchId = ref.read(currentBranchIdProvider);
    final result = await _repository.fetchAll(branchId: branchId);

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (memberships) => AsyncData(memberships),
    );
  }

  /// Creates a new membership plan.
  Future<Membership?> createMembership(Membership membership) async {
    final result = await _repository.create(membership);
    return result.fold(
      (failure) => null,
      (created) {
        refresh();
        return created;
      },
    );
  }

  /// Updates an existing membership plan.
  Future<bool> updateMembership(Membership membership) async {
    final result = await _repository.update(membership);
    return result.fold(
      (failure) => false,
      (updated) {
        refresh();
        return true;
      },
    );
  }

  /// Deletes a membership plan.
  Future<bool> deleteMembership(String id) async {
    final result = await _repository.delete(id);
    return result.fold(
      (failure) => false,
      (_) {
        refresh();
        return true;
      },
    );
  }
}
