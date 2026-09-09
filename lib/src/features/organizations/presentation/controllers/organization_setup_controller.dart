import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../settings/presentation/controllers/branches_controller.dart';
import '../../../users/data/repositories/user_repository.dart';
import '../../../users/domain/user.dart';
import '../../../users/domain/user_role.dart';
import '../../../users/presentation/controllers/user_roles_controller.dart';
import '../../data/repositories/organization_repository.dart';
import '../../domain/organization.dart';
import '../../domain/organization_setup_checks.dart';
import '../controllers/current_organization_controller.dart';
import '../controllers/organizations_controller.dart';

part 'organization_setup_controller.g.dart';

/// Setup progress for a single organization onboarding wizard.
class OrganizationSetupState {
  const OrganizationSetupState({
    required this.organization,
    this.hasBranch = false,
    this.hasAdminUser = false,
    this.adminUserEmail,
    this.createdBranchId,
    this.skippedMembership = false,
    this.skippedProduct = false,
    this.membershipCreated = false,
    this.productCreated = false,
  });

  final Organization organization;
  final bool hasBranch;
  final bool hasAdminUser;
  final String? adminUserEmail;
  final String? createdBranchId;
  final bool skippedMembership;
  final bool skippedProduct;
  final bool membershipCreated;
  final bool productCreated;

  List<OrganizationSetupCheck> get checks => OrganizationSetupChecks.evaluate(
    organization: organization,
    hasBranch: hasBranch,
    hasAdminUser: hasAdminUser,
    adminUserDetail: adminUserEmail,
  );

  bool get canComplete => OrganizationSetupChecks.canMarkComplete(
    organization: organization,
    hasBranch: hasBranch,
    hasAdminUser: hasAdminUser,
  );

  OrganizationSetupState copyWith({
    Organization? organization,
    bool? hasBranch,
    bool? hasAdminUser,
    String? adminUserEmail,
    String? createdBranchId,
    bool? skippedMembership,
    bool? skippedProduct,
    bool? membershipCreated,
    bool? productCreated,
  }) {
    return OrganizationSetupState(
      organization: organization ?? this.organization,
      hasBranch: hasBranch ?? this.hasBranch,
      hasAdminUser: hasAdminUser ?? this.hasAdminUser,
      adminUserEmail: adminUserEmail ?? this.adminUserEmail,
      createdBranchId: createdBranchId ?? this.createdBranchId,
      skippedMembership: skippedMembership ?? this.skippedMembership,
      skippedProduct: skippedProduct ?? this.skippedProduct,
      membershipCreated: membershipCreated ?? this.membershipCreated,
      productCreated: productCreated ?? this.productCreated,
    );
  }
}

@Riverpod(keepAlive: true)
class OrganizationSetupController extends _$OrganizationSetupController {
  OrganizationRepository get _orgRepository =>
      ref.read(organizationRepositoryProvider);

  UserRepository get _userRepository => ref.read(userRepositoryProvider);

  @override
  Future<OrganizationSetupState> build(String orgId) async {
    final orgResult = await _orgRepository.fetchOne(orgId);
    final organization = orgResult.fold(
      (failure) => throw failure,
      (org) => org,
    );

    // Enter tenant context once if needed. Calling switchOrganization on every
    // rebuild re-PATCHes users + refreshes auth, which re-triggers GoRouter.
    final currentOrgId = ref.read(currentOrganizationIdProvider);
    if (currentOrgId != orgId) {
      await ref
          .read(currentOrganizationControllerProvider.notifier)
          .switchOrganization(orgId);
    }

    final branches = await ref.read(branchesControllerProvider.future);
    final hasBranch = branches.isNotEmpty;
    final branchId = hasBranch ? branches.first.id : null;

    final admin = await _findOrgAdmin(orgId);
    return OrganizationSetupState(
      organization: organization,
      hasBranch: hasBranch,
      hasAdminUser: admin != null,
      adminUserEmail: admin?.email,
      createdBranchId: branchId,
    );
  }

  Future<User?> _findOrgAdmin(String orgId) async {
    final filter = 'organization = "$orgId"';
    final result = await _userRepository.fetchAll(filter: filter);
    return result.fold((_) => null, (users) {
      for (final user in users) {
        if ((user.email ?? '').isEmpty) continue;
        if (user.branchId == null || user.branchId!.isEmpty) continue;
        // Role name check is best-effort; server validates system.admin.
        if (user.roleName?.toLowerCase().contains('admin') ?? false) {
          return user;
        }
      }
      return null;
    });
  }

  Future<UserRole?> adminRole() async {
    final roles = await ref.read(userRolesControllerProvider.future);
    for (final role in roles) {
      if (role.isAdmin) return role;
    }
    return roles.isNotEmpty ? roles.first : null;
  }

  Future<bool> refreshOrganization() async {
    final current = state.value;
    if (current == null) return false;

    final result = await _orgRepository.fetchOne(current.organization.id);
    return result.fold((_) => false, (org) {
      state = AsyncData(current.copyWith(organization: org));
      return true;
    });
  }

  Future<bool> updateOrganization(Organization organization) async {
    final success = await ref
        .read(organizationsControllerProvider.notifier)
        .updateOrganization(organization);
    if (!success) return false;
    await refreshOrganization();
    return true;
  }

  Future<bool> completeSetup() async {
    final current = state.value;
    if (current == null || !current.canComplete) return false;

    final result =
        await _orgRepository.completeSetup(current.organization.id);
    return result.fold((_) => false, (org) {
      state = AsyncData(current.copyWith(organization: org));
      ref.invalidate(organizationsControllerProvider);
      return true;
    });
  }

  Future<void> refreshProgress() async {
    final current = state.value;
    if (current == null) return;

    final branches = await ref.read(branchesControllerProvider.future);
    final admin = await _findOrgAdmin(current.organization.id);
    state = AsyncData(
      current.copyWith(
        hasBranch: branches.isNotEmpty,
        createdBranchId: branches.isNotEmpty ? branches.first.id : null,
        hasAdminUser: admin != null,
        adminUserEmail: admin?.email,
      ),
    );
  }

  void markMembershipSkipped() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(skippedMembership: true));
  }

  void markProductSkipped() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(skippedProduct: true));
  }

  void markMembershipCreated() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(membershipCreated: true, skippedMembership: false),
    );
  }

  void markProductCreated() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(productCreated: true, skippedProduct: false),
    );
  }
}
