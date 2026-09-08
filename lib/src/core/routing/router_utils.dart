import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/organizations/presentation/controllers/organization_memberships_controller.dart';
import '../navigation/app_nav_destination.dart';
import '../permissions/current_user_permissions.dart';
import 'pending_redirect_provider.dart';
import 'routes/auth.routes.dart';
import 'routes/check_in.routes.dart';
import 'routes/dashboard.routes.dart';
import 'routes/organizations.routes.dart';
import 'routes/platform.routes.dart';
import 'routes/sales.routes.dart';

/// Utility functions for router configuration.
abstract class RouterUtils {
  /// Routes that should not trigger auth redirects.
  static const List<String> ignoredRoutes = [
    '/login',
    '/splash',
    '/auth-loading',
    '/forgot-password',
    '/verify-email',
    '/confirm-verification',
  ];

  /// Home path for an authenticated, verified user.
  static String homePathFor(Ref ref) {
    final perms = ref.read(currentUserPermissionsProvider).value;
    if (perms?.canManageOrganizations ?? false) {
      return PlatformDashboardRoute.path;
    }
    final auth = ref.read(currentAuthProvider);
    final linkedOrg = auth?.user.organization;
    if (linkedOrg != null && linkedOrg.isNotEmpty) {
      return DashboardRoute.path;
    }
    final membershipsAsync = ref.read(organizationMembershipsControllerProvider);
    if (membershipsAsync.hasError || membershipsAsync.isLoading) {
      return DashboardRoute.path;
    }
    final memberships = membershipsAsync.value;
    if (memberships != null && !memberships.any((m) => m.isActive)) {
      return AwaitingOrganizationRoute.path;
    }
    return DashboardRoute.path;
  }

  /// Former top-level check-in records path (now nested under check-in).
  static const String legacyCheckInRecordsPath = '/check-in-records';

  /// Current path without calling [GoRouter.state], which throws [StateError]
  /// when the match list is empty.
  ///
  /// go_router error configurations (unknown URLs) set `isError` with an empty
  /// `matches` list, so [RouteMatchList.last] / [GoRouter.state] crash. Prefer
  /// [RouteMatchList.lastOrNull] and fall back to the configuration URI.
  static String currentLocation(GoRouter router) {
    final config = router.routerDelegate.currentConfiguration;
    return config.lastOrNull?.matchedLocation ?? config.uri.path;
  }

  /// Former nested organization paths (users/roles/branches under /organization).
  static String? legacyOrganizationRedirect(String path) {
    if (path == '/organization' || path == '/organization/users') {
      return '/users';
    }
    if (path.startsWith('/organization/users/')) {
      final id = path.split('/').elementAtOrNull(3);
      if (id != null && id.isNotEmpty) {
        return '/users/$id';
      }
    }
    if (path == '/organization/roles') {
      return '/roles';
    }
    if (path.startsWith('/organization/roles/')) {
      final id = path.split('/').elementAtOrNull(3);
      if (id != null && id.isNotEmpty) {
        return '/roles/$id';
      }
    }
    if (path == '/organization/branches') {
      return '/branches';
    }
    if (path.startsWith('/organization/branches/')) {
      final id = path.split('/').elementAtOrNull(3);
      if (id != null && id.isNotEmpty) {
        return '/branches/$id';
      }
    }
    return null;
  }

