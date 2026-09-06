import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/features/organizations/domain/organization.dart';
import 'package:hzn_gyms/src/features/organizations/domain/organization_dns_status.dart';
import 'package:hzn_gyms/src/features/organizations/domain/organization_setup_checks.dart';
import 'package:hzn_gyms/src/features/organizations/domain/organization_setup_status.dart';

void main() {
  const org = Organization(
    id: 'org-1',
    name: 'Kylie Gym',
    slug: 'kyliegym',
    dnsStatus: OrganizationDnsStatus.created,
    setupStatus: OrganizationSetupStatus.pendingSetup,
  );

  group('OrganizationSetupChecks.evaluate', () {
    test('passes when DNS, branch, and admin user are satisfied', () {
      final checks = OrganizationSetupChecks.evaluate(
        organization: org,
        hasBranch: true,
        hasAdminUser: true,
        adminUserDetail: 'admin@example.com',
      );

      expect(checks.where((c) => !c.passed).map((c) => c.key), ['setupStatus']);
    });

    test('fails DNS when status is failed', () {
      const failedDns = Organization(
        id: 'org-1',
        name: 'Kylie Gym',
        slug: 'kyliegym',
        dnsStatus: OrganizationDnsStatus.failed,
        dnsError: 'Porkbun timeout',
      );

      final checks = OrganizationSetupChecks.evaluate(
        organization: failedDns,
        hasBranch: true,
        hasAdminUser: true,
      );

      final dns = checks.firstWhere((c) => c.key == 'dns');
      expect(dns.passed, isFalse);
      expect(dns.detail, 'Porkbun timeout');
    });

    test('treats pending DNS as acceptable', () {
      const pendingDns = Organization(
        id: 'org-1',
        name: 'Kylie Gym',
        slug: 'kyliegym',
        dnsStatus: OrganizationDnsStatus.pending,
      );

      final checks = OrganizationSetupChecks.evaluate(
        organization: pendingDns,
        hasBranch: false,
        hasAdminUser: false,
      );

      expect(checks.firstWhere((c) => c.key == 'dns').passed, isTrue);
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
  });

  group('PlatformDashboardSummary', () {
    test('counts ready, pending, and DNS issues', () {
      final summary = PlatformDashboardSummary.fromOrganizations([
        const Organization(
          id: '1',
          name: 'A',
          slug: 'a',
          setupStatus: OrganizationSetupStatus.ready,
          dnsStatus: OrganizationDnsStatus.created,
        ),
        const Organization(
          id: '2',
          name: 'B',
          slug: 'b',
          setupStatus: OrganizationSetupStatus.pendingSetup,
          dnsStatus: OrganizationDnsStatus.failed,
        ),
        const Organization(
          id: '3',
          name: 'C',
          slug: 'c',
          setupStatus: OrganizationSetupStatus.pendingSetup,
          dnsStatus: OrganizationDnsStatus.pending,
        ),
      ]);

      expect(summary.total, 3);
      expect(summary.ready, 1);
      expect(summary.pendingSetup, 2);
      expect(summary.dnsIssues, 1);
    });
  });
}
