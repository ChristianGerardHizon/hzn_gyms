import 'dart:async';

import 'package:ebe_gym/src/core/foundation/failure.dart';
import 'package:ebe_gym/src/core/permissions/current_user_permissions.dart';
import 'package:ebe_gym/src/features/auth/domain/auth_state.dart';
import 'package:ebe_gym/src/features/auth/domain/user.dart';
import 'package:ebe_gym/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ebe_gym/src/features/users/data/repositories/user_role_repository.dart';
import 'package:ebe_gym/src/features/users/domain/user_role.dart';
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
  });

  group('CurrentUserPermissionsController', () {
    late MockUserRoleRepository repo;

    const auth = AuthState(
      token: 'tok',
      user: User(
        id: 'u1',
        name: 'Staff',
        username: 'staff',
        verified: true,
        roleId: 'role-1',
      ),
    );

    const staffRole = UserRole(
      id: 'role-1',
      name: 'Staff',
      permissions: [
        Permissions.membershipsView,
        Permissions.membershipsCreate,
      ],
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
        () => repo.subscribeOne(
          any(),
          onEvent: any(named: 'onEvent'),
        ),
      ).thenAnswer((_) async => () async {});
    });

    ProviderContainer createContainer({
      AuthState? authState = auth,
      bool signedOut = false,
    }) {
      return ProviderContainer(
        overrides: [
          userRoleRepositoryProvider.overrideWithValue(repo),
          currentAuthProvider.overrideWithValue(signedOut ? null : authState),
        ],
      );
    }

    test('loads permissions from the signed-in user role', () async {
      when(() => repo.fetchOne('role-1')).thenAnswer(
        (_) async => right(staffRole),
      );

      final container = createContainer();
      addTearDown(container.dispose);

      final perms = await container.read(currentUserPermissionsProvider.future);

      expect(perms.canExcludeMembershipFromSales, isFalse);
      expect(perms.has(Permissions.membershipsCreate), isTrue);
    });

    test(
      'refreshInBackground updates permissions without clearing prior value',
      () async {
        var fetchCount = 0;
        when(() => repo.fetchOne('role-1')).thenAnswer((_) async {
          fetchCount++;
          return right(
            fetchCount == 1 ? staffRole : staffRoleWithExclude,
          );
        });

        final container = createContainer();
        addTearDown(container.dispose);

        final initial =
            await container.read(currentUserPermissionsProvider.future);
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
      when(() => repo.fetchOne('role-1')).thenAnswer(
        (_) async => right(staffRoleWithExclude),
      );

      final container = createContainer();
      addTearDown(container.dispose);

      final initial =
          await container.read(currentUserPermissionsProvider.future);
      expect(initial.canExcludeMembershipFromSales, isTrue);

      when(() => repo.fetchOne('role-1')).thenAnswer(
        (_) async => left(const DataFailure('offline', null, 'network')),
      );

      await container
          .read(currentUserPermissionsProvider.notifier)
          .refreshInBackground();

      expect(
        container.read(currentUserPermissionsProvider).value
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
      when(() => repo.fetchOne('role-1')).thenAnswer(
        (_) async => right(staffRole),
      );

      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(currentUserPermissionsProvider.future);
      // Listeners are scheduled after the initial build commits.
      await Future<void>.delayed(Duration.zero);

      final captured = verify(
        () => repo.subscribeOne(
          'role-1',
          onEvent: captureAny(named: 'onEvent'),
        ),
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
        () => repo.subscribeOne(
          any(),
          onEvent: any(named: 'onEvent'),
        ),
      );

      allowFetch.complete();
      await future;
      await Future<void>.delayed(Duration.zero);

      verify(
        () => repo.subscribeOne(
          'role-1',
          onEvent: any(named: 'onEvent'),
        ),
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
        expect(container.read(currentUserPermissionsProvider).hasValue, isFalse);

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
  });
}
