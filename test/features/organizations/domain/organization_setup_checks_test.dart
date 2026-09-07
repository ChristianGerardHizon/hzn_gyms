import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/features/organizations/domain/organization.dart';
import 'package:hzn_gyms/src/features/organizations/domain/organization_setup_checks.dart';
import 'package:hzn_gyms/src/features/organizations/domain/organization_setup_status.dart';

void main() {
  const org = Organization(
    id: 'org-1',
    name: 'Kylie Gym',
    slug: 'kyliegym',
    setupStatus: OrganizationSetupStatus.pendingSetup,
  );

  group('OrganizationSetupChecks.evaluate', () {
    test('passes when branch and admin user are satisfied', () {
      final checks = OrganizationSetupChecks.evaluate(
        organization: org,
        hasBranch: true,
        hasAdminUser: true,
        adminUserDetail: 'admin@example.com',
      );

      expect(checks.where((c) => !c.passed).map((c) => c.key), ['setupStatus']);
      expect(checks.any((c) => c.key == 'dns'), isFalse);
    });

    test('fails without branch', () {
      final checks = OrganizationSetupChecks.evaluate(
        organization: org,
        hasBranch: false,
        hasAdminUser: true,
      );

      final branch = checks.firstWhere((c) => c.key == 'branch');
      expect(branch.passed, isFalse);
    });

    test('fails without admin user', () {
      final checks = OrganizationSetupChecks.evaluate(
        organization: org,
        hasBranch: true,
        hasAdminUser: false,
      );

      final admin = checks.firstWhere((c) => c.key == 'adminUser');
      expect(admin.passed, isFalse);
    });
  });

  group('OrganizationSetupChecks.canMarkComplete', () {
    test('returns true when prerequisites met', () {
      expect(
        OrganizationSetupChecks.canMarkComplete(
          organization: org,
          hasBranch: true,
          hasAdminUser: true,
        ),
        isTrue,
      );
    });

    test('returns false without admin user', () {
      expect(
        OrganizationSetupChecks.canMarkComplete(
          organization: org,
          hasBranch: true,
          hasAdminUser: false,
        ),
        isFalse,
      );
    });

    test('returns false without branch', () {
      expect(
        OrganizationSetupChecks.canMarkComplete(
          organization: org,
          hasBranch: false,
          hasAdminUser: true,
        ),
        isFalse,
      );
    });
  });

  group('PlatformDashboardSummary', () {
    test('counts ready and pending setup', () {
      final summary = PlatformDashboardSummary.fromOrganizations([
        const Organization(
          id: '1',
          name: 'A',
          slug: 'a',
          setupStatus: OrganizationSetupStatus.ready,
        ),
        const Organization(
          id: '2',
          name: 'B',
          slug: 'b',
          setupStatus: OrganizationSetupStatus.pendingSetup,
        ),
        const Organization(
          id: '3',
          name: 'C',
          slug: 'c',
          setupStatus: OrganizationSetupStatus.pendingSetup,
        ),
      ]);

      expect(summary.total, 3);
      expect(summary.ready, 1);
      expect(summary.pendingSetup, 2);
    });
  });
}
