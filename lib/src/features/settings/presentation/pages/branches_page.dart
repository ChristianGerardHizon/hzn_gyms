import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/routing/routes/branches.routes.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../../domain/branch.dart';
import '../controllers/branches_controller.dart';
import '../widgets/dialogs/branch_form_dialog.dart';

/// Branches list page with CRUD operations.
class BranchesPage extends ConsumerWidget {
  const BranchesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final branchesAsync = ref.watch(branchesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).navigation.branches),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showBranchFormDialog(context),
        child: const Icon(Icons.add),
      ),
      body: branchesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorState.fromError(
          error,
          onRetry: () =>
              ref.read(branchesControllerProvider.notifier).refresh(),
        ),
        data: (branches) {
          if (branches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No branches yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add a branch',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(branchesControllerProvider.notifier).refresh(),
            child: ListView.builder(
              itemCount: branches.length,
              itemBuilder: (context, index) {
                final branch = branches[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.store_outlined,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(branch.name),
                  subtitle: Text(
                    branch.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) =>
                        _handleAction(context, ref, value, branch),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Edit'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete_outlined),
                          title: Text('Delete'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                  onTap: () => BranchDetailRoute(id: branch.id).push(context),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _handleAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    Branch branch,
  ) {
    switch (action) {
      case 'edit':
        showBranchFormDialog(context, branch: branch);
        break;
      case 'delete':
        _showDeleteConfirmation(context, ref, branch);
        break;
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Branch branch,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Branch'),
        content: Text('Are you sure you want to delete "${branch.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref
                  .read(branchesControllerProvider.notifier)
                  .deleteBranch(branch.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
