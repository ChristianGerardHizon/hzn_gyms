import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/repositories/organization_membership_repository.dart';
import '../../domain/organization_membership.dart';
import 'current_organization_controller.dart';

part 'organization_memberships_controller.g.dart';

/// Active organization memberships for the signed-in user.
@Riverpod(keepAlive: true)
class OrganizationMembershipsController
    extends _$OrganizationMembershipsController {
  @override
  Future<List<OrganizationMembership>> build() async {
    final auth = ref.watch(currentAuthProvider);
    if (auth == null) return const [];

    final result = await ref
        .read(organizationMembershipRepositoryProvider)
        .fetchActiveForUser(auth.user.id);

    return result.fold(
      (failure) {
        // Don't treat fetch failures as "no memberships" (that would wrongly
        // send users to the invite gate while offline).
        throw failure;
      },
      (rows) => rows,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// Active membership for the current organization, if any.
@Riverpod(keepAlive: true)
Future<OrganizationMembership?> currentOrganizationMembership(Ref ref) async {
  final auth = ref.watch(currentAuthProvider);
  final orgId = ref.watch(currentOrganizationIdProvider);
  if (auth == null || orgId == null || orgId.isEmpty) return null;

  final memberships = await ref.watch(
    organizationMembershipsControllerProvider.future,
  );
  for (final m in memberships) {
    if (m.organizationId == orgId && m.isActive) return m;
  }

  final result = await ref
      .read(organizationMembershipRepositoryProvider)
      .fetchForUserInOrganization(userId: auth.user.id, organizationId: orgId);
  return result.fold((_) => null, (m) => m);
}

/// Whether the signed-in user has at least one active org membership.
@Riverpod(keepAlive: true)
bool hasOrganizationMembership(Ref ref) {
  final async = ref.watch(organizationMembershipsControllerProvider);
  return async.maybeWhen(
    data: (rows) => rows.any((m) => m.isActive),
    orElse: () => false,
  );
}
