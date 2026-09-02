import '../domain/organization.dart';
import '../domain/organization_dns_status.dart';

/// A single checklist row for org setup (mirrors server complete-setup checks).
class OrganizationSetupCheck {
  const OrganizationSetupCheck({
    required this.key,
    required this.label,
    required this.passed,
    this.detail,
  });

  final String key;
  final String label;
  final bool passed;
  final String? detail;
}

/// Pure client-side setup checklist for wizard step indicators.
///
/// Server validation on complete-setup endpoint is authoritative.
class OrganizationSetupChecks {
  const OrganizationSetupChecks._();

  static List<OrganizationSetupCheck> evaluate({
    required Organization organization,
    required bool hasBranch,
    required bool hasAdminUser,
    String? adminUserDetail,
  }) {
    final dnsOk =
        organization.dnsStatus == OrganizationDnsStatus.created ||
        organization.dnsStatus == OrganizationDnsStatus.pending;

    return [
      OrganizationSetupCheck(
        key: 'dns',
        label: 'DNS provisioning',
        passed: dnsOk,
        detail: dnsOk
            ? organization.dnsStatus.label
            : organization.dnsError ?? organization.dnsStatus.label,
      ),
      OrganizationSetupCheck(
        key: 'branch',
        label: 'At least one branch',
        passed: hasBranch,
        detail: hasBranch ? null : 'Create a branch for this organization',
      ),
      OrganizationSetupCheck(
        key: 'adminUser',
        label: 'Org admin user with email and branch',
        passed: hasAdminUser,
        detail: hasAdminUser
            ? adminUserDetail
            : 'Create an admin user with email and default branch',
      ),
      OrganizationSetupCheck(
        key: 'setupStatus',
        label: 'Setup marked complete',
        passed: organization.setupStatus.isReady,
        detail: organization.setupStatus.isReady
            ? null
            : 'Complete the wizard review step',
      ),
    ];
  }

  static bool canMarkComplete({
    required Organization organization,
    required bool hasBranch,
    required bool hasAdminUser,
  }) {
    final dnsOk =
        organization.dnsStatus == OrganizationDnsStatus.created ||
        organization.dnsStatus == OrganizationDnsStatus.pending;
    return dnsOk && hasBranch && hasAdminUser;
  }
}

/// Platform dashboard aggregate counts from a tenant list.
class PlatformDashboardSummary {
  const PlatformDashboardSummary({
    required this.total,
    required this.pendingSetup,
    required this.dnsIssues,
    required this.ready,
  });

  final int total;
  final int pendingSetup;
  final int dnsIssues;
  final int ready;

  factory PlatformDashboardSummary.fromOrganizations(List<Organization> orgs) {
    var pending = 0;
    var dnsIssues = 0;
    var ready = 0;
    for (final org in orgs) {
      if (org.setupStatus.isReady) {
        ready++;
      } else {
        pending++;
      }
      if (org.dnsStatus == OrganizationDnsStatus.failed) {
        dnsIssues++;
      }
    }
    return PlatformDashboardSummary(
      total: orgs.length,
      pendingSetup: pending,
      dnsIssues: dnsIssues,
      ready: ready,
    );
  }
}
