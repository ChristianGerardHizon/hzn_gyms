import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../data/repositories/pos_group_repository.dart';
import '../../domain/pos_group.dart';
import '../../domain/pos_group_item.dart';

part 'pos_groups_controller.g.dart';

/// Controller for managing POS groups for the current branch.
///
/// Provides CRUD operations on groups and group items.
/// Groups are loaded with their items expanded (products).
@Riverpod(keepAlive: true)
class PosGroupsController extends _$PosGroupsController {
  PosGroupRepository get _repository =>
      ref.read(posGroupRepositoryProvider);

  @override
  Future<List<PosGroup>> build() async {
    final branchId = ref.watch(currentBranchIdProvider);
    if (branchId == null) return [];

    final result = await _repository.fetchGroupsWithItems(branchId);
    return result.fold(
      (failure) => throw failure,
      (groups) => groups,
    );
  }

  /// Refreshes the group list.
  Future<void> refresh() async {
    _repository.invalidateCache();
    state = const AsyncLoading();

    final branchId = ref.read(currentBranchIdProvider);
    if (branchId == null) {
      state = const AsyncData([]);
      return;
    }

    final result = await _repository.fetchGroupsWithItems(branchId);

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (groups) => AsyncData(groups),
    );
  }

  /// Creates a new group.
  ///
  /// Returns `null` on success, or an error message string on failure.
  Future<String?> createGroup(String name) async {
    final branchId = ref.read(currentBranchIdProvider);
    if (branchId == null) {
      return 'No branch selected';
    }

    final currentList = state.value ?? [];
    final group = PosGroup(
      name: name,
      branchId: branchId,
      sortOrder: currentList.length,
    );

    final result = await _repository.createGroup(group);

    return result.fold(
      (failure) => failure.messageString,
      (newGroup) {
        state = AsyncData([...currentList, newGroup]);
        return null;
      },
    );
  }

  /// Updates a group's name.
  ///
  /// Returns `null` on success, or an error message string on failure.
  Future<String?> updateGroup(String groupId, String name) async {
    final currentList = state.value ?? [];
    final existing = currentList.firstWhere((g) => g.id == groupId);

    final updated = existing.copyWith(name: name);
    final result = await _repository.updateGroup(updated);

    return result.fold(
      (failure) => failure.messageString,
      (updatedGroup) {
        final updatedList = currentList.map((g) {
          return g.id == groupId
              ? updatedGroup.copyWith(items: g.items)
              : g;
        }).toList();
        state = AsyncData(updatedList);
        return null;
      },
    );
  }

  /// Deletes a group (soft delete).
  Future<bool> deleteGroup(String groupId) async {
    final result = await _repository.deleteGroup(groupId);

    return result.fold(
      (failure) => false,
      (_) {
        final currentList = state.value ?? [];
        final updatedList =
            currentList.where((g) => g.id != groupId).toList();
        state = AsyncData(updatedList);
        return true;
      },
    );
  }

  /// Reorders groups.
  Future<bool> reorderGroups(List<PosGroup> reorderedGroups) async {
    // Optimistically update state
    state = AsyncData(reorderedGroups);

    final result = await _repository.reorderGroups(reorderedGroups);

    return result.fold(
      (failure) {
        // Revert on failure
        refresh();
        return false;
      },
      (_) => true,
    );
  }

  /// Adds a product to a group.
  Future<bool> addProductToGroup(String groupId, String productId) async {
    final currentList = state.value ?? [];
    final group = currentList.firstWhere((g) => g.id == groupId);

    final item = PosGroupItem(
      groupId: groupId,
      productId: productId,
      sortOrder: group.items.length,
    );

    final result = await _repository.addItemToGroup(item);

    return result.fold(
      (failure) => false,
      (newItem) {
        final updatedList = currentList.map((g) {
          if (g.id == groupId) {
            return g.copyWith(items: [...g.items, newItem]);
          }
          return g;
        }).toList();
        state = AsyncData(updatedList);
        return true;
      },
    );
  }

  /// Removes an item from a group.
  Future<bool> removeItemFromGroup(String groupId, String itemId) async {
    final result = await _repository.removeItemFromGroup(itemId);

    return result.fold(
      (failure) => false,
      (_) {
        final currentList = state.value ?? [];
        final updatedList = currentList.map((g) {
          if (g.id == groupId) {
            return g.copyWith(
              items: g.items.where((i) => i.id != itemId).toList(),
            );
          }
          return g;
        }).toList();
        state = AsyncData(updatedList);
        return true;
      },
    );
  }

  /// Reorders items within a group.
  Future<bool> reorderItems(
      String groupId, List<PosGroupItem> reorderedItems) async {
    // Optimistically update
    final currentList = state.value ?? [];
    final updatedList = currentList.map((g) {
      if (g.id == groupId) {
        return g.copyWith(items: reorderedItems);
      }
      return g;
    }).toList();
    state = AsyncData(updatedList);

    final result = await _repository.reorderItems(groupId, reorderedItems);

    return result.fold(
      (failure) {
        refresh();
        return false;
      },
      (_) => true,
    );
  }
}
