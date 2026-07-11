import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/routing/routes/users.routes.dart';
import '../controllers/paginated_users_controller.dart';
import 'dialogs/create_user_dialog.dart';
import 'empty_user_detail_state.dart';
import 'user_list_panel.dart';

/// Two-pane tablet layout for users.
///
/// Left pane: User list with search
/// Right pane: User detail from router or empty state
class TabletUsersLayout extends ConsumerWidget {
  const TabletUsersLayout({super.key, required this.detailChild});

  /// The detail panel content from the router.
  final Widget detailChild;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(paginatedUsersControllerProvider);
    final usersController = ref.read(paginatedUsersControllerProvider.notifier);

    // Get selected user ID from current route
    final routerState = GoRouterState.of(context);
    final selectedUserId = routerState.pathParameters['id'];

    // Check if we're on the roles page
    final isRolesPage = routerState.uri.path.endsWith('/roles');

    if (isRolesPage) {
      return detailChild;
    }

    return Row(
      children: [
        // List panel
        SizedBox(
          width: 320,
          child: Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () => showCreateUserDialog(context),
              tooltip: 'Add User',
              child: const Icon(Icons.add),
            ),
            body: usersAsync.when(
              skipLoadingOnReload: true,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    Text('Error: ${error.toString()}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => usersController.refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (paginatedState) => UserListPanel(
                paginatedState: paginatedState,
                selectedId: selectedUserId,
                onUserTap: (user) {
                  // Navigate using the route - this updates the URL and detail panel
                  UserDetailRoute(id: user.id).go(context);
                },
                onRefresh: () => usersController.refresh(),
                onLoadMore: () => usersController.loadMore(),
              ),
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        // Detail panel from router
        Expanded(
          child: (selectedUserId != null || isRolesPage)
              ? detailChild
              : const EmptyUserDetailState(),
        ),
      ],
    );
  }
}
