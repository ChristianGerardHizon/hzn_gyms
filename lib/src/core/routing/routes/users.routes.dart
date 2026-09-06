import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/users/domain/user_tab.dart';
import '../../../features/users/presentation/pages/user_detail_page.dart';
import '../../../features/users/presentation/pages/users_list_page.dart';
import '../../../features/users/presentation/pages/users_shell.dart';
import '../../utils/breakpoints.dart';

part 'users.routes.g.dart';

/// Users shell route for master-detail layout.
///
/// On tablet: Shows list and detail side-by-side
/// On mobile: Shows list, then navigates to detail
@TypedShellRoute<UsersShellRoute>(
  routes: [
    TypedGoRoute<UsersRoute>(
      path: UsersRoute.path,
      routes: [
        TypedGoRoute<UserDetailRoute>(path: ':id'),
      ],
    ),
  ],
)
class UsersShellRoute extends ShellRouteData {
  const UsersShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return UsersShell(child: navigator);
  }
}

/// Users list page route.
class UsersRoute extends GoRouteData with $UsersRoute {
  const UsersRoute();

  static const path = '/users';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    // On tablet, this is handled by the shell - return empty container
    // On mobile, this shows the list page
    if (Breakpoints.isTabletOrLarger(context)) {
      return const SizedBox.shrink();
    }
    return const UsersListPage();
  }
}

/// User detail page route.
class UserDetailRoute extends GoRouteData with $UserDetailRoute {
  const UserDetailRoute({required this.id, this.tab});

  final String id;
  final String? tab;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final tabName = state.uri.queryParameters['tab'];
    return UserDetailPage(
      userId: id,
      initialTab: UserTab.fromString(tabName),
    );
  }
}

