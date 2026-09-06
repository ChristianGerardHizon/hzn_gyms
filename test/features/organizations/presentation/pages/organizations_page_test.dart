import 'package:hzn_gyms/src/core/i18n/strings.g.dart';
import 'package:hzn_gyms/src/features/organizations/domain/organization.dart';
import 'package:hzn_gyms/src/features/organizations/domain/organization_dns_status.dart';
import 'package:hzn_gyms/src/features/organizations/presentation/controllers/organizations_controller.dart';
import 'package:hzn_gyms/src/features/organizations/presentation/pages/organizations_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const org = Organization(
    id: 'org-1',
    name: 'Kylie Gym',
    slug: 'kyliegym',
    subdomain: 'kyliegym.gyms.hznsystems.com',
    dnsStatus: OrganizationDnsStatus.failed,
    dnsError: 'DNS timeout',
  );

  testWidgets('shows organization list with DNS badge', (tester) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: ProviderScope(
          overrides: [
            organizationsControllerProvider.overrideWith(
              () => _FakeOrganizationsController(const [org]),
            ),
          ],
          child: const MaterialApp(home: OrganizationsPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kylie Gym'), findsOneWidget);
    expect(find.text('Slug: kyliegym'), findsOneWidget);
    expect(find.text('Failed'), findsOneWidget);
    expect(find.text('DNS timeout'), findsOneWidget);
    expect(find.text('Retry DNS'), findsOneWidget);
  });
}

class _FakeOrganizationsController extends OrganizationsController {
  _FakeOrganizationsController(this._organizations);

  final List<Organization> _organizations;

  @override
  Future<List<Organization>> build() async => _organizations;

  @override
  Future<bool> retryDnsProvisioning(String id) async => true;
}
