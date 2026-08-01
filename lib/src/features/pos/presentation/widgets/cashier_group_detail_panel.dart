import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/currency_format.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../../domain/pos_group.dart';
import '../../domain/pos_group_item.dart';
import '../controllers/pos_groups_controller.dart';
import 'group_item_picker_dialog.dart';
import 'pos_group_form_dialog.dart';

/// Detail panel for a selected POS group (used in tablet 3-panel layout).
///
/// Shows group info and a list of items with remove actions.
class CashierGroupDetailPanel extends ConsumerWidget {
  const CashierGroupDetailPanel({
    super.key,
    required this.groupId,
  });

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final groupsAsync = ref.watch(posGroupsControllerProvider);

    return groupsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ErrorState.fromError(error, compact: true),
      data: (groups) {
        final group = groups.cast<PosGroup?>().firstWhere(
              (g) => g?.id == groupId,
              orElse: () => null,
            );

        if (group == null) {
          return Center(
            child: Text(
              'Group not found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          );
        }

        return _GroupDetailContent(group: group);
      },
    );
  }
}

class _GroupDetailContent extends ConsumerWidget {
  const _GroupDetailContent({required this.group});

  final PosGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final controller = ref.read(posGroupsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Name',
            onPressed: () => showPosGroupFormDialog(
              context,
              groupId: group.id,
              initialName: group.name,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete Group',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'group_detail_add_item',
        onPressed: () => showGroupItemPickerDialog(context, group: group),
        tooltip: 'Add Items',
        child: const Icon(Icons.add),
      ),
      body: group.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.playlist_add,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No items in this group',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add products or services',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            )
          : ReorderableListView.builder(
              itemCount: group.items.length,
              onReorderItem: (oldIndex, newIndex) {
                final items = List<PosGroupItem>.from(group.items);
                final item = items.removeAt(oldIndex);
                items.insert(newIndex, item);
                controller.reorderItems(group.id, items);
              },
              itemBuilder: (context, index) {
                final item = group.items[index];
                return _GroupItemTile(
                  key: ValueKey(item.id),
                  item: item,
                  groupId: group.id,
                );
              },
            ),
    );
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

class _GroupItemTile extends ConsumerWidget {
  const _GroupItemTile({
    super.key,
    required this.item,
    required this.groupId,
  });

  final PosGroupItem item;
  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: item.isProduct
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.tertiaryContainer,
        child: Icon(
          item.isProduct ? Icons.inventory_2 : Icons.miscellaneous_services,
          color: item.isProduct
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onTertiaryContainer,
        ),
      ),
      title: Text(item.displayName),
      subtitle: Text(
        item.hasVariablePrice
            ? 'Variable price'
            : item.displayPrice.toCurrency(),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.isProduct ? 'Product' : 'Service',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.remove_circle_outline,
                color: theme.colorScheme.error),
            tooltip: 'Remove from group',
            onPressed: () async {
              await ref
                  .read(posGroupsControllerProvider.notifier)
                  .removeItemFromGroup(groupId, item.id);
            },
          ),
          const Icon(Icons.drag_handle),
        ],
      ),
    );
  }
}
