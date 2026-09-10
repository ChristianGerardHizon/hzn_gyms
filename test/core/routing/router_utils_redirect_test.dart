import 'dart:async';

import 'package:hzn_gyms/src/core/permissions/current_user_permissions.dart';
import 'package:hzn_gyms/src/core/routing/pending_redirect_provider.dart';
import 'package:hzn_gyms/src/core/routing/router_utils.dart';
import 'package:hzn_gyms/src/features/auth/domain/auth_state.dart';
import 'package:hzn_gyms/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:hzn_gyms/src/features/organizations/domain/organization.dart';
import 'package:hzn_gyms/src/features/organizations/domain/organization_membership.dart';
import 'package:hzn_gyms/src/features/organizations/presentation/controllers/current_organization_controller.dart';
import 'package:hzn_gyms/src/features/organizations/presentation/controllers/organization_memberships_controller.dart';
import 'package:hzn_gyms/src/features/settings/domain/branch.dart';
import 'package:hzn_gyms/src/features/settings/presentation/controllers/branches_controller.dart';
import 'package:hzn_gyms/src/features/settings/presentation/controllers/current_branch_controller.dart';
import 'package:hzn_gyms/src/features/users/domain/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/fake_organization_memberships.dart';
import '../../helpers/fixtures.dart';

const _testOrg = Organization(id: 'org-1', name: 'Test Gym', slug: 'testgym');
const _testBranch = Branch(
  id: 'branch-1',
  name: 'Main',
  code: 'MAIN',
  slug: 'main',
  address: 'x',
  contactNumber: '1',
);
const _scopedDashboard = '/testgym/main/dashboard';

const _testMembership = OrganizationMembership(
  id: 'om-1',
  userId: 'user-1',
  organizationId: 'org-1',
  roleId: 'role-1',
);

final _membershipsOverride =
    organizationMembershipsControllerProvider.overrideWith(
      () => FakeOrganizationMembershipsController(const [_testMembership]),
    );

final _emptyMembershipsOverride =
    organizationMembershipsControllerProvider.overrideWith(
      () => FakeOrganizationMembershipsController(const []),
    );

final _scopeOverrides = [
  currentOrganizationControllerProvider.overrideWith(
    () => _FixedCurrentOrganization(_testOrg),
  ),
  currentBranchControllerProvider.overrideWith(
    () => _FixedCurrentBranch(
      const CurrentBranchSelection(branch: _testBranch),
    ),
  ),
  branchesControllerProvider.overrideWith(
    () => _FakeBranchesController(const [_testBranch]),
  ),
];

class _AuthenticatedAuth extends AuthController {
  @override
  Future<AuthState?> build() async => buildAuthState();
}

class _SignedOutAuth extends AuthController {
  @override
  Future<AuthState?> build() async => null;
}

class _LoadingAuth extends AuthController {
  @override
  Future<AuthState?> build() async {
    await Completer<void>().future;
    return null;
  }
}

class _FixedPermissions extends CurrentUserPermissionsController {
  _FixedPermissions(this._permissions);

  final CurrentUserPermissions _permissions;

  @override
  Future<CurrentUserPermissions> build() async => _permissions;
}

class _LoadingPermissions extends CurrentUserPermissionsController {
  _LoadingPermissions(this._completer);

  final Completer<CurrentUserPermissions> _completer;

  @override
  Future<CurrentUserPermissions> build() => _completer.future;
}

class _FixedCurrentOrganization extends CurrentOrganizationController {
  _FixedCurrentOrganization(this._org);

  final Organization? _org;

  @override
  Future<Organization?> build() async => _org;
}

class _FixedCurrentBranch extends CurrentBranchController {
  _FixedCurrentBranch(this._selection);

  final CurrentBranchSelection _selection;

  @override
  Future<CurrentBranchSelection> build() async => _selection;

  @override
  Future<List<String>> switchableBranchIds() async {
    final id = _selection.branch?.id;
    return id == null ? const [] : [id];
  }

  @override
  Future<bool> canViewAllBranches() async => false;
}

class _FakeBranchesController extends BranchesController {
  _FakeBranchesController(this._branches);

  final List<Branch> _branches;

  @override
  Future<List<Branch>> build() async => _branches;
}

