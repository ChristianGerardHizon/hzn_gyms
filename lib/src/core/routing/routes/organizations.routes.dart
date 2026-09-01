import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/organizations/presentation/pages/organizations_page.dart';

part 'organizations.routes.g.dart';

/// Organizations management route (super-admin).
@TypedGoRoute<OrganizationsRoute>(path: OrganizationsRoute.path)
class OrganizationsRoute extends GoRouteData with $OrganizationsRoute {
  const OrganizationsRoute();

  static const path = '/organizations';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const OrganizationsPage();
  }
}
