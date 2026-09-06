import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hzn_gyms/src/features/organizations/domain/organization.dart';
import 'package:hzn_gyms/src/features/organizations/domain/organization_dns_status.dart';
import 'package:hzn_gyms/src/features/organizations/domain/organization_setup_status.dart';
import 'package:hzn_gyms/src/features/organizations/presentation/controllers/organizations_controller.dart';
import 'package:hzn_gyms/src/features/organizations/presentation/controllers/platform_dashboard_controller.dart';

void main() {
  final orgs = [
    Organization(
      id: '1',
      name: 'Ready Gym',
      slug: 'ready',
      setupStatus: OrganizationSetupStatus.ready,
      dnsStatus: OrganizationDnsStatus.created,
      created: DateTime(2026, 1, 3),
    ),
    Organization(
      id: '2',
      name: 'Pending Gym',
      slug: 'pending',
      setupStatus: OrganizationSetupStatus.pendingSetup,
      dnsStatus: OrganizationDnsStatus.failed,
      created: DateTime(2026, 1, 2),
    ),
    Organization(
      id: '3',
      name: 'Newest Gym',
      slug: 'newest',
      setupStatus: OrganizationSetupStatus.pendingSetup,
      dnsStatus: OrganizationDnsStatus.pending,
      created: DateTime(2026, 1, 4),
    ),
  ];

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        organizationsControllerProvider.overrideWith(
          () => _FixedOrganizations(orgs),
        ),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('platformDashboardSummary aggregates tenant metrics', () async {
    final summary = await container.read(platformDashboardSummaryProvider.future);

    expect(summary.total, 3);
    expect(summary.ready, 1);
    expect(summary.pendingSetup, 2);
    expect(summary.dnsIssues, 1);
  });

  test('platformRecentOrganizations returns newest five sorted by created', () async {
    final recent =
        await container.read(platformRecentOrganizationsProvider.future);

    expect(recent.map((o) => o.id), ['3', '1', '2']);
  });
}

class _FixedOrganizations extends OrganizationsController {
  _FixedOrganizations(this._orgs);

  final List<Organization> _orgs;

  @override
  Future<List<Organization>> build() async => _orgs;
}