  /// Global redirect function for auth guards.
  ///
  /// Redirects unauthenticated users to login and
  /// authenticated users away from login pages.
  /// Preserves deep link URLs on web by storing them during auth loading.
  static FutureOr<String?> redirect(
    BuildContext context,
    GoRouterState state,
    Ref ref,
  ) {
    final currentPath = state.matchedLocation;
    final fullUri = state.uri.toString();

    // Legacy organization nested paths → top-level users/roles/branches.
    final legacyOrgRedirect = legacyOrganizationRedirect(state.uri.path);
    if (legacyOrgRedirect != null) {
      return legacyOrgRedirect;
    }

    // Legacy /organizations → platform org list.
    if (state.uri.path == OrganizationsRoute.path) {
      return PlatformOrganizationsRoute.path;
    }

    // Legacy bookmark/deep link → nested records route.
    // Use uri.path: unmatched locations may not set matchedLocation.
    if (state.uri.path == legacyCheckInRecordsPath) {
      return CheckInRecordsRoute.path;
    }

    // Cashier is dashboard-dialog only — redirect standalone /cashier.
    if (state.uri.path == SalesRoute.path) {
      return DashboardRoute.path;
    }

    // Check if this route should skip auth check
    final isIgnored = ignoredRoutes.any(
      (route) => currentPath.startsWith(route),
    );

    final authAsync = ref.read(authControllerProvider);
    final isAuthenticated = authAsync.value != null;
    final isAuthLoading = authAsync.isLoading;
    final isVerified = authAsync.value?.isVerified ?? false;
    final isOnLoginPage = currentPath == LoginRoute.path;
    final isOnSplashPage = currentPath == SplashRoute.path;
    final isOnVerifyEmailPage = currentPath == VerifyEmailRoute.path;
    final isOnConfirmVerification = currentPath.startsWith(
      '/confirm-verification',
    );

    // 1. Still loading auth on splash - stay on splash
    if (isAuthLoading && isOnSplashPage) {
      return SplashRoute.path;
    }

    // 2. Auth loading + protected route - save URL, go to splash
    // This prevents login flash and preserves deep links on web.
    // Stash synchronously (safe during redirect/build); sync Riverpod state
    // in a microtask so splash restore cannot race auth completion.
    if (isAuthLoading && !isIgnored) {
      PendingRedirect.stash(fullUri);
      Future(() {
        ref.read(pendingRedirectProvider.notifier).set(fullUri);
      });
      return SplashRoute.path;
    }

    // 3. Splash complete - redirect based on auth result
    if (isOnSplashPage && !isAuthLoading) {
      if (isAuthenticated) {
        if (!isVerified) {
          return VerifyEmailRoute.path;
        }
        // peek() includes eager stash if provider set has not run yet
        final pendingUrl = ref.read(pendingRedirectProvider.notifier).peek();
        if (pendingUrl != null) {
          // Clear synchronously so a racing auth listener cannot also consume
          // (or miss and default to dashboard).
          ref.read(pendingRedirectProvider.notifier).clear();
          return pendingUrl;
        }
        return homePathFor(ref);
      }
      return LoginRoute.path;
    }

    // 4. Login page - redirect if authenticated
    if (isOnLoginPage) {
      if (isAuthenticated) {
        if (!isVerified) {
          return VerifyEmailRoute.path;
        }
        final pendingUrl = ref.read(pendingRedirectProvider.notifier).peek();
        if (pendingUrl != null) {
          ref.read(pendingRedirectProvider.notifier).clear();
          return pendingUrl;
        }
        return homePathFor(ref);
      }
      return null;
    }

    // 4b. Verify-email page
    if (isOnVerifyEmailPage) {
      if (!isAuthenticated) return LoginRoute.path;
      if (isVerified) {
        final pendingUrl = ref.read(pendingRedirectProvider.notifier).peek();
        if (pendingUrl != null) {
          ref.read(pendingRedirectProvider.notifier).clear();
          return pendingUrl;
        }
        return homePathFor(ref);
      }
      return null;
    }

    // 4c. Confirm-verification: require session; verified users leave after success
    if (isOnConfirmVerification) {
      if (!isAuthenticated) return LoginRoute.path;
      if (isVerified) return homePathFor(ref);
      return null;
    }

    final isOnAwaitingOrganization =
        currentPath == AwaitingOrganizationRoute.path;

    // 4d. Invite-required gate
    if (isOnAwaitingOrganization) {
      if (!isAuthenticated) return LoginRoute.path;
      if (!isVerified) return VerifyEmailRoute.path;
      final perms = ref.read(currentUserPermissionsProvider).value;
      if (perms?.canManageOrganizations ?? false) {
        return PlatformDashboardRoute.path;
      }
      final memberships =
          ref.read(organizationMembershipsControllerProvider).value;
      if (memberships != null && memberships.any((m) => m.isActive)) {
        return DashboardRoute.path;
      }
      // Still loading memberships — stay put.
      return null;
    }

    // 5. Not authenticated + protected route - redirect to login
    if (!isAuthenticated && !isIgnored) {
      return LoginRoute.path;
    }

    // 5b. Authenticated but unverified - force verify gate
    if (isAuthenticated && !isVerified && !isIgnored) {
      return VerifyEmailRoute.path;
    }

    // 5c. Authenticated, verified, no org membership / link, not platform admin
    if (isAuthenticated && isVerified && !isIgnored) {
      final perms = ref.read(currentUserPermissionsProvider).value;
      final isPlatform = perms?.canManageOrganizations ?? false;
      if (!isPlatform) {
        final linkedOrg = authAsync.value?.user.organization;
        final hasLinkedOrg = linkedOrg != null && linkedOrg.isNotEmpty;
        if (!hasLinkedOrg) {
          final membershipsAsync =
              ref.read(organizationMembershipsControllerProvider);
          // Do not return early while loading — that would skip permission
          // guards. Invite gate only fires once memberships are known empty.
          if (!membershipsAsync.isLoading &&
              !membershipsAsync.hasError &&
              membershipsAsync.value != null &&
              !membershipsAsync.value!.any((m) => m.isActive)) {
            return AwaitingOrganizationRoute.path;
          }
        }
      }
    }

    // 6. Role permission guards for authenticated shell routes
    if (isAuthenticated && !isIgnored) {
      final permsAsync = ref.read(currentUserPermissionsProvider);
      final perms = permsAsync.value;
      if (perms == null) {
        // Wait for permissions. Do not redirect sensitive paths to the
        // dashboard — that permanently loses deep links on web refresh
        // (e.g. /system/printers). AppRoot hides admin nav while loading;
        // once perms resolve, canAccessPath / AppRoot kick unauthorized users.
        return null;
      }
      if (!canAccessPath(currentPath, perms)) {
        return fallbackPathFor(perms);
      }
    }

    // No redirect needed
    return null;
  }

  /// Error page builder for unknown routes.
  static Widget errorBuilder(BuildContext context, GoRouterState state) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('404', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => const DashboardRoute().go(context),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
