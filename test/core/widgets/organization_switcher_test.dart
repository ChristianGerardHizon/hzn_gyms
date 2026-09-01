import 'package:kylie_gym/src/core/i18n/strings.g.dart';
import 'package:kylie_gym/src/core/permissions/current_user_permissions.dart';
import 'package:kylie_gym/src/core/widgets/organization_switcher.dart';
import 'package:kylie_gym/src/features/organizations/domain/organization.dart';
import 'package:kylie_gym/src/features/organizations/presentation/controllers/current_organization_controller.dart';
import 'package:kylie_gym/src/features/organizations/presentation/controllers/organizations_controller.dart';
import 'package:kylie_gym/src/features/users/domain/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const orgA = Organization(id: 'org-a', name: 'Org A', slug: 'org-a');
  const orgB = Organization(id: 'org-b', name: 'Org B', slug: 'org-b');

  testWidgets('hidden without organizations.manage permission', (tester) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: ProviderScope(
          overrides: [
            currentUserPermissionsProvider.overrideWith(
              () => _FakePermissionsController(const CurrentUserPermissions()),
            ),
            organizationsControllerProvider.overrideWith(
              () => _FakeOrganizationsController(const [orgA, orgB]),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: OrganizationSwitcher(compact: true)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DropdownButton<String>), findsNothing);
    expect(find.byType(OrganizationSwitcher), findsOneWidget);
  });

  testWidgets('shows dropdown when user can manage organizations', (
    tester,
  ) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: ProviderScope(
          overrides: [
            currentUserPermissionsProvider.overrideWith(
              () => _FakePermissionsController(
                const CurrentUserPermissions(
                  permissions: {Permissions.organizationsManage},
                ),
              ),
            ),
            organizationsControllerProvider.overrideWith(
              () => _FakeOrganizationsController(const [orgA, orgB]),
            ),
            currentOrganizationControllerProvider.overrideWith(
              () => _FakeCurrentOrganizationController(orgA),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: OrganizationSwitcher(compact: true)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DropdownButton<String>), findsOneWidget);
    expect(find.text('Org A'), findsOneWidget);
  });
}

class _FakePermissionsController extends CurrentUserPermissionsController {
  _FakePermissionsController(this._permissions);

  final CurrentUserPermissions _permissions;

  @override
  Future<CurrentUserPermissions> build() async => _permissions;
}

class _FakeOrganizationsController extends OrganizationsController {
  _FakeOrganizationsController(this._organizations);

  final List<Organization> _organizations;

  @override
  Future<List<Organization>> build() async => _organizations;
}

class _FakeCurrentOrganizationController extends CurrentOrganizationController {
  _FakeCurrentOrganizationController(this._organization);

  final Organization _organization;

  @override
  Future<Organization?> build() async => _organization;
}
