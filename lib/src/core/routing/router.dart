import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../packages/sentry/sentry_config.dart';
import '../pages/app_root.dart';
import '../pages/platform_root.dart';
import '../permissions/current_user_permissions.dart';
import 'pending_redirect_provider.dart';
import 'router_utils.dart';
import 'routes/auth.routes.dart';
import 'routes/branches.routes.dart';
import 'routes/check_in.routes.dart';
import 'routes/dashboard.routes.dart';
import 'routes/outbox.routes.dart';
import 'routes/products.routes.dart';
import 'routes/members.routes.dart';
import 'routes/memberships.routes.dart';
import 'routes/organizations.routes.dart';
import 'routes/profile.routes.dart';
import 'routes/sales.routes.dart';
import 'routes/sales_history.routes.dart';
import 'routes/reports.routes.dart';
import 'routes/roles.routes.dart';
import 'routes/platform.routes.dart';
import 'routes/system.routes.dart';
import 'routes/users.routes.dart';

part 'router.g.dart';

/// Global navigator key for root navigation.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Global ScaffoldMessenger key for showing snackbars on root scaffold.
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Provides the GoRouter instance for the application.
///
/// Configured with auth redirects and error handling.
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  // On web refresh, capture the browser URL before auth forces splash so
  // [RouterUtils.redirect] can restore it even if the first match is /splash.
  _stashWebDeepLinkIfNeeded();

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: SplashRoute.path,
    debugLogDiagnostics: true,
    observers: [if (isSentryEnabled) SentryNavigatorObserver()],
    redirect: (context, state) => RouterUtils.redirect(context, state, ref),
    errorBuilder: RouterUtils.errorBuilder,
    routes: [
      // Auth routes (outside shell)
      $splashRoute,
      $loginRoute,
      $forgotPasswordRoute,
      $authLoadingRoute,

      // Legacy org path redirect
      $organizationsRoute,

      // Platform super-admin shell
      $platformShellRoute,

      // Main app shell with navigation
      ShellRoute(
        builder: (context, state, child) => AppRoot(child: child),
        routes: [
          $dashboardRoute,
          $checkInRoute,
          $productsShellRoute,
          $membersShellRoute,
          $membershipsShellRoute,
          $salesRoute,
          $salesShellRoute,
          $reportsRoute,
          $usersShellRoute,
          $rolesRoute,
          $branchesShellRoute,
          $profileRoute,
          $outboxRoute,
          $systemShellRoute,
        ],
      ),
    ],
  );

  // Listen to auth state changes: navigate explicitly on login/logout and
  // refresh redirect guards for permission changes.
  ref.listen(authControllerProvider, (previous, next) {
    final wasAuthenticated = previous?.value != null;
    final isAuthenticated =
        next.value != null && !next.isLoading && !next.hasError;

    if (wasAuthenticated != isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Avoid router.state: it throws StateError when matches are empty
        // (e.g. go_router error pages for unknown URLs). See EBEGYM-1.
        final location = RouterUtils.currentLocation(router);
        if (location.isEmpty) return;

        if (isAuthenticated && location == LoginRoute.path) {
          // Login success: restore deep link or go home.
          final pendingUrl = ref
              .read(pendingRedirectProvider.notifier)
              .consume();
          if (pendingUrl != null) {
            router.go(pendingUrl);
            return;
          }
          final perms = ref.read(currentUserPermissionsProvider).value;
          if (perms?.canManageOrganizations ?? false) {
            router.go(PlatformDashboardRoute.path);
          } else {
            router.go(DashboardRoute.path);
          }
        } else if (isAuthenticated && location == SplashRoute.path) {
          // Do not router.go(Dashboard) here — that races redirect restore and
          // can wipe a pending deep link. Let [RouterUtils.redirect] step 3
          // run via refresh() below.
        } else if (!isAuthenticated &&
            !RouterUtils.ignoredRoutes.any(
              (route) => location.startsWith(route),
            )) {
          router.go(LoginRoute.path);
        }
      });
    }

    router.refresh();
  });

  ref.listen(currentUserPermissionsProvider, (previous, next) {
    router.refresh();
  });

  // Auth may finish during GoRouter construction (before listeners attach).
  // Re-run redirects so splash can restore a stashed web deep link.
  Future.microtask(router.refresh);

  return router;
}

void _stashWebDeepLinkIfNeeded() {
  if (!kIsWeb) return;

  final platform = WidgetsBinding.instance.platformDispatcher.defaultRouteName;
  final uri = Uri.tryParse(platform);
  final path = uri?.path ?? platform;
  if (path.isEmpty || path == '/') return;
  if (RouterUtils.ignoredRoutes.any((route) => path.startsWith(route))) {
    return;
  }

  PendingRedirect.stash(uri?.toString() ?? platform);
}
