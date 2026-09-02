import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/routing/routes/users.routes.dart';
import '../../../../core/widgets/state/error_state.dart';
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
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.navigation.users)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreateUserDialog(context),
        tooltip: 'Add User',
        child: const Icon(Icons.add),
      ),
      body: paginatedAsync.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorState.fromError(
          error,
          onRetry: () => ref
              .read(paginatedUsersControllerProvider.notifier)
              .refresh(),
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
