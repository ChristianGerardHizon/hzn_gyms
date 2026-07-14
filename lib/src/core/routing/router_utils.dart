import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../navigation/app_nav_destination.dart';
import '../permissions/current_user_permissions.dart';
import 'pending_redirect_provider.dart';
import 'routes/auth.routes.dart';
import 'routes/dashboard.routes.dart';

/// Utility functions for router configuration.
abstract class RouterUtils {
  /// Routes that should not trigger auth redirects.
  static const List<String> ignoredRoutes = [
    '/login',
    '/splash',
    '/auth-loading',
    '/forgot-password',
  ];

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

    // Check if this route should skip auth check
    final isIgnored = ignoredRoutes.any(
      (route) => currentPath.startsWith(route),
    );

    final authAsync = ref.read(authControllerProvider);
    final isAuthenticated = authAsync.value != null;
    final isAuthLoading = authAsync.isLoading;
    final isOnLoginPage = currentPath == LoginRoute.path;
    final isOnSplashPage = currentPath == SplashRoute.path;

    // 1. Still loading auth on splash - stay on splash
    if (isAuthLoading && isOnSplashPage) {
      return SplashRoute.path;
    }

    // 2. Auth loading + protected route - save URL, go to splash
    // This prevents login flash and preserves deep links on web
    if (isAuthLoading && !isIgnored) {
      // Delay state modification to avoid modifying provider during build
      Future(() {
        ref.read(pendingRedirectProvider.notifier).set(fullUri);
      });
      return SplashRoute.path;
    }

    // 3. Splash complete - redirect based on auth result
    if (isOnSplashPage && !isAuthLoading) {
      if (isAuthenticated) {
        // Read pending URL, then clear it after redirect
        final pendingUrl = ref.read(pendingRedirectProvider);
        if (pendingUrl != null) {
          Future(() {
            ref.read(pendingRedirectProvider.notifier).clear();
          });
        }
        return pendingUrl ?? '/';
      }
      return LoginRoute.path;
    }

    // 4. Login page - redirect if authenticated
    if (isOnLoginPage) {
      if (isAuthenticated) {
        // Read pending URL, then clear it after redirect
        final pendingUrl = ref.read(pendingRedirectProvider);
        if (pendingUrl != null) {
          Future(() {
            ref.read(pendingRedirectProvider.notifier).clear();
          });
        }
        return pendingUrl ?? '/';
      }
      return null;
    }

    // 5. Not authenticated + protected route - redirect to login
    if (!isAuthenticated && !isIgnored) {
      return LoginRoute.path;
    }

    // 6. Role permission guards for authenticated shell routes
    if (isAuthenticated && !isIgnored) {
      final permsAsync = ref.read(currentUserPermissionsProvider);
      final perms = permsAsync.value;
      if (perms != null && !canAccessPath(currentPath, perms)) {
        return fallbackPathFor(perms);
      }
    }

    // No redirect needed
    return null;
  }

  /// Error page builder for unknown routes.
  static Widget errorBuilder(BuildContext context, GoRouterState state) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              '404',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
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
