import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/organization_repository.dart';
import '../../domain/organization.dart';

part 'organizations_controller.g.dart';

/// Controller for super-admin organization list and CRUD.
@Riverpod(keepAlive: true)
class OrganizationsController extends _$OrganizationsController {
  OrganizationRepository get _repository =>
      ref.read(organizationRepositoryProvider);

  @override
  Future<List<Organization>> build() async {
    final result = await _repository.fetchAll();
    return result.fold(
      (failure) => throw failure,
      (organizations) => organizations,
    );
  }

  /// Refreshes the organization list.
  Future<void> refresh() async {
    if (!state.hasValue) {
      state = const AsyncLoading();
    }

    final result = await _repository.fetchAll();
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (organizations) => AsyncData(organizations),
    );
  }

  /// Creates a new organization.
  Future<bool> createOrganization(Organization organization) async {
    final result = await _repository.create(organization);

    return result.fold(
      (failure) => false,
      (created) {
        final currentList = state.value ?? [];
        state = AsyncData([created, ...currentList]);
        return true;
      },
    );
  }

  /// Updates an existing organization.
  Future<bool> updateOrganization(Organization organization) async {
    final result = await _repository.update(organization);

    return result.fold(
      (failure) => false,
      (updated) {
        final currentList = state.value ?? [];
        final updatedList = currentList.map((org) {
          return org.id == updated.id ? updated : org;
        }).toList();
        state = AsyncData(updatedList);
        return true;
      },
    );
  }

  /// Soft-deletes an organization.
  Future<bool> deleteOrganization(String id) async {
    final result = await _repository.delete(id);

    return result.fold(
      (failure) => false,
      (_) {
        final currentList = state.value ?? [];
        final updatedList = currentList.where((org) => org.id != id).toList();
        state = AsyncData(updatedList);
        return true;
      },
    );
  }

  /// Re-triggers DNS provisioning and updates the list entry.
  Future<bool> retryDnsProvisioning(String id) async {
    final result = await _repository.retryDnsProvisioning(id);

    return result.fold(
      (failure) => false,
      (updated) {
        final currentList = state.value ?? [];
        final updatedList = currentList.map((org) {
          return org.id == updated.id ? updated : org;
        }).toList();
        state = AsyncData(updatedList);
        return true;
      },
    );
  }
}
