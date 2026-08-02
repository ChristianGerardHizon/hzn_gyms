import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../pages/app_root.dart';
import '../permissions/current_user_permissions.dart';
import 'pending_redirect_provider.dart';
import 'router_utils.dart';
import 'routes/auth.routes.dart';
import 'routes/check_in.routes.dart';
import 'routes/dashboard.routes.dart';
import 'routes/organization.routes.dart';
import 'routes/outbox.routes.dart';
import 'routes/products.routes.dart';
import 'routes/members.routes.dart';
import 'routes/memberships.routes.dart';
import 'routes/profile.routes.dart';
import 'routes/sales.routes.dart';
import 'routes/sales_history.routes.dart';
import 'routes/reports.routes.dart';
import 'routes/system.routes.dart';

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
  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: SplashRoute.path,
    debugLogDiagnostics: true,
    redirect: (context, state) => RouterUtils.redirect(context, state, ref),
    errorBuilder: RouterUtils.errorBuilder,
    routes: [
      // Auth routes (outside shell)
      $splashRoute,
      $loginRoute,
      $forgotPasswordRoute,
      $authLoadingRoute,

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
          $organizationShellRoute,
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

        if (isAuthenticated &&
            (location == LoginRoute.path || location == SplashRoute.path)) {
          final pendingUrl = ref
              .read(pendingRedirectProvider.notifier)
              .consume();
          router.go(pendingUrl ?? DashboardRoute.path);
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

  return router;
}
