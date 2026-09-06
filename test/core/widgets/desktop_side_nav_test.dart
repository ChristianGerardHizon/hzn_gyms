import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hzn_gyms/src/core/i18n/strings.g.dart';
import 'package:hzn_gyms/src/core/navigation/app_nav_destination.dart';
import 'package:hzn_gyms/src/core/permissions/current_user_permissions.dart';
import 'package:hzn_gyms/src/core/routing/routes/dashboard.routes.dart';
import 'package:hzn_gyms/src/core/routing/routes/members.routes.dart';
import 'package:hzn_gyms/src/core/routing/routes/memberships.routes.dart';
import 'package:hzn_gyms/src/core/sync/outbox_sync_worker.dart';
import 'package:hzn_gyms/src/core/widgets/desktop_side_nav.dart';
import 'package:hzn_gyms/src/features/organizations/domain/organization.dart';
import 'package:hzn_gyms/src/features/organizations/presentation/controllers/current_organization_controller.dart';
import 'package:hzn_gyms/src/features/users/domain/user_role.dart';

void main() {
  const org = Organization(id: 'org-1', name: 'Test Gym', slug: 'testgym');

  const adminPerms = CurrentUserPermissions(
    permissions: {
      Permissions.checkInsView,
      Permissions.salesView,
      Permissions.productsView,
      Permissions.membersView,
      Permissions.membershipsView,
      Permissions.reportsView,
      Permissions.usersView,
      Permissions.rolesView,
      Permissions.branchesView,
    },
    isAdmin: true,
  );

  const staffPerms = CurrentUserPermissions(
    permissions: {
      Permissions.membersView,
      Permissions.checkInsView,
    },
  );

  Widget buildHarness({
    required List<AppNavDestination> destinations,
    required CurrentUserPermissions permissions,
    String initialLocation = DashboardRoute.path,
  }) {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: DashboardRoute.path,
          builder: (context, state) => SizedBox(
            width: 1200,
            height: 1200,
            child: DesktopSideNav(
              destinations: destinations,
              onDestinationTap: (_) {},
            ),
          ),
        ),
        GoRoute(
          path: MembersRoute.path,
          builder: (context, state) => SizedBox(
            width: 1200,
            height: 1200,
            child: DesktopSideNav(
              destinations: destinations,
              onDestinationTap: (_) {},
            ),
          ),
        ),
        GoRoute(
          path: MembershipsRoute.path,
          builder: (context, state) => SizedBox(
            width: 1200,
            height: 1200,
            child: DesktopSideNav(
              destinations: destinations,
              onDestinationTap: (_) {},
            ),
          ),
        ),
      ],
    );

    return TranslationProvider(
      child: ProviderScope(
        overrides: [
          outboxPendingCountProvider.overrideWith((ref) => Stream.value(0)),
          currentUserPermissionsProvider.overrideWith(
            () => _FakePermissionsController(permissions),
          ),
          currentOrganizationControllerProvider.overrideWith(
            () => _FakeCurrentOrganizationController(org),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
  }

  testWidgets('renders dashboard, shortcuts, categories, and system for admin',
      (tester) async {
    final destinations = visibleAppNavDestinations(adminPerms);

    await tester.pumpWidget(
      buildHarness(
        destinations: destinations,
        permissions: adminPerms,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Shortcuts'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Check-In'), findsOneWidget);
    expect(find.text('Members'), findsOneWidget);
    expect(find.text('People'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
    expect(find.text('Users'), findsNothing);
    expect(
      destinations.any((destination) => destination.id == AppNavId.system),
      isTrue,
    );

    await tester.scrollUntilVisible(
      find.text('System'),
      48,
      scrollable: find.descendant(
        of: find.byType(DesktopSideNav),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('System'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Administration'),
      48,
      scrollable: find.descendant(
        of: find.byType(DesktopSideNav),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('Administration'), findsOneWidget);
  });

  testWidgets('hides admin-only categories for staff users', (tester) async {
    final destinations = visibleAppNavDestinations(staffPerms);

    await tester.pumpWidget(
      buildHarness(
        destinations: destinations,
        permissions: staffPerms,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Check-In'), findsOneWidget);
    expect(find.text('Members'), findsOneWidget);
    expect(find.text('Administration'), findsNothing);
    expect(find.text('Reports'), findsNothing);
  });

  testWidgets('collapse toggle hides section labels', (tester) async {
    final destinations = visibleAppNavDestinations(adminPerms);

    await tester.pumpWidget(
      buildHarness(
        destinations: destinations,
        permissions: adminPerms,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Shortcuts'), findsOneWidget);

    await tester.tap(find.byTooltip('Collapse navigation'));
    await tester.pumpAndSettle();

    expect(find.text('Shortcuts'), findsNothing);
    expect(find.text('Categories'), findsNothing);
    expect(find.byTooltip('Dashboard'), findsOneWidget);
  });

  testWidgets('category flyout shows remaining items on tap', (tester) async {
    final destinations = visibleAppNavDestinations(adminPerms);

    await tester.pumpWidget(
      buildHarness(
        destinations: destinations,
        permissions: adminPerms,
        initialLocation: MembersRoute.path,
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('People'),
      48,
      scrollable: find.descendant(
        of: find.byType(DesktopSideNav),
        matching: find.byType(Scrollable),
      ),
    );
    // Scrolling can trigger hover flyouts; wait for dismiss delay to clear overlay.
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(
      find.ancestor(
        of: find.text('People'),
        matching: find.byType(InkWell),
      ).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Memberships'), findsOneWidget);
  });

  testWidgets('show more reveals extra shortcut destinations', (tester) async {
    final destinations = visibleAppNavDestinations(adminPerms);

    await tester.pumpWidget(
      buildHarness(
        destinations: destinations,
        permissions: adminPerms,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reports'), findsNothing);

    await tester.tap(find.text('Show more'));
    await tester.pumpAndSettle();

    expect(find.text('Reports'), findsOneWidget);
  });

  testWidgets('hides Platform nav without organizations.manage', (tester) async {
    final destinations = visibleAppNavDestinations(adminPerms);

    await tester.pumpWidget(
      buildHarness(
        destinations: destinations,
        permissions: adminPerms,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Platform'), findsNothing);
  });

  testWidgets('shows Platform nav with organizations.manage', (tester) async {
    const platformPerms = CurrentUserPermissions(
      permissions: {
        Permissions.membersView,
        Permissions.organizationsManage,
      },
    );
    final destinations = visibleAppNavDestinations(platformPerms);

    await tester.pumpWidget(
      buildHarness(
        destinations: destinations,
        permissions: platformPerms,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Platform'), findsOneWidget);
  });
}

class _FakePermissionsController extends CurrentUserPermissionsController {
  _FakePermissionsController(this._permissions);

  final CurrentUserPermissions _permissions;

  @override
  Future<CurrentUserPermissions> build() async => _permissions;
}

class _FakeCurrentOrganizationController extends CurrentOrganizationController {
  _FakeCurrentOrganizationController(this._organization);

  final Organization _organization;

  @override
  Future<Organization?> build() async => _organization;
}
