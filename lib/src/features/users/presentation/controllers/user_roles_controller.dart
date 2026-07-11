import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/user_role_repository.dart';
import '../../domain/user_role.dart';

part 'user_roles_controller.g.dart';

/// Controller for managing user roles list.
@Riverpod(keepAlive: true)
class UserRolesController extends _$UserRolesController {
  UserRoleRepository get _repository => ref.read(userRoleRepositoryProvider);

  @override
  Future<List<UserRole>> build() async {
    final result = await _repository.fetchAll();
    return result.fold((failure) => throw failure, (roles) => roles);
  }

  /// Refreshes the roles list.
  Future<void> refresh() async {
    _repository.invalidateCache();
    // Avoid wiping previous data so list UIs (and search inputs) stay mounted.
    if (!state.hasValue) {
      state = const AsyncValue.loading();
    }

    final result = await _repository.fetchAll();
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (roles) => AsyncData(roles),
    );
  }

  /// Creates a new role.
  Future<bool> createRole(UserRole role) async {
    final result = await _repository.create(role);
    return result.fold((failure) => false, (newRole) {
      state.whenData((currentList) {
        state = AsyncValue.data([...currentList, newRole]);
      });
      return true;
    });
  }

  /// Updates an existing role.
  Future<bool> updateRole(UserRole role) async {
    final result = await _repository.update(role);
    return result.fold((failure) => false, (updated) {
      state.whenData((currentList) {
        final updatedList = currentList.map((r) {
          return r.id == updated.id ? updated : r;
        }).toList();
        state = AsyncValue.data(updatedList);
      });
      return true;
    });
  }

  /// Deletes a role.
  Future<bool> deleteRole(String id) async {
    final result = await _repository.delete(id);
    return result.fold((failure) => false, (_) {
      state.whenData((currentList) {
        final updatedList = currentList.where((r) => r.id != id).toList();
        state = AsyncValue.data(updatedList);
      });
      return true;
    });
  }
}
