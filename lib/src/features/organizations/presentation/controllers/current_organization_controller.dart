import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/packages/storage/secure_storage_provider.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../members/data/local/member_local_data_source.dart';
import '../../data/repositories/organization_membership_repository.dart';
import '../../data/repositories/organization_repository.dart';
import '../../domain/organization.dart';
import 'organization_memberships_controller.dart';
import 'tenant_scope_invalidation.dart';

part 'current_organization_controller.g.dart';

/// Storage key for persisting the selected organization (non-web fallback).
const _currentOrganizationStorageKey = 'CURRENT_ORGANIZATION_ID';

/// Controller for resolving/switching the current organization.
///
/// Login is organization-agnostic — no tenant is resolved from the URL/hostname
/// before sign-in. After authentication, resolution order is:
/// 1. The signed-in user's `organization` field.
/// 2. A persisted choice in secure storage (super-admin org switcher).
@Riverpod(keepAlive: true)
class CurrentOrganizationController extends _$CurrentOrganizationController {
  OrganizationRepository get _repository =>
      ref.read(organizationRepositoryProvider);

  @override
  Future<Organization?> build() async {
    final auth = ref.watch(currentAuthProvider);
    if (auth == null) return null;

    final orgId = auth.user.organization;
    if (orgId != null && orgId.isNotEmpty) {
      final org = await _fetchOrganization(orgId);
      if (org != null) return org;
    }

    final persistedId = await _loadPersistedOrganizationId();
    if (persistedId != null && persistedId.isNotEmpty) {
      return _fetchOrganization(persistedId);
    }

    return null;
  }

  /// Switches to a different organization (super-admin only in the UI).
  ///
  /// Persists the choice, syncs `users.organization` so PocketBase rules and
  /// `@request.auth.organization` match, resets branch, clears member cache,
  /// and invalidates tenant-scoped list providers.
  Future<void> switchOrganization(String organizationId) async {
    final auth = ref.read(currentAuthProvider);
    // No-op when already in this tenant — avoids auth refresh / router churn.
    if (auth?.user.organization == organizationId &&
        state.value?.id == organizationId) {
      return;
    }

    state = const AsyncLoading<Organization?>();
    await _persistOrganizationId(organizationId);

    if (auth != null) {
      final pb = ref.read(pocketbaseProvider);
      final body = <String, dynamic>{'organization': organizationId};

      // Non-platform users switch role with the tenant membership.
      if (!auth.user.superAdmin) {
        final membershipResult = await ref
            .read(organizationMembershipRepositoryProvider)
            .fetchForUserInOrganization(
              userId: auth.user.id,
              organizationId: organizationId,
            );
        membershipResult.fold((_) {}, (membership) {
          if (membership != null && membership.roleId.isNotEmpty) {
            body['role'] = membership.roleId;
          }
        });
      }

      // Skip the users PATCH when auth is already linked to this org.
      if (auth.user.organization != organizationId) {
        await pb.collection(PocketBaseCollections.users).update(
          auth.user.id,
          body: body,
        );
        await ref.read(authControllerProvider.notifier).refresh();
      }
    }

    final org = await _fetchOrganization(organizationId);
    state = AsyncData(org);

    try {
      await ref.read(memberLocalDataSourceProvider).clearSynced();
    } catch (_) {
      // Local DB may be unavailable (tests); continue switch.
    }

    invalidateTenantScopedProviders(ref);
    ref.invalidate(organizationMembershipsControllerProvider);
  }

  Future<Organization?> _fetchOrganization(String id) async {
    final result = await _repository.fetchOne(id);
    return result.fold((_) => null, (org) => org);
  }

  Future<String?> _loadPersistedOrganizationId() async {
    final storage = ref.read(secureStorageProvider);
    return storage.read(key: _currentOrganizationStorageKey);
  }

  Future<void> _persistOrganizationId(String organizationId) async {
    final storage = ref.read(secureStorageProvider);
    await storage.write(
      key: _currentOrganizationStorageKey,
      value: organizationId,
    );
  }
}

/// Convenience provider for the current organization ID, or null if
/// unresolved.
///
/// Prefers the resolved [currentOrganizationControllerProvider] record, then
/// falls back to `auth.user.organization` so tenant-scoped lists (e.g. branches)
/// still work if the organization row cannot be fetched briefly.
@Riverpod(keepAlive: true)
String? currentOrganizationId(Ref ref) {
  final fromController =
      ref.watch(currentOrganizationControllerProvider).value?.id;
  if (fromController != null && fromController.isNotEmpty) {
    return fromController;
  }
  final fromAuth = ref.watch(currentAuthProvider)?.user.organization;
  if (fromAuth != null && fromAuth.isNotEmpty) return fromAuth;
  return null;
}

/// Convenience provider for an organization-scoped filter string.
///
/// Returns `organization = "id" && isDeleted = false`, or null while
/// unresolved. Use for collections that own an `organization` field.
@Riverpod(keepAlive: true)
String? currentOrganizationFilter(Ref ref) {
  final orgId = ref.watch(currentOrganizationIdProvider);
  if (orgId == null || orgId.isEmpty) return null;
  return PBFilters.forOrganization(orgId).build();
}

/// Filter for gym rows scoped via `branch.organization`.
///
/// Returns `branch.organization = "id" && isDeleted = false`, or null while
/// unresolved.
@Riverpod(keepAlive: true)
String? currentBranchOrganizationFilter(Ref ref) {
  final orgId = ref.watch(currentOrganizationIdProvider);
  if (orgId == null || orgId.isEmpty) return null;
  return PBFilters.forBranchOrganization(orgId).build();
}
