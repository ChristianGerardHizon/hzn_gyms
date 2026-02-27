import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../pages/app_root.dart';
import 'router_utils.dart';
import 'routes/auth.routes.dart';
import 'routes/check_in.routes.dart';
import 'routes/dashboard.routes.dart';
import 'routes/organization.routes.dart';
import 'routes/products.routes.dart';
import 'routes/members.routes.dart';
import 'routes/memberships.routes.dart';
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
          $systemShellRoute,
        ],
      ),
    ],
  );

  // Listen to auth state changes and refresh router to re-evaluate redirects
  ref.listen(authControllerProvider, (previous, next) {
    // Refresh router when auth state changes (loading -> data/error)
    // This triggers redirect logic to navigate after login success/failure
    router.refresh();
  });

  return router;
}
