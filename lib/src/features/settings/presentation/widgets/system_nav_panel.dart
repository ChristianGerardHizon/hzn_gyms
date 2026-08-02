import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/permissions/current_user_permissions.dart';

/// System management modes.
enum SystemMode {
  productCategories,
  quantityUnits,
  printers,
  cashierGroups,
  appearance,
  import,
  debug,
  activityLog,
}

/// Vertical navigation panel for selecting system mode.
///
/// Admin sees all modes; every signed-in user sees Appearance.
class SystemNavPanel extends ConsumerWidget {
  const SystemNavPanel({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  /// Currently selected mode.
  final SystemMode currentMode;

  /// Callback when mode is changed.
  final ValueChanged<SystemMode> onModeChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final perms =
        ref.watch(currentUserPermissionsProvider).value ??
            CurrentUserPermissions.empty;
    final isAdmin = perms.canManageSystem;
    final canViewActivityLog = perms.canViewActivityLog;

    final modes = <(SystemMode, IconData, IconData, String)>[
      if (isAdmin) ...[
        (
          SystemMode.productCategories,
          Icons.inventory_2_outlined,
          Icons.inventory_2,
          'Categories',
        ),
        (
          SystemMode.quantityUnits,
          Icons.straighten_outlined,
          Icons.straighten,
          'Units',
        ),
        (
          SystemMode.printers,
          Icons.print_outlined,
          Icons.print,
          'Printers',
        ),
        (
          SystemMode.cashierGroups,
          Icons.point_of_sale_outlined,
          Icons.point_of_sale,
          'Cashier',
        ),
      ],
      (
        SystemMode.appearance,
        Icons.palette_outlined,
        Icons.palette,
        'Appearance',
      ),
      if (isAdmin) ...[
        (
          SystemMode.import,
          Icons.file_upload_outlined,
          Icons.file_upload,
          'Import',
        ),
        (
          SystemMode.debug,
          Icons.bug_report_outlined,
          Icons.bug_report,
          'Debug',
        ),
      ],
      if (canViewActivityLog)
        (
          SystemMode.activityLog,
          Icons.history_outlined,
          Icons.history,
          'Activity Log',
        ),
    ];

    return SizedBox(
      width: 80,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.settings,
              size: 32,
              color: theme.colorScheme.primary,
            ),
          ),
          const Divider(),
          const SizedBox(height: 8),
          for (final entry in modes) ...[
            _NavButton(
              icon: entry.$2,
              selectedIcon: entry.$3,
              label: entry.$4,
              isSelected: currentMode == entry.$1,
              onTap: () => onModeChanged(entry.$1),
            ),
            const SizedBox(height: 4),
          ],
          const Spacer(),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 64,
        padding: const EdgeInsets.symmetric(vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.secondaryContainer : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              size: 24,
              color: isSelected
                  ? theme.colorScheme.onSecondaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onSecondaryContainer
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : null,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
