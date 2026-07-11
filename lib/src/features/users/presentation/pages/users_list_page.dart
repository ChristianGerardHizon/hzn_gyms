import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/routing/routes/users.routes.dart';
import '../controllers/paginated_users_controller.dart';
import '../widgets/dialogs/create_user_dialog.dart';
import '../widgets/user_list_panel.dart';

/// Users list page for mobile view.
///
/// Shows the user list panel and navigates to detail on tap.
class UsersListPage extends ConsumerWidget {
  const UsersListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginatedAsync = ref.watch(paginatedUsersControllerProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreateUserDialog(context),
        tooltip: 'Add User',
        child: const Icon(Icons.add),
      ),
      body: paginatedAsync.when(
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
                onPressed: () => ref
                    .read(paginatedUsersControllerProvider.notifier)
                    .refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (paginatedState) => UserListPanel(
          paginatedState: paginatedState,
          selectedId: null,
          onUserTap: (user) {
            UserDetailRoute(id: user.id).push(context);
          },
          onRefresh: () =>
              ref.read(paginatedUsersControllerProvider.notifier).refresh(),
          onLoadMore: () =>
              ref.read(paginatedUsersControllerProvider.notifier).loadMore(),
        ),
      ),
    );
  }
}
