import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/members/presentation/pages/member_detail_page.dart';
import '../../../features/members/presentation/pages/members_list_page.dart';
import '../../../features/members/presentation/pages/members_shell.dart';
import '../../utils/breakpoints.dart';

part 'members.routes.g.dart';

/// Members shell route for master-detail layout.
///
/// On tablet: Shows list and detail side-by-side
/// On mobile: Shows list, then navigates to detail
@TypedShellRoute<MembersShellRoute>(
  routes: [
    TypedGoRoute<MembersRoute>(
      path: MembersRoute.path,
      routes: [
        TypedGoRoute<MemberDetailRoute>(path: ':id'),
      ],
    ),
  ],
)
class MembersShellRoute extends ShellRouteData {
  const MembersShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return MembersShell(child: navigator);
  }
}

/// Members list page route.
class MembersRoute extends GoRouteData with $MembersRoute {
  const MembersRoute();

  static const path = '/members';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    // On tablet, this is handled by the shell - return empty container
    // On mobile, this shows the list page
    if (Breakpoints.isTabletOrLarger(context)) {
      return const SizedBox.shrink();
    }
    return const MembersListPage();
  }
}

/// Member detail page route.
class MemberDetailRoute extends GoRouteData with $MemberDetailRoute {
  const MemberDetailRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return MemberDetailPage(memberId: id);
  }
}
