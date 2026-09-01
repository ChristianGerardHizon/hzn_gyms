import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/storage/secure_storage_provider.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/repositories/organization_repository.dart';
import '../../domain/organization.dart';

part 'current_organization_controller.g.dart';

/// Storage key for persisting the selected organization (non-web fallback).
const _currentOrganizationStorageKey = 'CURRENT_ORGANIZATION_ID';

/// Controller for resolving/switching the current organization.
///
/// Resolution order:
/// 1. Web: `Uri.base.host` matched against an organization's `subdomain`/
///    `slug` — wins whenever it matches, even before the user is signed in,
///    so login/branding can render for the right org immediately.
/// 2. The signed-in user's `organization` field.
/// 3. A persisted choice in secure storage (native/desktop, or local dev
///    where the hostname won't match any subdomain).
@Riverpod(keepAlive: true)
class CurrentOrganizationController extends _$CurrentOrganizationController {
  OrganizationRepository get _repository =>
      ref.read(organizationRepositoryProvider);

  @override
  Future<Organization?> build() async {
    final byHostname = await _resolveByHostname();
    if (byHostname != null) return byHostname;

    final auth = ref.watch(currentAuthProvider);
    final orgId = auth?.user.organization;
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
  Future<void> switchOrganization(String organizationId) async {
    state = const AsyncLoading<Organization?>();
    await _persistOrganizationId(organizationId);
    final org = await _fetchOrganization(organizationId);
    state = AsyncData(org);
  }

  Future<Organization?> _resolveByHostname() async {
    if (!kIsWeb) return null;

    final host = Uri.base.host;
    if (host.isEmpty) return null;

    final result = await _repository.fetchBySlugOrHostname(host);
    return result.fold((_) => null, (org) => org);
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
@Riverpod(keepAlive: true)
String? currentOrganizationId(Ref ref) {
  return ref.watch(currentOrganizationControllerProvider).value?.id;
}

/// Convenience provider for an organization-scoped filter string.
///
/// Returns `organization = "id" && isDeleted = false`, or null while
/// unresolved.
@Riverpod(keepAlive: true)
String? currentOrganizationFilter(Ref ref) {
  final orgId = ref.watch(currentOrganizationIdProvider);
  if (orgId == null || orgId.isEmpty) return null;
  return PBFilters.forOrganization(orgId).build();
}
