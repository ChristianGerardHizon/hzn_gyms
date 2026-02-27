import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/memberships/presentation/pages/membership_detail_page.dart';
import '../../../features/memberships/presentation/pages/memberships_list_page.dart';
import '../../../features/memberships/presentation/pages/memberships_shell.dart';
import '../../utils/breakpoints.dart';

part 'memberships.routes.g.dart';

/// Memberships shell route for master-detail layout.
///
/// On tablet: Shows list and detail side-by-side
/// On mobile: Shows list, then navigates to detail
@TypedShellRoute<MembershipsShellRoute>(
  routes: [
    TypedGoRoute<MembershipsRoute>(
      path: MembershipsRoute.path,
      routes: [
        TypedGoRoute<MembershipDetailRoute>(path: ':id'),
      ],
    ),
  ],
)
class MembershipsShellRoute extends ShellRouteData {
  const MembershipsShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return MembershipsShell(child: navigator);
  }
}

/// Memberships list page route.
class MembershipsRoute extends GoRouteData with $MembershipsRoute {
  const MembershipsRoute();

  static const path = '/memberships';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    if (Breakpoints.isTabletOrLarger(context)) {
      return const SizedBox.shrink();
    }
    return const MembershipsListPage();
  }
}

/// Membership detail page route.
class MembershipDetailRoute extends GoRouteData with $MembershipDetailRoute {
  const MembershipDetailRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return MembershipDetailPage(membershipId: id);
  }
}
