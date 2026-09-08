import 'package:hzn_gyms/src/features/organizations/domain/organization_membership.dart';
import 'package:hzn_gyms/src/features/organizations/presentation/controllers/organization_memberships_controller.dart';

/// Test helper: fixed memberships list (avoids PocketBase in widget/router tests).
class FakeOrganizationMembershipsController
    extends OrganizationMembershipsController {
  FakeOrganizationMembershipsController([this._rows = const []]);

  final List<OrganizationMembership> _rows;

  @override
  Future<List<OrganizationMembership>> build() async => _rows;
}
