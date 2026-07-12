import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/state/error_state.dart';
import '../../domain/pos_group.dart';
import '../controllers/pos_groups_controller.dart';
import '../widgets/group_item_picker_dialog.dart';
import '../widgets/pos_group_form_dialog.dart';

/// Settings page for managing POS groups.
///
/// Shows a list of groups for the current branch with reorder, edit, and
/// delete capabilities. Each group can be expanded to show its items.
class CashierGroupsSettingsPage extends ConsumerWidget {
  const CashierGroupsSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final groupsAsync = ref.watch(posGroupsControllerProvider);
    final controller = ref.read(posGroupsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cashier Layout'),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'cashier_groups_fab',
        onPressed: () => showPosGroupFormDialog(context),
        tooltip: 'Add Group',
        child: const Icon(Icons.add),
      ),
      body: groupsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorState.fromError(
          error,
          onRetry: () => controller.refresh(),
        ),
        data: (groups) {
          if (groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.dashboard_customize_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No cashier groups yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create groups to customize the cashier layout',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tap + to create a group',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.refresh(),
            child: ReorderableListView.builder(
              itemCount: groups.length,
              onReorder: (oldIndex, newIndex) {
                final reordered = List<PosGroup>.from(groups);
                if (newIndex > oldIndex) newIndex--;
                final item = reordered.removeAt(oldIndex);
                reordered.insert(newIndex, item);
                controller.reorderGroups(reordered);
              },
              itemBuilder: (context, index) {
                final group = groups[index];
                return _GroupListTile(
                  key: ValueKey(group.id),
                  group: group,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _GroupListTile extends ConsumerWidget {
  const _GroupListTile({
    super.key,
    required this.group,
  });

  final PosGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ExpansionTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(
          Icons.dashboard_customize,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(group.name),
      subtitle: Text(
        '${group.items.length} item${group.items.length == 1 ? '' : 's'}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, ref, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add_items',
                child: ListTile(
                  leading: Icon(Icons.add),
                  title: Text('Add Items'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit Name'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.red),
                  title: Text('Delete', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const Icon(Icons.drag_handle),
        ],
      ),
      children: group.items.isEmpty
          ? [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No items yet. Tap the menu to add products or services.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            ]
          : group.items.map((item) {
              return ListTile(
                contentPadding: const EdgeInsets.only(left: 72, right: 16),
                leading: Icon(
                  item.isProduct
                      ? Icons.inventory_2
                      : Icons.miscellaneous_services,
                  size: 20,
                  color: item.isProduct
                      ? theme.colorScheme.primary
                      : theme.colorScheme.tertiary,
                ),
                title: Text(item.displayName),
                trailing: IconButton(
                  icon: Icon(Icons.remove_circle_outline,
                      color: theme.colorScheme.error, size: 20),
                  onPressed: () async {
                    await ref
                        .read(posGroupsControllerProvider.notifier)
                        .removeItemFromGroup(group.id, item.id);
                  },
                ),
              );
            }).toList(),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'add_items':
        showGroupItemPickerDialog(context, group: group);
      case 'edit':
        showPosGroupFormDialog(
          context,
          groupId: group.id,
          initialName: group.name,
        );
      case 'delete':
        _confirmDelete(context, ref);
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: Text('Delete "${group.name}" and all its item assignments?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref
                  .read(posGroupsControllerProvider.notifier)
                  .deleteGroup(group.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
