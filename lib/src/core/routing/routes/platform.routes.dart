import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/organizations/presentation/pages/organization_setup_page.dart';
import '../../../features/organizations/presentation/pages/organizations_page.dart';
import '../../../features/organizations/presentation/pages/platform_dashboard_page.dart';
import '../../../features/organizations/presentation/pages/platform_users_page.dart';
import '../../pages/platform_root.dart';

part 'platform.routes.g.dart';

/// Platform admin shell — super-admin tenant management (separate from gym app).
@TypedShellRoute<PlatformShellRoute>(
  routes: [
    TypedGoRoute<PlatformDashboardRoute>(path: PlatformDashboardRoute.path),
    TypedGoRoute<PlatformOrganizationsRoute>(
      path: PlatformOrganizationsRoute.path,
      routes: [
        TypedGoRoute<OrganizationSetupRoute>(path: ':orgId/setup'),
      ],
    ),
    TypedGoRoute<PlatformUsersRoute>(path: PlatformUsersRoute.path),
  ],
)
class PlatformShellRoute extends ShellRouteData {
  const PlatformShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return PlatformRoot(child: navigator);
  }
}

/// Platform home dashboard.
class PlatformDashboardRoute extends GoRouteData with $PlatformDashboardRoute {
  const PlatformDashboardRoute();

  static const path = '/platform';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const PlatformDashboardPage();
  }
}

/// Organization list under platform shell.
class PlatformOrganizationsRoute extends GoRouteData
    with $PlatformOrganizationsRoute {
  const PlatformOrganizationsRoute();

  static const path = '/platform/organizations';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const OrganizationsPage();
  }
}

/// Guided onboarding wizard for a new tenant.
class OrganizationSetupRoute extends GoRouteData with $OrganizationSetupRoute {
  const OrganizationSetupRoute({required this.orgId});

  final String orgId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return OrganizationSetupPage(organizationId: orgId);
  }
}

/// Cross-org users list — toggle platform `superAdmin`.
class PlatformUsersRoute extends GoRouteData with $PlatformUsersRoute {
  const PlatformUsersRoute();

  static const path = '/platform/users';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const PlatformUsersPage();
  }
}
