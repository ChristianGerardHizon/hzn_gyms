import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hzn_gyms/src/core/navigation/app_nav_destination.dart';
import 'package:hzn_gyms/src/core/permissions/current_user_permissions.dart';
import 'package:hzn_gyms/src/core/routing/router_utils.dart';
import 'package:hzn_gyms/src/core/routing/routes/platform.routes.dart';
import 'package:hzn_gyms/src/features/auth/domain/auth_state.dart';
import 'package:hzn_gyms/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:hzn_gyms/src/features/users/domain/user_role.dart';

import '../../helpers/fixtures.dart';

class _AuthenticatedAuth extends AuthController {
  @override
  Future<AuthState?> build() async => buildAuthState();
}

class _PlatformAdminPermissions extends CurrentUserPermissionsController {
  @override
  Future<CurrentUserPermissions> build() async {
    return const CurrentUserPermissions(
      permissions: {Permissions.organizationsManage},
    );
  }
}

void main() {
  group('platform dashboard redirects', () {
    test('legacy /organizations redirects to platform org list', () {
      final router = GoRouter(
        routes: [GoRoute(path: '/', builder: (_, _) => const SizedBox())],
      );
      final state = GoRouterState(
        router.configuration,
        uri: Uri.parse('/organizations'),
        matchedLocation: '/organizations',
        fullPath: '/organizations',
        pathParameters: const {},
        pageKey: const ValueKey('organizations'),
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      late final Ref redirectRef;
      container.read(Provider((ref) {
        redirectRef = ref;
        return null;
      }));

      final result = RouterUtils.redirect(
        _FakeBuildContext(),
        state,
        redirectRef,
      );

      expect(result, PlatformOrganizationsRoute.path);
    });

    testWidgets('splash sends platform admins to /platform', (tester) async {
      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWith(_AuthenticatedAuth.new),
          currentUserPermissionsProvider.overrideWith(
            _PlatformAdminPermissions.new,
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authControllerProvider.future);
      await container.read(currentUserPermissionsProvider.future);

      late final Ref redirectRef;
      container.read(Provider((ref) {
        redirectRef = ref;
        return null;
      }));

      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => const SizedBox()),
          GoRoute(path: '/splash', builder: (_, _) => const SizedBox()),
          GoRoute(path: '/platform', builder: (_, _) => const SizedBox()),
        ],
      );
      final state = GoRouterState(
        router.configuration,
        uri: Uri.parse('/splash'),
        matchedLocation: '/splash',
        fullPath: '/splash',
        pathParameters: const {},
        pageKey: const ValueKey('splash'),
      );

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      final context = tester.element(find.byType(MaterialApp));

      final result = RouterUtils.redirect(context, state, redirectRef);
      expect(result, PlatformDashboardRoute.path);
    });

    test('fallbackPathFor returns platform dashboard for org managers', () {
      const perms = CurrentUserPermissions(
        permissions: {Permissions.organizationsManage},
      );

      expect(fallbackPathFor(perms), PlatformDashboardRoute.path);
    });
  });
}

class _FakeBuildContext implements BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
