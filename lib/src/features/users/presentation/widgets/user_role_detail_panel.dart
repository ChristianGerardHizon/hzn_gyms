import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/form_feedback.dart';
import '../../domain/user_role.dart';
import '../controllers/user_roles_controller.dart';
import 'permission_category_widget.dart';
import 'dialogs/edit_role_dialog.dart';

/// Detail panel for viewing a role in tablet layout.
class UserRoleDetailPanel extends ConsumerWidget {
  const UserRoleDetailPanel({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedPermissions = role.permissions.toSet();
    final permissionEntries = Permissions.allPermissionsByCategory.entries
        .map((entry) {
          final filteredPermissions = entry.value
              .where((perm) => selectedPermissions.contains(perm.key))
              .toList();
          return MapEntry(entry.key, filteredPermissions);
        })
        .where((entry) => entry.value.isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(role.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(userRolesControllerProvider.notifier).refresh(),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => showEditRoleDialog(context, role),
            tooltip: 'Edit',
          ),
          if (!role.isSystem)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showDeleteConfirmation(context, ref, role),
              tooltip: 'Delete',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (role.description != null && role.description!.trim().isNotEmpty)
              Text(role.description!, style: theme.textTheme.bodyLarge)
            else
              Text(
                'No description provided',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (role.isSystem)
                  _StatusChip(
                    label: 'System',
                    color: theme.colorScheme.tertiaryContainer,
                    textColor: theme.colorScheme.onTertiaryContainer,
                  ),
                if (role.isAdmin)
                  _StatusChip(
                    label: 'Admin',
                    color: theme.colorScheme.primaryContainer,
                    textColor: theme.colorScheme.onPrimaryContainer,
                  ),
                _StatusChip(
                  label: role.permissionCountDisplay,
                  color: theme.colorScheme.secondaryContainer,
                  textColor: theme.colorScheme.onSecondaryContainer,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Permissions', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (permissionEntries.isEmpty)
              Text(
                'No permissions assigned',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              )
            else
              ...permissionEntries.map(
                (entry) => PermissionCategoryWidget(
                  category: entry.key,
                  permissions: entry.value,
                  selectedPermissions: selectedPermissions,
                  enabled: false,
                  showSelectAll: false,
                  initiallyExpanded: true,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    UserRole role,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete'),
        content: Text(
          'Are you sure you want to delete the "${role.name}" role?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(userRolesControllerProvider.notifier)
                  .deleteRole(role.id);
              if (context.mounted) {
                if (success) {
                  showSuccessSnackBar(context, message: 'Role deleted');
                } else {
                  showErrorSnackBar(context, message: 'Failed to delete role');
                }
              }
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(color: textColor),
      ),
    );
  }
}
