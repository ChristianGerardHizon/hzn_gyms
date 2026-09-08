import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/features/organizations/domain/organization_membership.dart';

void main() {
  test('OrganizationMembershipStatus parses wire values', () {
    expect(
      OrganizationMembershipStatus.fromString('active'),
      OrganizationMembershipStatus.active,
    );
    expect(
      OrganizationMembershipStatus.fromString('suspended'),
      OrganizationMembershipStatus.suspended,
    );
    expect(
      OrganizationMembershipStatus.fromString(null),
      OrganizationMembershipStatus.active,
    );
  });

  test('isActive follows status', () {
    const active = OrganizationMembership(
      id: '1',
      userId: 'u',
      organizationId: 'o',
      roleId: 'r',
    );
    const suspended = OrganizationMembership(
      id: '2',
      userId: 'u',
      organizationId: 'o',
      roleId: 'r',
      status: OrganizationMembershipStatus.suspended,
    );
    expect(active.isActive, isTrue);
    expect(suspended.isActive, isFalse);
  });
}
