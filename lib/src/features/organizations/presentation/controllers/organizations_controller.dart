import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/organization_repository.dart';
import '../../domain/organization.dart';
import '../../domain/organization_logo_draft.dart';
import '../controllers/current_organization_controller.dart';

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

  /// Updates an existing organization.
  Future<bool> updateOrganization(
    Organization organization, {
    OrganizationLogoDraft? logoDraft,
  }) async {
    final result = await _repository.update(organization);

    return result.fold(
      (failure) => Future.value(false),
      (updated) async {
        final withLogo = await _applyLogoDraft(
          updated.id,
          logoDraft,
          fallback: updated,
        );
        if (withLogo == null) return false;

        _replaceInList(withLogo);
        _refreshCurrentOrganizationIfNeeded(withLogo.id);
        return true;
      },
    );
  }

  /// Creates a new organization.
  Future<Organization?> createOrganization(
    Organization organization, {
    OrganizationLogoDraft? logoDraft,
  }) async {
    final result = await _repository.create(organization);

    return result.fold(
      (failure) => Future.value(null),
      (created) async {
        final withLogo = await _applyLogoDraft(
          created.id,
          logoDraft,
          fallback: created,
        );
        final saved = withLogo ?? created;
        final currentList = state.value ?? [];
        state = AsyncData([saved, ...currentList]);
        return saved;
      },
    );
  }

  Future<Organization?> _applyLogoDraft(
    String organizationId,
    OrganizationLogoDraft? logoDraft, {
    required Organization fallback,
  }) async {
    if (logoDraft == null || !logoDraft.hasChanges) {
      return fallback;
    }

    if (logoDraft.removeExisting) {
      final result = await _repository.updateLogo(
        organizationId,
        removeLogoTransparent: true,
      );
      return result.fold((_) => null, (org) => org);
    }

    final file = buildOrganizationLogoMultipart(logoDraft);
    if (file == null) return fallback;

    final result = await _repository.updateLogo(
      organizationId,
      logoTransparent: file,
    );
    return result.fold((_) => null, (org) => org);
  }

  void _replaceInList(Organization updated) {
    final currentList = state.value ?? [];
    final updatedList = currentList.map((org) {
      return org.id == updated.id ? updated : org;
    }).toList();
    state = AsyncData(updatedList);
  }

  void _refreshCurrentOrganizationIfNeeded(String organizationId) {
    final currentId = ref.read(currentOrganizationControllerProvider).value?.id;
    if (currentId == organizationId) {
      ref.invalidate(currentOrganizationControllerProvider);
    }
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
}
