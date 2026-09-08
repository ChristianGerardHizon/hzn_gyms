import 'dart:async';

import 'package:hzn_gyms/src/core/foundation/failure.dart';
import 'package:hzn_gyms/src/core/permissions/current_user_permissions.dart';
import 'package:hzn_gyms/src/features/auth/domain/auth_state.dart';
import 'package:hzn_gyms/src/features/auth/domain/user.dart';
import 'package:hzn_gyms/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:hzn_gyms/src/features/organizations/domain/organization_membership.dart';
import 'package:hzn_gyms/src/features/organizations/presentation/controllers/current_organization_controller.dart';
import 'package:hzn_gyms/src/features/organizations/presentation/controllers/organization_memberships_controller.dart';
import 'package:hzn_gyms/src/features/users/data/repositories/user_role_repository.dart';
import 'package:hzn_gyms/src/features/users/domain/user_role.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocketbase/pocketbase.dart';

class MockUserRoleRepository extends Mock implements UserRoleRepository {}

void main() {
  group('CurrentUserPermissions', () {
    test('equality ignores permission order', () {
      const a = CurrentUserPermissions(
        permissions: {
          Permissions.membershipsView,
          Permissions.membershipsExcludeFromSales,
        },
      );
      const b = CurrentUserPermissions(
        permissions: {
          Permissions.membershipsExcludeFromSales,
          Permissions.membershipsView,
        },
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('fromRole marks admin when system.admin is present', () {
      final perms = CurrentUserPermissions.fromRole(
        const UserRole(
          id: '1',
          name: 'Admin',
          permissions: [Permissions.systemAdmin],
        ),
      );

      expect(perms.isAdmin, isTrue);
      expect(perms.canExcludeMembershipFromSales, isTrue);
    });

    test('canVoidCheckIns requires explicit permission like canVoidSales', () {
      const adminOnly = CurrentUserPermissions(
        permissions: {Permissions.systemAdmin},
        isAdmin: true,
      );
      expect(adminOnly.canVoidCheckIns, isFalse);
      expect(adminOnly.canVoidSales, isFalse);

      const withVoid = CurrentUserPermissions(
        permissions: {Permissions.checkInsVoid},
      );
      expect(withVoid.canVoidCheckIns, isTrue);
    });

    test('canManageOrganizations requires users.superAdmin', () {
      const adminOnly = CurrentUserPermissions(
        permissions: {Permissions.systemAdmin},
        isAdmin: true,
      );
      expect(adminOnly.canManageOrganizations, isFalse);

      const platform = CurrentUserPermissions(superAdmin: true);
      expect(platform.canManageOrganizations, isTrue);
    });

    test('canViewActivityLog is granted by admin or activityLog.view', () {
      const admin = CurrentUserPermissions(isAdmin: true);
      expect(admin.canViewActivityLog, isTrue);

      const viewer = CurrentUserPermissions(
        permissions: {Permissions.activityLogView},
      );
      expect(viewer.canViewActivityLog, isTrue);

      const staff = CurrentUserPermissions(
        permissions: {Permissions.membersView},
      );
      expect(staff.canViewActivityLog, isFalse);
    });
  });

  group('canUseOrganizationSwitcher', () {
    const platformPerms = CurrentUserPermissions(superAdmin: true);

    const platformAuth = AuthState(
      token: 'tok',
      user: User(
        id: 'platform-admin',
        name: 'Platform Admin',
        email: 'platform@test.com',
        verified: true,
        superAdmin: true,
      ),
    );

    ProviderContainer createContainer({
      required CurrentUserPermissions permissions,
      AuthState? auth,
    }) {
      return ProviderContainer(
        overrides: [
          currentUserPermissionsProvider.overrideWith(
            () => _StaticPermissionsController(permissions),
          ),
          currentAuthProvider.overrideWithValue(auth),
        ],
      );
    }

    test('true when permissions.superAdmin is set', () async {
      final container = createContainer(
        permissions: platformPerms,
        auth: platformAuth,
      );
      addTearDown(container.dispose);

      await container.read(currentUserPermissionsProvider.future);
      expect(container.read(canUseOrganizationSwitcherProvider), isTrue);
    });

    test('true for superAdmin even when user has organization link', () async {
      const linkedAuth = AuthState(
        token: 'tok',
        user: User(
          id: 'platform-admin',
          name: 'Platform Admin',
          email: 'platform@test.com',
          verified: true,
          organization: 'org-1',
          superAdmin: true,
        ),
      );
      final container = createContainer(
        permissions: platformPerms,
        auth: linkedAuth,
      );
      addTearDown(container.dispose);

      await container.read(currentUserPermissionsProvider.future);
      expect(container.read(canUseOrganizationSwitcherProvider), isTrue);
    });

    test('false without superAdmin', () async {
      final container = createContainer(
        permissions: CurrentUserPermissions.empty,
        auth: platformAuth,
      );
      addTearDown(container.dispose);

      await container.read(currentUserPermissionsProvider.future);
      expect(container.read(canUseOrganizationSwitcherProvider), isFalse);
    });
  });

  group('CurrentUserPermissionsController', () {
    late MockUserRoleRepository repo;

    const auth = AuthState(
      token: 'tok',
      user: User(
        id: 'u1',
        name: 'Staff',
        email: 'staff@test.com',
        verified: true,
        roleId: 'role-1',
      ),
    );

    const staffRole = UserRole(
      id: 'role-1',
      name: 'Staff',
      permissions: [Permissions.membershipsView, Permissions.membershipsCreate],
    );

    const staffRoleWithExclude = UserRole(
      id: 'role-1',
      name: 'Staff',
      permissions: [
        Permissions.membershipsView,
        Permissions.membershipsCreate,
        Permissions.membershipsExcludeFromSales,
      ],
    );

    setUp(() {
      repo = MockUserRoleRepository();
      when(
        () => repo.subscribeOne(any(), onEvent: any(named: 'onEvent')),
      ).thenAnswer((_) async => () async {});
    });

    ProviderContainer createContainer({
      AuthState? authState = auth,
      bool signedOut = false,
      OrganizationMembership? membership,
    }) {
      return ProviderContainer(
        overrides: [
          userRoleRepositoryProvider.overrideWithValue(repo),
          currentAuthProvider.overrideWithValue(signedOut ? null : authState),
          currentOrganizationIdProvider.overrideWith((ref) => 'org-1'),
          currentOrganizationMembershipProvider.overrideWith(
            (ref) => membership,
          ),
        ],
      );
    }

    test('loads permissions from the signed-in user role', () async {
      when(
        () => repo.fetchOne('role-1'),
      ).thenAnswer((_) async => right(staffRole));

      final container = createContainer();
      addTearDown(container.dispose);

      final perms = await container.read(currentUserPermissionsProvider.future);

      expect(perms.canExcludeMembershipFromSales, isFalse);
      expect(perms.has(Permissions.membershipsCreate), isTrue);
    });

    test('prefers active organization membership role over users.role', () async {
      const orgRole = UserRole(
        id: 'role-org',
        name: 'Org Staff',
        permissions: [Permissions.membersView],
      );
      when(
        () => repo.fetchOne('role-org'),
      ).thenAnswer((_) async => right(orgRole));

      final container = createContainer(
        membership: const OrganizationMembership(
          id: 'om-1',
          userId: 'u1',
          organizationId: 'org-1',
          roleId: 'role-org',
        ),
      );
      addTearDown(container.dispose);

      final perms = await container.read(currentUserPermissionsProvider.future);

      expect(perms.has(Permissions.membersView), isTrue);
      expect(perms.has(Permissions.membershipsCreate), isFalse);
      verify(() => repo.fetchOne('role-org')).called(1);
      verifyNever(() => repo.fetchOne('role-1'));
    });

    test(
      'refreshInBackground updates permissions without clearing prior value',
      () async {
        var fetchCount = 0;
        when(() => repo.fetchOne('role-1')).thenAnswer((_) async {
          fetchCount++;
          return right(fetchCount == 1 ? staffRole : staffRoleWithExclude);
        });

        final container = createContainer();
        addTearDown(container.dispose);

        final initial = await container.read(
          currentUserPermissionsProvider.future,
        );
        expect(initial.canExcludeMembershipFromSales, isFalse);

        await container
            .read(currentUserPermissionsProvider.notifier)
            .refreshInBackground();

        final updated = container.read(currentUserPermissionsProvider).value;
        expect(updated?.canExcludeMembershipFromSales, isTrue);
        expect(
          container.read(currentUserPermissionsProvider).isLoading,
          isFalse,
        );
      },
    );

    test('refreshInBackground keeps prior permissions on failure', () async {
      when(
        () => repo.fetchOne('role-1'),
      ).thenAnswer((_) async => right(staffRoleWithExclude));

      final container = createContainer();
      addTearDown(container.dispose);

      final initial = await container.read(
        currentUserPermissionsProvider.future,
      );
      expect(initial.canExcludeMembershipFromSales, isTrue);

      when(() => repo.fetchOne('role-1')).thenAnswer(
        (_) async => left(const DataFailure('offline', null, 'network')),
      );

      await container
          .read(currentUserPermissionsProvider.notifier)
          .refreshInBackground();

      expect(
        container
            .read(currentUserPermissionsProvider)
            .value
            ?.canExcludeMembershipFromSales,
        isTrue,
      );
    });

    test('returns empty permissions when signed out', () async {
      final container = createContainer(signedOut: true);
      addTearDown(container.dispose);

      final perms = await container.read(currentUserPermissionsProvider.future);

      expect(perms, CurrentUserPermissions.empty);
      verifyNever(() => repo.fetchOne(any()));
    });

    test('subscribes to the signed-in role for realtime updates', () async {
      when(
        () => repo.fetchOne('role-1'),
      ).thenAnswer((_) async => right(staffRole));

      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(currentUserPermissionsProvider.future);
      // Listeners are scheduled after the initial build commits.
      await Future<void>.delayed(Duration.zero);

      final captured = verify(
        () =>
            repo.subscribeOne('role-1', onEvent: captureAny(named: 'onEvent')),
      )..called(1);

      final onEvent =
          captured.captured.single as void Function(RecordSubscriptionEvent);
      expect(onEvent, isNotNull);
    });

    test('does not subscribe until the initial fetch completes', () async {
      final fetchStarted = Completer<void>();
      final allowFetch = Completer<void>();
      when(() => repo.fetchOne('role-1')).thenAnswer((_) async {
        if (!fetchStarted.isCompleted) fetchStarted.complete();
        await allowFetch.future;
        return right(staffRole);
      });

      final container = createContainer();
      addTearDown(container.dispose);

      final future = container.read(currentUserPermissionsProvider.future);
      await fetchStarted.future;

      verifyNever(
        () => repo.subscribeOne(any(), onEvent: any(named: 'onEvent')),
      );

      allowFetch.complete();
      await future;
      await Future<void>.delayed(Duration.zero);

      verify(
        () => repo.subscribeOne('role-1', onEvent: any(named: 'onEvent')),
      ).called(1);
    });

    test(
      'refreshInBackground is a no-op while initial build is still loading',
      () async {
        final allowFetch = Completer<void>();
        when(() => repo.fetchOne('role-1')).thenAnswer((_) async {
          await allowFetch.future;
          return right(staffRole);
        });

        final container = createContainer();
        addTearDown(container.dispose);

        final future = container.read(currentUserPermissionsProvider.future);
        expect(
          container.read(currentUserPermissionsProvider).hasValue,
          isFalse,
        );

        await container
            .read(currentUserPermissionsProvider.notifier)
            .refreshInBackground();

        // Still only the in-flight initial fetch — no extra fetch from refresh.
        verify(() => repo.fetchOne('role-1')).called(1);

        allowFetch.complete();
        final perms = await future;
        expect(perms.has(Permissions.membershipsCreate), isTrue);
      },
    );

    test('refreshInBackground coalesces overlapping calls', () async {
      when(
        () => repo.fetchOne('role-1'),
      ).thenAnswer((_) async => right(staffRole));

      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(currentUserPermissionsProvider.future);

      final allowRefresh = Completer<void>();
      var refreshFetchCount = 0;
      when(() => repo.fetchOne('role-1')).thenAnswer((_) async {
        refreshFetchCount++;
        await allowRefresh.future;
        return right(staffRoleWithExclude);
      });

      final notifier = container.read(currentUserPermissionsProvider.notifier);
      final first = notifier.refreshInBackground();
      final second = notifier.refreshInBackground();

      // Role id resolution is async; wait until the coalesced fetch starts.
      await Future<void>.delayed(Duration.zero);
      expect(refreshFetchCount, 1);

      allowRefresh.complete();
      await Future.wait([first, second]);

      expect(refreshFetchCount, 1);
      expect(
        container
            .read(currentUserPermissionsProvider)
            .value
            ?.canExcludeMembershipFromSales,
        isTrue,
      );
    });
  });
}

class _StaticPermissionsController extends CurrentUserPermissionsController {
  _StaticPermissionsController(this._permissions);

  final CurrentUserPermissions _permissions;

  @override
  Future<CurrentUserPermissions> build() async => _permissions;
}
