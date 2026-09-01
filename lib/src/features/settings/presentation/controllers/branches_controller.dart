import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../organizations/presentation/controllers/current_organization_controller.dart';
import '../../data/repositories/branch_repository.dart';
import '../../domain/branch.dart';

part 'branches_controller.g.dart';

/// Controller for managing branch list state.
///
/// Provides methods for fetching and CRUD operations on branches, scoped to
/// the current organization once resolved.
@Riverpod(keepAlive: true)
class BranchesController extends _$BranchesController {
  BranchRepository get _repository => ref.read(branchRepositoryProvider);

  @override
  Future<List<Branch>> build() async {
    final organizationId = ref.watch(currentOrganizationIdProvider);
    final result = await _repository.fetchAll(organizationId: organizationId);
    return result.fold(
      (failure) => throw failure,
      (branches) => branches,
    );
  }

  /// Refreshes the branch list.
  Future<void> refresh() async {
    // Avoid wiping previous data so list UIs (and search inputs) stay mounted.
    if (!state.hasValue) {
      state = const AsyncLoading();
    }

    final organizationId = ref.read(currentOrganizationIdProvider);
    final result = await _repository.fetchAll(organizationId: organizationId);

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (branches) => AsyncData(branches),
    );
  }

  /// Creates a new branch, always scoped to the current organization
  /// (branches belong to whichever org the caller is currently in — not
  /// user-selectable).
  Future<bool> createBranch(Branch branch) async {
    final organizationId = ref.read(currentOrganizationIdProvider);
    final result = await _repository.create(
      branch.copyWith(organization: organizationId),
    );

    return result.fold(
      (failure) => false,
      (newBranch) {
        final currentList = state.value ?? [];
        state = AsyncData([newBranch, ...currentList]);
        return true;
      },
    );
  }

  /// Updates an existing branch.
  Future<bool> updateBranch(Branch branch) async {
    final result = await _repository.update(branch);

    return result.fold(
      (failure) => false,
      (updatedBranch) {
        final currentList = state.value ?? [];
        final updatedList = currentList.map((b) {
          return b.id == updatedBranch.id ? updatedBranch : b;
        }).toList();
        state = AsyncData(updatedList);
        return true;
      },
    );
  }

  /// Deletes a branch (soft delete).
  Future<bool> deleteBranch(String id) async {
    final result = await _repository.delete(id);

    return result.fold(
      (failure) => false,
      (_) {
        final currentList = state.value ?? [];
        final updatedList = currentList.where((b) => b.id != id).toList();
        state = AsyncData(updatedList);
        return true;
      },
    );
  }
}
