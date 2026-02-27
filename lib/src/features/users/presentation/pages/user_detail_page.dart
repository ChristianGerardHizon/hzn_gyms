import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/routing/routes/users.routes.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../domain/user.dart';
import '../../domain/user_tab.dart';
import '../controllers/paginated_users_controller.dart';
import '../controllers/user_provider.dart';
import '../widgets/dialogs/edit_user_dialog.dart';
import '../widgets/tabs/user_details_tab.dart';
import '../widgets/tabs/user_overview_tab.dart';

/// User detail page with tabbed content.
///
/// Shows user info across 2 tabs:
/// - Overview: Brief summary with key info
/// - Details: Full user information
class UserDetailPage extends HookConsumerWidget {
  const UserDetailPage({
    super.key,
    required this.userId,
    this.initialTab = UserTab.overview,
  });

  final String userId;
  final UserTab initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider(userId));

    final tabController = useTabController(
      initialLength: 2,
      initialIndex: initialTab.index,
    );
    final isTablet = Breakpoints.isTabletOrLarger(context);
    final t = Translations.of(context);

    return userAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          leading: isTablet
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => const UsersRoute().go(context),
                ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('Error loading user: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(userProvider(userId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (user) {
        if (user == null) {
          return Scaffold(
            appBar: AppBar(
              leading: isTablet
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => const UsersRoute().go(context),
                    ),
            ),
            body: const Center(
              child: Text('User not found'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: !isTablet,
            leading: isTablet
                ? null
                : IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => const UsersRoute().go(context),
                  ),
            title: Text('${user.name} - ${user.displayRole}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  ref.invalidate(userProvider(userId));
                  showInfoSnackBar(
                    context,
                    message: 'Refreshing...',
                    duration: const Duration(seconds: 1),
                  );
                },
                tooltip: 'Refresh',
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditUserDialog(context, user),
                tooltip: t.common.edit,
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showMoreOptions(context, ref, user),
              ),
            ],
            bottom: TabBar(
              controller: tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Details'),
              ],
            ),
          ),
          body: TabBarView(
            controller: tabController,
            children: [
              UserOverviewTab(user: user),
              UserDetailsTab(user: user),
            ],
          ),
        );
      },
    );
  }

  void _showEditUserDialog(BuildContext context, User user) {
    showEditUserDialog(context, user);
  }

  void _showMoreOptions(BuildContext context, WidgetRef ref, User user) {
    final t = Translations.of(context);

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('More Options'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _showResetPasswordDialog(context, ref, user);
            },
            child: const ListTile(
              leading: Icon(Icons.lock_reset),
              title: Text('Reset Password'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _showToggleVerificationDialog(context, ref, user);
            },
            child: ListTile(
              leading: Icon(
                user.verified ? Icons.verified : Icons.verified_outlined,
                color: user.verified ? Colors.green : null,
              ),
              title: Text(user.verified ? 'Mark as Unverified' : 'Mark as Verified'),
              subtitle: Text(user.verified
                  ? 'Remove verification status'
                  : 'Manually verify this user\'s account'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context, ref, user);
            },
            child: ListTile(
              leading:
                  Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
              title: Text(t.common.delete,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.error)),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(
      BuildContext context, WidgetRef ref, User user) {
    final t = Translations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Text('Are you sure you want to reset the password for ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.common.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              showWarningSnackBar(context, message: 'Password reset functionality coming soon');
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showToggleVerificationDialog(
      BuildContext context, WidgetRef ref, User user) {
    final t = Translations.of(context);
    final newStatus = !user.verified;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(newStatus ? 'Verify User' : 'Unverify User'),
        content: Text(newStatus
            ? 'Are you sure you want to mark ${user.name} as verified?'
            : 'Are you sure you want to remove verification status from ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.common.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);

              final updatedUser = user.copyWith(verified: newStatus);
              final success = await ref
                  .read(paginatedUsersControllerProvider.notifier)
                  .updateUser(updatedUser);

              if (context.mounted) {
                if (success) {
                  // Refresh user detail page
                  ref.invalidate(userProvider(userId));
                  showSuccessSnackBar(
                    context,
                    message: newStatus
                        ? '${user.name} has been marked as verified'
                        : '${user.name} has been marked as unverified',
                  );
                } else {
                  showErrorSnackBar(
                    context,
                    message: 'Failed to update verification status',
                  );
                }
              }
            },
            child: Text(newStatus ? 'Verify' : 'Unverify'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, User user) {
    final t = Translations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.common.delete),
        content: Text('Are you sure you want to delete ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.common.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(paginatedUsersControllerProvider.notifier)
                  .deleteUser(user.id);
              if (context.mounted) {
                if (success) {
                  const UsersRoute().go(context);
                  showSuccessSnackBar(context, message: 'User deleted');
                } else {
                  showErrorSnackBar(context, message: 'Failed to delete user');
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(t.common.delete),
          ),
        ],
      ),
    );
  }
}
