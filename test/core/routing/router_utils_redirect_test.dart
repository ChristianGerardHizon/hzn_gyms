import 'dart:async';

import 'package:kylie_gym/src/core/permissions/current_user_permissions.dart';
import 'package:kylie_gym/src/core/routing/pending_redirect_provider.dart';
import 'package:kylie_gym/src/core/routing/router_utils.dart';
import 'package:kylie_gym/src/features/auth/domain/auth_state.dart';
import 'package:kylie_gym/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:kylie_gym/src/features/users/domain/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/fixtures.dart';

class _AuthenticatedAuth extends AuthController {
  @override
  Future<AuthState?> build() async => buildAuthState();
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
      GoRoute(path: '/splash', builder: (_, _) => const Text('splash')),
      GoRoute(path: '/login', builder: (_, _) => const Text('login')),
      GoRoute(path: '/members', builder: (_, _) => const Text('members')),
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
    ],
  );

  ref.listen(authControllerProvider, (_, _) => router.refresh());
  ref.listen(currentUserPermissionsProvider, (_, _) => router.refresh());
  Future.microtask(router.refresh);

  return router;
});

void main() {
  tearDown(PendingRedirect.clearStash);

  group('RouterUtils.redirect', () {
    testWidgets(
      'stays on permission-sensitive path while role permissions load',
      (tester) async {
        final permsCompleter = Completer<CurrentUserPermissions>();
        final container = ProviderContainer(
          overrides: [
            authControllerProvider.overrideWith(_AuthenticatedAuth.new),
            currentUserPermissionsProvider.overrideWith(
              () => _LoadingPermissions(permsCompleter),
            ),
          ],
        );
        addTearDown(container.dispose);

        final router = container.read(_testRouterProvider('/system/printers'));

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        // Auth resolves; permissions stay pending — do not use pumpAndSettle.
        await tester.pump();
        await tester.pump();

        expect(RouterUtils.currentLocation(router), '/system/printers');
        expect(find.text('printers'), findsOneWidget);
        expect(find.text('dashboard'), findsNothing);

        permsCompleter.complete(
          const CurrentUserPermissions(
            permissions: {Permissions.systemAdmin},
            isAdmin: true,
          ),
        );
        await tester.pump();
        await tester.pump();

        expect(RouterUtils.currentLocation(router), '/system/printers');
      },
    );

    testWidgets(
      'redirects away from sensitive path when loaded perms deny access',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
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

        final router = container.read(_testRouterProvider('/system/printers'));

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pumpAndSettle();

        // Staff without system.admin cannot stay on /system/printers.
        expect(RouterUtils.currentLocation(router), '/');
        expect(find.text('dashboard'), findsOneWidget);
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

    testWidgets('redirects standalone /cashier to dashboard', (tester) async {
      final container = ProviderContainer(
        overrides: [
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

      expect(RouterUtils.currentLocation(router), '/');
      expect(find.text('dashboard'), findsOneWidget);
      expect(find.text('cashier'), findsNothing);
    });

    testWidgets('restores stashed deep link from splash after auth resolves', (
      tester,
    ) async {
      PendingRedirect.stash('/system/printers');
      final container = ProviderContainer(
        overrides: [
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

      final result = RouterUtils.redirect(context, state, redirectRef);

      expect(result, '/system/printers');
      expect(container.read(pendingRedirectProvider.notifier).peek(), isNull);
    });
  });
}