/// Minimal router that uses [RouterUtils.redirect] like the app.
final _testRouterProvider = Provider.family<GoRouter, String>((
  ref,
  initialLocation,
) {
  final router = GoRouter(
    initialLocation: initialLocation,
    redirect: (context, state) => RouterUtils.redirect(context, state, ref),
    routes: [
      GoRoute(path: '/', builder: (_, _) => const Text('dashboard')),
      GoRoute(
        path: '/dashboard',
        builder: (_, _) => const Text('dashboard'),
      ),
      GoRoute(path: '/splash', builder: (_, _) => const Text('splash')),
      GoRoute(path: '/login', builder: (_, _) => const Text('login')),
      GoRoute(path: '/members', builder: (_, _) => const Text('members')),
      GoRoute(
        path: '/platform/organizations',
        builder: (_, _) => const Text('platform-orgs'),
      ),
      GoRoute(
        path: '/platform',
        builder: (_, _) => const Text('platform'),
      ),
      GoRoute(
        path: '/system/printers',
        builder: (_, _) => const Text('printers'),
      ),
      GoRoute(
        path: '/organization',
        builder: (_, _) => const Text('organization'),
      ),
      GoRoute(
        path: '/check-in/records',
        builder: (_, _) => const Text('records'),
      ),
      GoRoute(path: '/cashier', builder: (_, _) => const Text('cashier')),
      GoRoute(
        path: '/awaiting-organization',
        builder: (_, _) => const Text('awaiting'),
      ),
      // Production-shaped org/branch shell (dashboard is not top-level).
      GoRoute(
        path: '/:orgSlug/:branchSlug',
        redirect: (context, state) {
          final org = state.pathParameters['orgSlug']!;
          final branch = state.pathParameters['branchSlug']!;
          final path = state.uri.path.replaceAll(RegExp(r'/+$'), '');
          if (path == '/$org/$branch') {
            return '/$org/$branch/dashboard';
          }
          return null;
        },
        routes: [
          ShellRoute(
            builder: (context, state, child) => Scaffold(body: child),
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (_, _) => const Text('scoped-dashboard'),
              ),
              GoRoute(
                path: '/members',
                builder: (_, _) => const Text('scoped-members'),
              ),
              GoRoute(
                path: '/system/printers',
                builder: (_, _) => const Text('scoped-printers'),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ref.listen(authControllerProvider, (_, _) => router.refresh());
  ref.listen(currentUserPermissionsProvider, (_, _) => router.refresh());
  ref.listen(
    organizationMembershipsControllerProvider,
    (_, _) => router.refresh(),
  );
  ref.listen(currentOrganizationControllerProvider, (_, _) => router.refresh());
  ref.listen(currentBranchControllerProvider, (_, _) => router.refresh());
  Future.microtask(router.refresh);

  return router;
});

void main() {
  tearDown(PendingRedirect.clearStash);

  group('legacyOrganizationRedirect', () {
    test('maps nested organization paths to top-level routes', () {
      expect(RouterUtils.legacyOrganizationRedirect('/organization'), '/users');
      expect(
        RouterUtils.legacyOrganizationRedirect('/organization/users'),
        '/users',
      );
      expect(
        RouterUtils.legacyOrganizationRedirect('/organization/users/u1'),
        '/users/u1',
      );
      expect(
        RouterUtils.legacyOrganizationRedirect('/organization/roles'),
        '/roles',
      );
      expect(
        RouterUtils.legacyOrganizationRedirect('/organization/roles/r1'),
        '/roles/r1',
      );
      expect(
        RouterUtils.legacyOrganizationRedirect('/organization/branches'),
        '/branches',
      );
      expect(
        RouterUtils.legacyOrganizationRedirect('/organization/branches/b1'),
        '/branches/b1',
      );
      expect(RouterUtils.legacyOrganizationRedirect('/members'), isNull);
    });
  });

  group('RouterUtils.homePathFor', () {
    test('parks on splash when org/branch scope is unresolved', () {
      late final Ref homeRef;
      final container = ProviderContainer(
        overrides: [
          _membershipsOverride,
          authControllerProvider.overrideWith(_AuthenticatedAuth.new),
          currentUserPermissionsProvider.overrideWith(
            () => _FixedPermissions(
              const CurrentUserPermissions(
                permissions: {Permissions.membersView},
              ),
            ),
          ),
          currentOrganizationControllerProvider.overrideWith(
            () => _FixedCurrentOrganization(null),
          ),
          currentBranchControllerProvider.overrideWith(
            () => _FixedCurrentBranch(const CurrentBranchSelection()),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(
        Provider((ref) {
          homeRef = ref;
          return null;
        }),
      );

      expect(RouterUtils.homePathFor(homeRef), '/splash');
    });

    test('returns scoped dashboard when org/branch are resolved', () async {
      late final Ref homeRef;
      final container = ProviderContainer(
        overrides: [
          _membershipsOverride,
          ..._scopeOverrides,
          authControllerProvider.overrideWith(_AuthenticatedAuth.new),
          currentUserPermissionsProvider.overrideWith(
            () => _FixedPermissions(
              const CurrentUserPermissions(
                permissions: {Permissions.membersView},
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(currentOrganizationControllerProvider.future);
      await container.read(currentBranchControllerProvider.future);

      container.read(
        Provider((ref) {
          homeRef = ref;
          return null;
        }),
      );

      expect(RouterUtils.homePathFor(homeRef), _scopedDashboard);
    });
  });

  group('RouterUtils.redirect', () {
    testWidgets(
      'stays on permission-sensitive path while role permissions load',
      (tester) async {
        final permsCompleter = Completer<CurrentUserPermissions>();
        final container = ProviderContainer(
          overrides: [
            _membershipsOverride,
            ..._scopeOverrides,
            authControllerProvider.overrideWith(_AuthenticatedAuth.new),
            currentUserPermissionsProvider.overrideWith(
              () => _LoadingPermissions(permsCompleter),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container.read(currentOrganizationControllerProvider.future);
        await container.read(currentBranchControllerProvider.future);
        await container.read(branchesControllerProvider.future);

        final router = container.read(
          _testRouterProvider('/testgym/main/system/printers'),
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        // Auth resolves; permissions stay pending — do not use pumpAndSettle.
        await tester.pump();
        await tester.pump();

        expect(
          RouterUtils.currentLocation(router),
          '/testgym/main/system/printers',
        );
        expect(find.text('scoped-printers'), findsOneWidget);
        expect(find.text('scoped-dashboard'), findsNothing);

        permsCompleter.complete(
          const CurrentUserPermissions(
            permissions: {Permissions.systemAdmin},
            isAdmin: true,
          ),
        );
        await tester.pump();
        await tester.pump();

        expect(
          RouterUtils.currentLocation(router),
          '/testgym/main/system/printers',
        );
      },
    );

    testWidgets(
      'redirects away from sensitive path when loaded perms deny access',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            _membershipsOverride,
            ..._scopeOverrides,
            authControllerProvider.overrideWith(_AuthenticatedAuth.new),
            currentUserPermissionsProvider.overrideWith(
              () => _FixedPermissions(
                const CurrentUserPermissions(
                  permissions: {Permissions.membersView},
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container.read(currentOrganizationControllerProvider.future);
        await container.read(currentBranchControllerProvider.future);
        await container.read(branchesControllerProvider.future);

        final router = container.read(
          _testRouterProvider('/testgym/main/system/printers'),
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        // Staff without system.admin cannot stay on /system/printers.
        expect(RouterUtils.currentLocation(router), _scopedDashboard);
        expect(find.text('scoped-dashboard'), findsOneWidget);
      },
    );

    testWidgets(
      'parks flat app paths on splash when org/branch are unresolved',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            _membershipsOverride,
            authControllerProvider.overrideWith(_AuthenticatedAuth.new),
            currentUserPermissionsProvider.overrideWith(
              () => _FixedPermissions(
                const CurrentUserPermissions(
                  permissions: {Permissions.membersView},
                ),
              ),
            ),
            currentOrganizationControllerProvider.overrideWith(
              () => _FixedCurrentOrganization(null),
            ),
            currentBranchControllerProvider.overrideWith(
              () => _FixedCurrentBranch(const CurrentBranchSelection()),
            ),
          ],
        );
        addTearDown(container.dispose);

        final router = container.read(_testRouterProvider('/dashboard'));

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        expect(RouterUtils.currentLocation(router), '/splash');
        expect(find.text('splash'), findsOneWidget);
      },
    );

    testWidgets('stores pending redirect synchronously while auth is loading', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [authControllerProvider.overrideWith(_LoadingAuth.new)],
      );
      addTearDown(container.dispose);

      final router = container.read(_testRouterProvider('/members'));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump();
      // Flush Future(() => pendingRedirect.set(...)) scheduled during redirect.
      await tester.pump(Duration.zero);

      // Eager stash is set during redirect; peek sees it immediately.
      expect(
        container.read(pendingRedirectProvider.notifier).peek(),
        '/members',
      );
      expect(RouterUtils.currentLocation(router), '/splash');
      expect(find.text('splash'), findsOneWidget);
    });

    testWidgets(
      'redirects to awaiting-organization when no memberships',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            _emptyMembershipsOverride,
            authControllerProvider.overrideWith(_AuthenticatedAuth.new),
            currentUserPermissionsProvider.overrideWith(
              () => _FixedPermissions(
                const CurrentUserPermissions(
                  permissions: {Permissions.membersView},
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        final router = container.read(_testRouterProvider('/members'));

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        expect(RouterUtils.currentLocation(router), '/awaiting-organization');
        expect(find.text('awaiting'), findsOneWidget);
      },
    );

    testWidgets(
      'platform admin is not blocked by empty memberships',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            _emptyMembershipsOverride,
            authControllerProvider.overrideWith(_AuthenticatedAuth.new),
            currentUserPermissionsProvider.overrideWith(
              () => _FixedPermissions(
                const CurrentUserPermissions(superAdmin: true),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Platform home is the correct landing path for superAdmin.
        final router = container.read(_testRouterProvider('/platform'));

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        expect(RouterUtils.currentLocation(router), '/platform');
        expect(find.text('platform'), findsOneWidget);
        expect(find.text('awaiting'), findsNothing);
      },
    );

    testWidgets('empty root `/` redirects authenticated user to scoped home', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          _membershipsOverride,
          ..._scopeOverrides,
          authControllerProvider.overrideWith(_AuthenticatedAuth.new),
          currentUserPermissionsProvider.overrideWith(
            () => _FixedPermissions(
              const CurrentUserPermissions(
                permissions: {Permissions.membersView},
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final router = container.read(_testRouterProvider('/'));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(RouterUtils.currentLocation(router), _scopedDashboard);
      expect(find.text('scoped-dashboard'), findsOneWidget);
    });

    testWidgets(
      'empty root `/` parks on splash when scope is unresolved',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            _membershipsOverride,
            authControllerProvider.overrideWith(_AuthenticatedAuth.new),
            currentUserPermissionsProvider.overrideWith(
              () => _FixedPermissions(
                const CurrentUserPermissions(
                  permissions: {Permissions.membersView},
                ),
              ),
            ),
            currentOrganizationControllerProvider.overrideWith(
              () => _FixedCurrentOrganization(null),
            ),
            currentBranchControllerProvider.overrideWith(
              () => _FixedCurrentBranch(const CurrentBranchSelection()),
            ),
          ],
        );
        addTearDown(container.dispose);

        final router = container.read(_testRouterProvider('/'));

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        expect(RouterUtils.currentLocation(router), '/splash');
        expect(find.text('splash'), findsOneWidget);
      },
    );

    testWidgets('empty root `/` redirects platform admin to platform home', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          _emptyMembershipsOverride,
          authControllerProvider.overrideWith(_AuthenticatedAuth.new),
          currentUserPermissionsProvider.overrideWith(
            () => _FixedPermissions(
              const CurrentUserPermissions(superAdmin: true),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final router = container.read(_testRouterProvider('/'));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(RouterUtils.currentLocation(router), '/platform');
      expect(find.text('platform'), findsOneWidget);
    });

    testWidgets('empty root `/` redirects signed-out user to login', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWith(_SignedOutAuth.new),
        ],
      );
      addTearDown(container.dispose);

      final router = container.read(_testRouterProvider('/'));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(RouterUtils.currentLocation(router), '/login');
      expect(find.text('login'), findsOneWidget);
    });

    testWidgets('redirects standalone /cashier to scoped dashboard', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          _membershipsOverride,
          ..._scopeOverrides,
          authControllerProvider.overrideWith(_AuthenticatedAuth.new),
          currentUserPermissionsProvider.overrideWith(
            () => _FixedPermissions(
              const CurrentUserPermissions(
                permissions: {Permissions.salesCreate},
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final router = container.read(_testRouterProvider('/cashier'));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(RouterUtils.currentLocation(router), _scopedDashboard);
      expect(find.text('scoped-dashboard'), findsOneWidget);
      expect(find.text('cashier'), findsNothing);
    });

    testWidgets('restores stashed deep link from splash after auth resolves', (
      tester,
    ) async {
      PendingRedirect.stash('/system/printers');
      final container = ProviderContainer(
        overrides: [
          _membershipsOverride,
          authControllerProvider.overrideWith(_AuthenticatedAuth.new),
          currentUserPermissionsProvider.overrideWith(
            () => _FixedPermissions(
              const CurrentUserPermissions(
                permissions: {Permissions.systemAdmin},
                isAdmin: true,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authControllerProvider.future);

      // Call redirect the same way GoRouter does once auth is settled on splash.
      late final Ref redirectRef;
      container.read(
        Provider((ref) {
          redirectRef = ref;
          return null;
        }),
      );

      final probeRouter = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => const SizedBox()),
          GoRoute(path: '/splash', builder: (_, _) => const SizedBox()),
          GoRoute(
            path: '/system/printers',
            builder: (_, _) => const SizedBox(),
          ),
          GoRoute(path: '/login', builder: (_, _) => const SizedBox()),
        ],
      );
      final state = GoRouterState(
        probeRouter.configuration,
        uri: Uri.parse('/splash'),
        matchedLocation: '/splash',
        fullPath: '/splash',
        pathParameters: const {},
        pageKey: const ValueKey('splash'),
      );

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      final context = tester.element(find.byType(MaterialApp));

      final result = await RouterUtils.redirect(context, state, redirectRef);

      expect(result, '/system/printers');
      expect(container.read(pendingRedirectProvider.notifier).peek(), isNull);
    });
  });
}
