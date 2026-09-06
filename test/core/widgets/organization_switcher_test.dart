import 'package:hzn_gyms/src/core/i18n/strings.g.dart';
import 'package:hzn_gyms/src/core/permissions/current_user_permissions.dart';
import 'package:hzn_gyms/src/core/widgets/cached_avatar.dart';
import 'package:hzn_gyms/src/core/widgets/organization_switcher.dart';
import 'package:hzn_gyms/src/features/auth/domain/auth_state.dart';
import 'package:hzn_gyms/src/features/auth/domain/user.dart';
import 'package:hzn_gyms/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:hzn_gyms/src/features/organizations/domain/organization.dart';import 'package:hzn_gyms/src/features/organizations/presentation/controllers/current_organization_controller.dart';
import 'package:hzn_gyms/src/features/organizations/presentation/controllers/organizations_controller.dart';
import 'package:hzn_gyms/src/features/users/domain/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const orgA = Organization(id: 'org-a', name: 'Org A', slug: 'org-a');
  const orgB = Organization(id: 'org-b', name: 'Org B', slug: 'org-b');
  const orgWithLogo = Organization(
    id: 'org-logo',
    name: 'Kylie Gym',
    slug: 'kyliegym',
    logoTransparentUrl: 'https://example.com/logo.png',
  );
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

  testWidgets('hidden for org-scoped admin with organizations.manage', (
    tester,
  ) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: ProviderScope(
          overrides: [
            currentAuthProvider.overrideWithValue(
              const AuthState(
                token: 'tok',
                user: User(
                  id: 'org-admin',
                  name: 'Org Admin',
                  username: 'orgadmin',
                  verified: true,
                  organization: 'org-a',
                ),
              ),
            ),
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

    expect(find.byType(DropdownButton<String>), findsNothing);
  });

  testWidgets('shows dropdown when user can manage organizations', (    tester,
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

  testWidgets('shows organization logo when logoTransparentUrl is set', (
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
              () => _FakeOrganizationsController(const [orgWithLogo, orgB]),
            ),
            currentOrganizationControllerProvider.overrideWith(
              () => _FakeCurrentOrganizationController(orgWithLogo),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: OrganizationSwitcher(compact: true)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CachedAvatar), findsWidgets);
    expect(find.text('Kylie Gym'), findsOneWidget);
  });

  testWidgets('compact mode lays out in AppBar actions without overflow', (    tester,
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
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                actions: const [OrganizationSwitcher(compact: true)],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(DropdownButton<String>), findsOneWidget);
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
