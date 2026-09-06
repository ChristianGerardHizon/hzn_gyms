import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../features/users/presentation/controllers/user_roles_controller.dart';
import '../../../features/users/presentation/pages/user_roles_page.dart';
import '../../../features/users/presentation/widgets/user_role_detail_panel.dart';
import '../../widgets/state/error_state.dart';

part 'roles.routes.g.dart';

/// Top-level route for user roles management.
@TypedGoRoute<RolesRoute>(
  path: RolesRoute.path,
  routes: [
    TypedGoRoute<RoleDetailRoute>(path: ':id'),
  ],
)
class RolesRoute extends GoRouteData with $RolesRoute {
  const RolesRoute();

  static const path = '/roles';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const UserRolesPage();
  }
}

/// Role detail page route (mobile push / deep link).
class RoleDetailRoute extends GoRouteData with $RoleDetailRoute {
  const RoleDetailRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return _RoleDetailPage(roleId: id);
  }
}

class _RoleDetailPage extends ConsumerWidget {
  const _RoleDetailPage({required this.roleId});

  final String roleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(userRolesControllerProvider);

    return rolesAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: ErrorState.fromError(
          error,
          compact: true,
          onRetry: () =>
              ref.read(userRolesControllerProvider.notifier).refresh(),
        ),
      ),
      data: (roles) {
        final role = roles.cast().firstWhere(
              (r) => r.id == roleId,
              orElse: () => null,
            );

        if (role == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Role not found')),
          );
        }

        return UserRoleDetailPanel(role: role);
      },
    );
  }
}
