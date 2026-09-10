import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/organizations/presentation/controllers/current_organization_controller.dart';
import '../../features/organizations/presentation/controllers/organization_memberships_controller.dart';
import '../../features/settings/presentation/controllers/branches_controller.dart';
import '../../features/settings/presentation/controllers/current_branch_controller.dart';
import '../navigation/app_nav_destination.dart';
import '../pages/page_not_found_page.dart';
import '../permissions/current_user_permissions.dart';
import 'pending_redirect_provider.dart';
import 'route_scope_provider.dart';
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
  ///
  /// [DashboardRoute.path] results are prefixed with the resolved
  /// `/orgSlug/branchSlug` scope when available. While org/branch are still
  /// resolving (e.g. right after login), parks on [SplashRoute.path] — bare
  /// `/dashboard` is not a top-level route under the org/branch shell.
  ///
  static String homePathFor(Ref ref) {
    final perms = ref.read(currentUserPermissionsProvider).value;
    if (perms?.canManageOrganizations ?? false) {
      return PlatformDashboardRoute.path;
    }
    final auth = ref.read(currentAuthProvider);
    final linkedOrg = auth?.user.organization;
    if (linkedOrg != null && linkedOrg.isNotEmpty) {
      return _scopedDashboardPath(ref);
    }
    final membershipsAsync = ref.read(organizationMembershipsControllerProvider);
    if (membershipsAsync.hasError || membershipsAsync.isLoading) {
      return _scopedDashboardPath(ref);
    }
    final memberships = membershipsAsync.value;
    if (memberships != null && !memberships.any((m) => m.isActive)) {
      return AwaitingOrganizationRoute.path;
    }
    return _scopedDashboardPath(ref);
  }

  /// [DashboardRoute.path] prefixed with the current org/branch scope, or
  /// [SplashRoute.path] while the scope can't be resolved yet.
  static String _scopedDashboardPath(Ref ref) {
    final prefix = _resolveScopePrefix(ref);
    if (prefix == null) return SplashRoute.path;
    return '$prefix${DashboardRoute.path}';
  }

  /// Resolves `/orgSlug/branchSlug` from the current org/branch controllers,
  /// or null while either is unresolved.
  static String? _resolveScopePrefix(Ref ref) {
    final org = ref.read(currentOrganizationControllerProvider).value;
    if (org == null || org.slug.isEmpty) return null;
    final branchSelection = ref.read(currentBranchControllerProvider).value;
    if (branchSelection == null) return null;
    final branchSlug = branchSelection.isAll
        ? allBranchesSlug
        : branchSelection.branch?.slug;
    if (branchSlug == null || branchSlug.isEmpty) return null;
    return '/${org.slug}/$branchSlug';
  }

  /// Replaces the `/orgSlug/branchSlug` segments of [currentLocation],
  /// preserving everything after them (e.g. switching branch while on
  /// `/acme/downtown/system/product-categories` with `branchSlug: 'all'`
  /// yields `/acme/all/system/product-categories`, not a bounce to
  /// dashboard). Returns [currentLocation] unchanged if it doesn't start
  /// with two path segments.
  static String replaceScopeSegment(
    String currentLocation, {
    String? orgSlug,
    String? branchSlug,
  }) {
    final segments = currentLocation.split('/');
    // ['', orgSlug, branchSlug, ...rest]
    if (segments.length < 3) return currentLocation;
    if (orgSlug != null) segments[1] = orgSlug;
    if (branchSlug != null) segments[2] = branchSlug;
    return segments.join('/');
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

  /// True for `/` or an empty path (no registered top-level route).
  static bool isEmptyRootPath(String path) => path.isEmpty || path == '/';

  /// Global redirect function for auth guards.
  ///
  /// Redirects unauthenticated users to login and
  /// authenticated users away from login pages.
  /// Preserves deep link URLs on web by storing them during auth loading.
  static Future<String?> redirect(
    BuildContext context,
    GoRouterState state,
    Ref ref,
  ) async {
    final currentPath = state.matchedLocation;
    // Prefer uri.path for unmatched URLs — matchedLocation is often empty
    // on the error/404 path, which would skip flat-path rewrites.
    final uriPath = state.uri.path;
    final fullUri = state.uri.toString();

    // Legacy organization nested paths → top-level users/roles/branches.
    final legacyOrgRedirect = legacyOrganizationRedirect(uriPath);
    if (legacyOrgRedirect != null) {
      return legacyOrgRedirect;
    }

    // Legacy /organizations → platform org list.
    if (uriPath == OrganizationsRoute.path) {
      return PlatformOrganizationsRoute.path;
    }

    // Legacy bookmark/deep link → nested records route.
    // Use uri.path: unmatched locations may not set matchedLocation.
    if (uriPath == legacyCheckInRecordsPath) {
      return CheckInRecordsRoute.path;
    }

    // Cashier is dashboard-dialog only — redirect standalone /cashier.
    if (uriPath == SalesRoute.path) {
      return homePathFor(ref);
    }

    // Check if this route should skip auth check
    final isIgnored = ignoredRoutes.any(
      (route) => currentPath.startsWith(route) || uriPath.startsWith(route),
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

    // Bare `/` (or empty) is not a registered route under the org/branch
    // shell — send users to splash/login/home instead of the 404 page.
    if (isEmptyRootPath(uriPath)) {
      if (isAuthLoading) return SplashRoute.path;
      if (!isAuthenticated) return LoginRoute.path;
      if (!isVerified) return VerifyEmailRoute.path;
      return homePathFor(ref);
    }

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
        return homePathFor(ref);
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

    final perms = ref.read(currentUserPermissionsProvider).value;
    final isPlatformAdmin = perms?.canManageOrganizations ?? false;

    // 5d. Flat legacy main-app path (no org/branch prefix) → rewrite to the
    // scoped equivalent using the currently-resolved org/branch. Preserves
    // old bookmarks / not-yet-updated internal navigation. Platform routes
    // never get this prefix — they're excluded by not appearing in
    // [allAppNavDestinations]. Applies to platform admins too (unlike 5e) —
    // this only rewrites using whatever org/branch is already resolved, it
    // never switches tenants, so it's safe regardless of role.
    //
    // Use [uriPath] (not matchedLocation): bare `/dashboard` does not match
    // any top-level route under the org/branch shell, so matchedLocation is
    // empty on the way to errorBuilder and would skip this rewrite.
    if (isAuthenticated &&
        isVerified &&
        !isIgnored &&
        state.pathParameters['orgSlug'] == null &&
        allAppNavDestinations.any((d) => matchesRoutePath(uriPath, d.path))) {
      final prefix = _resolveScopePrefix(ref);
      if (prefix != null) {
        return state.uri.replace(path: '$prefix$uriPath').toString();
      }
      // Still resolving org/branch — park on splash so go_router does not
      // treat the unmatched flat path as a 404. Org/branch listeners refresh
      // the router once the scope is known.
      return SplashRoute.path;
    }

    // 5e. Validate an already-scoped URL's org/branch segments against what
    // this user may actually access. Org is validated/self-healing only —
    // never a trigger to switch tenants from a bare URL (that requires a
    // server-side `users.organization` patch; see
    // [CurrentOrganizationController.switchOrganization]). Branch may
    // safely be sourced from the URL (no server patch involved), so once
    // validated it's published to [currentRouteScopeProvider] and
    // [CurrentBranchController] follows it.
    if (isAuthenticated &&
        isVerified &&
        !isIgnored &&
        !isPlatformAdmin &&
        state.pathParameters['orgSlug'] != null) {
      final orgSlug = state.pathParameters['orgSlug']!;
      final branchSlug = state.pathParameters['branchSlug']!;

      final orgAsync = ref.read(currentOrganizationControllerProvider);
      if (orgAsync.isLoading) return null;
      final org = orgAsync.value;
      if (org == null || org.slug != orgSlug) {
        final prefix = _resolveScopePrefix(ref);
        if (prefix == null) return null;
        // currentPath already carries the wrong org/branch segments — strip
        // them before prepending the resolved (correct) prefix, or this
        // would double up into `/rightOrg/rightBranch/wrongOrg/wrongBranch/...`.
        final wrongPrefixLength = '/$orgSlug/$branchSlug'.length;
        final suffix = currentPath.substring(wrongPrefixLength);
        return state.uri.replace(path: '$prefix$suffix').toString();
      }

      final branchesAsync = ref.read(branchesControllerProvider);
      if (branchesAsync.isLoading) return null;
      final orgBranches = branchesAsync.value ?? const [];

      bool branchValid;
      if (branchSlug == allBranchesSlug) {
        branchValid = await ref
            .read(currentBranchControllerProvider.notifier)
            .canViewAllBranches();
      } else {
        final match = orgBranches
            .where((b) => b.slug == branchSlug)
            .firstOrNull;
        if (match == null) {
          branchValid = false;
        } else {
          final allowedIds = await ref
              .read(currentBranchControllerProvider.notifier)
              .switchableBranchIds();
          branchValid = allowedIds.contains(match.id);
        }
      }

      if (!branchValid) {
        return homePathFor(ref);
      }

      ref.read(currentRouteScopeProvider.notifier).set(orgSlug, branchSlug);
    }

    // 6. Role permission guards for authenticated shell routes
    if (isAuthenticated && !isIgnored) {
      if (perms == null) {
        // Wait for permissions. Do not redirect sensitive paths to the
        // dashboard — that permanently loses deep links on web refresh
        // (e.g. /system/printers). AppRoot hides admin nav while loading;
        // once perms resolve, canAccessPath / AppRoot kick unauthorized users.
        return null;
      }
      final scopePrefixLength = state.pathParameters['orgSlug'] != null
          ? '/${state.pathParameters['orgSlug']}/${state.pathParameters['branchSlug']}'
              .length
          : 0;
      final unscopedPath = currentPath.substring(scopePrefixLength);
      if (!canAccessPath(
        unscopedPath.isEmpty ? DashboardRoute.path : unscopedPath,
        perms,
      )) {
        final prefix = currentPath.substring(0, scopePrefixLength);
        return '$prefix${fallbackPathFor(perms)}';
      }
    }

    // No redirect needed
    return null;
  }

  /// Error page builder for unknown routes.
  ///
  /// Auto-redirects to the resolved home path when it differs from the
  /// current URI (so `/` / typos land on dashboard instead of a dead-end
  /// 404). Falls back to a manual "Go Home" page only when home cannot be
  /// resolved to something better than the current location.
  ///
  /// Uses [_errorPageHomePath] (via a [Consumer]) rather than a bare
  /// `DashboardRoute().go(context)` since an error page has no guaranteed
  /// org/branch route scope to build a `.goScoped` navigation from.
  static Widget errorBuilder(BuildContext context, GoRouterState state) {
    return Consumer(
      builder: (context, ref, _) {
        final home = _errorPageHomePath(ref);
        final current = state.uri.path;
        // Avoid a redirect loop when home itself is still an unmatched flat
        // path (e.g. bare `/dashboard` before org/branch scope resolves).
        if (home != current) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go(home);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return PageNotFoundPage(
          attemptedPath: current,
          onGoHome: () => context.go(home),
        );
      },
    );
  }

  /// Same resolution as [homePathFor], duplicated against [WidgetRef]
  /// (unrelated to [Ref] in this riverpod version) since [errorBuilder] has
  /// no ambient provider [Ref] to call the shared version with.
  static String _errorPageHomePath(WidgetRef ref) {
    final perms = ref.read(currentUserPermissionsProvider).value;
    if (perms?.canManageOrganizations ?? false) {
      return PlatformDashboardRoute.path;
    }
    final org = ref.read(currentOrganizationControllerProvider).value;
    final branchSelection = ref.read(currentBranchControllerProvider).value;
    if (org != null && org.slug.isNotEmpty && branchSelection != null) {
      final branchSlug = branchSelection.isAll
          ? allBranchesSlug
          : branchSelection.branch?.slug;
      if (branchSlug != null && branchSlug.isNotEmpty) {
        return '/${org.slug}/$branchSlug${DashboardRoute.path}';
      }
    }
    // Park on splash while scope resolves — bare `/dashboard` is unmatched.
    return SplashRoute.path;
  }
}
