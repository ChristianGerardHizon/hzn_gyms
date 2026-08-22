import 'package:kylie_gym/src/core/packages/app_info/app_info_provider.dart';
import 'package:kylie_gym/src/core/packages/pocketbase/pb_connectivity_provider.dart';
import 'package:kylie_gym/src/core/routing/pending_redirect_provider.dart';
import 'package:kylie_gym/src/core/routing/router_utils.dart';
import 'package:kylie_gym/src/core/sync/outbox_sync_worker.dart';
import 'package:kylie_gym/src/features/auth/domain/auth_state.dart';
import 'package:kylie_gym/src/features/auth/domain/user.dart';
import 'package:kylie_gym/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:kylie_gym/src/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

const _fakeAuth = AuthState(
  token: 'tok',
  user: User(id: 'u1', name: 'Test User', username: 'cashier', verified: true),
);

/// Mirrors the real [AuthController.login] transition (loading -> data/error)
/// without touching the network.
class _FakeAuthController extends AuthController {
  _FakeAuthController({this.shouldFail = false});

  final bool shouldFail;

  @override
  Future<AuthState?> build() async => null;

  @override
  Future<bool> login(String username, String password) async {
    state = const AsyncLoading();
    await Future<void>.delayed(Duration.zero);
    if (shouldFail) {
      state = AsyncError(Exception('bad credentials'), StackTrace.current);
      return false;
    }
    state = const AsyncData(_fakeAuth);
    return true;
  }
}

class _FakePendingRedirect extends PendingRedirect {
  _FakePendingRedirect(this._initial);
  final String? _initial;

  @override
  String? build() => _initial;
}

class _FakePbConnectivity extends PbConnectivity {
  @override
  Future<bool> build() async => true;
}

const _ignoredAuthRoutes = [
  '/login',
  '/splash',
  '/auth-loading',
  '/forgot-password',
];

/// Test router with the same auth transition navigation as [router.dart].
GoRouter _testRouter(ProviderContainer container) {
  final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/', builder: (context, state) => const Text('DASHBOARD')),
      GoRoute(
        path: '/deep/link',
        builder: (context, state) => const Text('DEEP_LINK'),
      ),
    ],
  );

  container.listen(authControllerProvider, (previous, next) {
    final wasAuthenticated = previous?.value != null;
    final isAuthenticated =
        next.value != null && !next.isLoading && !next.hasError;

    if (wasAuthenticated != isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final location = RouterUtils.currentLocation(router);
        if (location.isEmpty) return;

        if (isAuthenticated &&
            (location == '/login' || location == '/splash')) {
          final pendingUrl = container
              .read(pendingRedirectProvider.notifier)
              .consume();
          router.go(pendingUrl ?? '/');
        } else if (!isAuthenticated &&
            !_ignoredAuthRoutes.any((route) => location.startsWith(route))) {
          router.go('/login');
        }
      });
    }

    router.refresh();
  });

  return router;
}

_baseOverrides() => [
  pbConnectivityProvider.overrideWith(_FakePbConnectivity.new),
  appInfoProvider.overrideWith(
    (ref) async => PackageInfo(
      appName: 'kylie_gym',
      packageName: 'com.test.kylie_gym',
      version: '1.0.0',
      buildNumber: '1',
    ),
  ),
  outboxPendingCountProvider.overrideWith((ref) => Stream.value(0)),
];

Future<void> _fillAndSubmit(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField).at(0), 'cashier');
  await tester.enterText(find.byType(TextField).at(1), 'secret123');
  await tester.tap(find.byType(FilledButton));
  await tester.pumpAndSettle();
}

void main() {
  group('LoginPage', () {
    testWidgets('navigates straight to dashboard on successful login '
        '(no manual refresh required)', (tester) async {
      final container = ProviderContainer(
        overrides: [
          ..._baseOverrides(),
          authControllerProvider.overrideWith(_FakeAuthController.new),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: _testRouter(container)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);

      await _fillAndSubmit(tester);

      expect(find.text('DASHBOARD'), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
    });

    testWidgets('navigates to the pending deep link instead of dashboard, '
        'and clears the pending redirect afterwards', (tester) async {
      final container = ProviderContainer(
        overrides: [
          ..._baseOverrides(),
          authControllerProvider.overrideWith(_FakeAuthController.new),
          pendingRedirectProvider.overrideWith(
            () => _FakePendingRedirect('/deep/link'),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: _testRouter(container)),
        ),
      );
      await tester.pumpAndSettle();

      await _fillAndSubmit(tester);

      expect(find.text('DEEP_LINK'), findsOneWidget);
      expect(find.text('DASHBOARD'), findsNothing);
      expect(container.read(pendingRedirectProvider), isNull);
    });

    testWidgets('stays on the login page and shows an error on failed login', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          ..._baseOverrides(),
          authControllerProvider.overrideWith(
            () => _FakeAuthController(shouldFail: true),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: _testRouter(container)),
        ),
      );
      await tester.pumpAndSettle();

      await _fillAndSubmit(tester);

      expect(find.text('Invalid username or password.'), findsOneWidget);
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('DASHBOARD'), findsNothing);
    });
  });
}
