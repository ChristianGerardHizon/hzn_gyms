import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/settings/presentation/pages/branches_page.dart';
import '../../../features/settings/presentation/pages/branches_shell.dart';
import '../../../features/settings/presentation/widgets/branch_detail_panel.dart';
import '../../utils/breakpoints.dart';

part 'branches.routes.g.dart';

/// Branches shell route for master-detail layout.
@TypedShellRoute<BranchesShellRoute>(
  routes: [
    TypedGoRoute<BranchesRoute>(
      path: BranchesRoute.path,
      routes: [
        TypedGoRoute<BranchDetailRoute>(path: ':id'),
      ],
    ),
  ],
)
class BranchesShellRoute extends ShellRouteData {
  const BranchesShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return BranchesShell(child: navigator);
  }
}

/// Branches list page route.
class BranchesRoute extends GoRouteData with $BranchesRoute {
  const BranchesRoute();

  static const path = '/branches';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    if (Breakpoints.isTabletOrLarger(context)) {
      return const SizedBox.shrink();
    }
    return const BranchesPage();
  }
}

/// Branch detail page route.
class BranchDetailRoute extends GoRouteData with $BranchDetailRoute {
  const BranchDetailRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BranchDetailPanel(branchId: id);
  }
}
