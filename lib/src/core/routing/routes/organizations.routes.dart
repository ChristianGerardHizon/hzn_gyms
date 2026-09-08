import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/organizations/presentation/pages/awaiting_organization_page.dart';
import '../../../features/organizations/presentation/pages/organizations_page.dart';

part 'organizations.routes.g.dart';

/// Legacy redirect: `/organizations` → `/platform/organizations`.
@TypedGoRoute<OrganizationsRoute>(path: OrganizationsRoute.path)
class OrganizationsRoute extends GoRouteData with $OrganizationsRoute {
  const OrganizationsRoute();

  static const path = '/organizations';

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    return '/platform/organizations';
  }

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const OrganizationsPage();
  }
}

/// Signed-in users with no org membership wait here for an invite.
@TypedGoRoute<AwaitingOrganizationRoute>(path: AwaitingOrganizationRoute.path)
class AwaitingOrganizationRoute extends GoRouteData
    with $AwaitingOrganizationRoute {
  const AwaitingOrganizationRoute();

  static const path = '/awaiting-organization';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AwaitingOrganizationPage();
  }
}
