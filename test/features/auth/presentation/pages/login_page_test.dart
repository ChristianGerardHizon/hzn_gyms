import 'package:hzn_gyms/src/core/foundation/failure.dart';
import 'package:hzn_gyms/src/core/packages/app_info/app_info_provider.dart';
import 'package:hzn_gyms/src/core/packages/pocketbase/pb_connectivity_provider.dart';
import 'package:hzn_gyms/src/core/routing/pending_redirect_provider.dart';
import 'package:hzn_gyms/src/core/routing/router_utils.dart';
import 'package:hzn_gyms/src/core/sync/outbox_sync_worker.dart';
import 'package:hzn_gyms/src/features/auth/domain/auth_state.dart';
import 'package:hzn_gyms/src/features/auth/domain/user.dart';
import 'package:hzn_gyms/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:hzn_gyms/src/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

const _fakeAuth = AuthState(
  token: 'tok',
  user: User(id: 'u1', name: 'Test User', email: 'cashier@test.com', verified: true),
);

/// Mirrors the real [AuthController.login] transition (loading -> data/error)
/// without touching the network.
class _FakeAuthController extends AuthController {
  _FakeAuthController({
    this.shouldFailLogin = false,
    this.shouldFailOtp = false,
    this.otpId = 'otp-test',
  });

  final bool shouldFailLogin;
  final bool shouldFailOtp;
  final String otpId;
  int requestOtpCalls = 0;

  @override
  Future<AuthState?> build() async => null;

  @override
  Future<bool> login(String email, String password) async {
    state = const AsyncLoading();
    await Future<void>.delayed(Duration.zero);
    if (shouldFailLogin) {
      state = AsyncError(Exception('bad credentials'), StackTrace.current);
      return false;
    }
    state = const AsyncData(_fakeAuth);
    return true;
  }

  @override
  Future<String?> requestOtp(String email) async {
    requestOtpCalls++;
    await Future<void>.delayed(Duration.zero);
    return otpId;
  }

  @override
  Future<bool> loginWithOtp(String otpId, String code) async {
    state = const AsyncLoading();
    await Future<void>.delayed(Duration.zero);
    if (shouldFailOtp) {
      state = AsyncError(
        const AuthFailure('Invalid or expired OTP', null, 'otp_invalid'),
        StackTrace.current,
      );
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
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const Text('FORGOT'),
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
      appName: 'hzn_gyms',
      packageName: 'com.test.hzn_gyms',
      version: '1.0.0',
      buildNumber: '1',
    ),
  ),
  outboxPendingCountProvider.overrideWith((ref) => Stream.value(0)),
];

Future<void> _continueWithEmail(WidgetTester tester, String email) async {
  await tester.enterText(find.byType(TextField).at(0), email);
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
}

Future<void> _fillAndSubmit(WidgetTester tester) async {
  await _continueWithEmail(tester, 'cashier@test.com');
  await tester.enterText(find.byType(TextField).at(0), 'secret123');
  await tester.tap(find.text('Login'));
  await tester.pumpAndSettle();
}

void main() {
  group('LoginPage', () {
    testWidgets('shows generic app branding before sign-in', (tester) async {
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

      expect(find.text('HZN Gyms [Dev]'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

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
            () => _FakeAuthController(shouldFailLogin: true),
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

      expect(find.text('Invalid email or password.'), findsOneWidget);
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('DASHBOARD'), findsNothing);
    });

    testWidgets('email then OTP verify navigates on success', (tester) async {
      final fake = _FakeAuthController();
      final container = ProviderContainer(
        overrides: [
          ..._baseOverrides(),
          authControllerProvider.overrideWith(() => fake),
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

      await _continueWithEmail(tester, 'cashier@test.com');
      expect(find.text('cashier@test.com'), findsOneWidget);

      await tester.tap(find.text('Sign in with email code'));
      await tester.pumpAndSettle();

      expect(fake.requestOtpCalls, 1);
      expect(find.text('Verify code'), findsOneWidget);
      expect(
        find.text('We sent a login code to cashier@test.com'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextField).at(0), '123456');
      await tester.tap(find.text('Verify code'));
      await tester.pumpAndSettle();

      expect(find.text('DASHBOARD'), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
    });

    testWidgets('invalid OTP shows login-code error not credentials', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          ..._baseOverrides(),
          authControllerProvider.overrideWith(
            () => _FakeAuthController(shouldFailOtp: true),
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

      await _continueWithEmail(tester, 'cashier@test.com');
      await tester.tap(find.text('Sign in with email code'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), '000000');
      await tester.tap(find.text('Verify code'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid or expired login code.'), findsOneWidget);
      expect(find.text('Invalid email or password.'), findsNothing);
      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}
