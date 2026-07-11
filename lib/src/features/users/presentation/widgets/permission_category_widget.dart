import 'package:flutter/material.dart';

import '../../domain/permission.dart';

/// A reusable widget for displaying a category of permissions.
///
/// Used in role creation/editing sheets to select permissions,
/// and can be used in read-only mode to display permissions.
class PermissionCategoryWidget extends StatelessWidget {
  const PermissionCategoryWidget({
    super.key,
    required this.category,
    required this.permissions,
    required this.selectedPermissions,
    this.enabled = true,
    this.onChanged,
    this.onSelectAll,
    this.showSelectAll = true,
    this.initiallyExpanded = false,
  });

  /// The category name (e.g., "Members", "Users").
  final String category;

  /// List of Permission objects in this category.
  final List<Permission> permissions;

  /// Set of currently selected permission keys.
  final Set<String> selectedPermissions;

  /// Whether the checkboxes are enabled.
  final bool enabled;

  /// Callback when a single permission is toggled.
  final void Function(String permission, bool selected)? onChanged;

  /// Callback when "select all" is toggled.
  final void Function(List<String> permissions, bool selectAll)? onSelectAll;

  /// Whether to show the select all checkbox.
  final bool showSelectAll;

  /// Whether the expansion tile starts expanded.
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final permissionKeys = permissions.map((p) => p.key).toList();

    final selectedCount = permissions
        .where((p) => selectedPermissions.contains(p.key))
        .length;
    final allSelected = selectedCount == permissions.length;
    final someSelected = selectedCount > 0 && !allSelected;

    // Get category icon from first permission or fallback
    final categoryIcon = _getCategoryIcon(category);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(categoryIcon, color: theme.colorScheme.primary),
        initiallyExpanded: initiallyExpanded,
        title: Row(
          children: [
            Text(
              category,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            if (selectedCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$selectedCount',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        trailing: showSelectAll && onSelectAll != null
            ? Checkbox(
                value: allSelected ? true : (someSelected ? null : false),
                tristate: true,
                onChanged: enabled
                    ? (value) => onSelectAll!(permissionKeys, value == true)
                    : null,
              )
            : null,
        children: permissions.map((permission) {
          final isSelected = selectedPermissions.contains(permission.key);
          return _PermissionTile(
            permission: permission,
            isSelected: isSelected,
            enabled: enabled && onChanged != null,
            onChanged: onChanged != null
                ? (value) => onChanged!(permission.key, value ?? false)
                : null,
          );
        }).toList(),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'System':
        return Icons.settings;
      case 'Users':
        return Icons.people;
      case 'Members':
        return Icons.people;
      case 'Memberships':
        return Icons.card_membership;
      case 'Check-In':
        return Icons.how_to_reg;
      case 'Member Cards':
        return Icons.badge;
      case 'Reports':
        return Icons.assessment;
      case 'Products':
        return Icons.inventory;
      case 'Inventory':
        return Icons.warehouse;
      case 'Sales':
        return Icons.point_of_sale;
      case 'Roles':
        return Icons.admin_panel_settings;
      case 'Branches':
        return Icons.business;
      case 'Settings':
        return Icons.tune;
      default:
        return Icons.key;
    }
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.permission,
    required this.isSelected,
    required this.enabled,
    this.onChanged,
  });

  final Permission permission;
  final bool isSelected;
  final bool enabled;
  final void Function(bool?)? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CheckboxListTile(
      value: isSelected,
      onChanged: enabled ? onChanged : null,
      title: Text(permission.name, style: theme.textTheme.bodyMedium),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            permission.key,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
              fontFamily: 'monospace',
            ),
          ),
          if (permission.description != null) ...[
            const SizedBox(height: 2),
            Text(
              permission.description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      secondary: Icon(
        permission.icon ?? Icons.key,
        size: 20,
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.outline,
      ),
      dense: true,
    );
  }
}

/// A read-only version of permission category display.
///
/// Used in the user permissions tab to show assigned permissions.
class PermissionCategoryDisplayWidget extends StatelessWidget {
  const PermissionCategoryDisplayWidget({
    super.key,
    required this.category,
    required this.permissions,
    this.initiallyExpanded = false,
  });

  /// The category name.
  final String category;

  /// List of Permission objects in this category.
  final List<Permission> permissions;

  /// Whether the expansion tile starts expanded.
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryIcon = _getCategoryIcon(category);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(categoryIcon, color: theme.colorScheme.primary),
        initiallyExpanded: initiallyExpanded,
        title: Text(
          category,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${permissions.length} permission${permissions.length == 1 ? '' : 's'}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        children: permissions.map((permission) {
          return ListTile(
            leading: Icon(
              permission.icon ?? Icons.check_circle,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            title: Text(permission.name, style: theme.textTheme.bodyMedium),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  permission.key,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontFamily: 'monospace',
                  ),
                ),
                if (permission.description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    permission.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
            dense: true,
          );
        }).toList(),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'System':
        return Icons.settings;
      case 'Users':
        return Icons.people;
      case 'Members':
        return Icons.people;
      case 'Memberships':
        return Icons.card_membership;
      case 'Check-In':
        return Icons.how_to_reg;
      case 'Member Cards':
        return Icons.badge;
      case 'Reports':
        return Icons.assessment;
      case 'Products':
        return Icons.inventory;
      case 'Inventory':
        return Icons.warehouse;
      case 'Sales':
        return Icons.point_of_sale;
      case 'Roles':
        return Icons.admin_panel_settings;
      case 'Branches':
        return Icons.business;
      case 'Settings':
        return Icons.tune;
      default:
        return Icons.key;
    }
  }
}
