import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../assets/assets.gen.dart';
import '../i18n/strings.g.dart';
import '../packages/pocketbase/pocketbase_provider.dart';
import 'branch_switcher.dart';

/// Mobile drawer with full navigation menu.
///
/// Contains all navigation sections:
/// - Primary: Dashboard, Cashier, Products
/// - Secondary: Sales History, Reports, Organization, System
/// - Actions: Logout
class MobileDrawer extends ConsumerWidget {
  const MobileDrawer({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  /// Currently selected navigation index.
  final int selectedIndex;

  /// Callback when a destination is selected.
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Assets.icons.appIconTransparent.image(
                    width: 48,
                    height: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ebe Gym',
                    style: theme.textTheme.titleLarge,
                  ),
                  Text(
                    'Gym Management System',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pocketbaseUrl,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.5,
                      ),
                      fontFamily: 'monospace',
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            // Branch switcher
            const BranchSwitcher(),

            // Primary navigation
            _DrawerItem(
              icon: Icons.dashboard,
              label: t.navigation.dashboard,
              selected: selectedIndex == 0,
              onTap: () => _selectAndClose(context, 0),
            ),
            _DrawerItem(
              icon: Icons.how_to_reg,
              label: t.navigation.checkIn,
              selected: selectedIndex == 1,
              onTap: () => _selectAndClose(context, 1),
            ),
            _DrawerItem(
              icon: Icons.point_of_sale,
              label: t.navigation.sales,
              selected: selectedIndex == 2,
              onTap: () => _selectAndClose(context, 2),
            ),
            _DrawerItem(
              icon: Icons.receipt_long,
              label: t.navigation.salesHistory,
              selected: selectedIndex == 3,
              onTap: () => _selectAndClose(context, 3),
            ),
            _DrawerItem(
              icon: Icons.inventory_2,
              label: t.navigation.products,
              selected: selectedIndex == 4,
              onTap: () => _selectAndClose(context, 4),
            ),
            _DrawerItem(
              icon: Icons.people,
              label: t.navigation.members,
              selected: selectedIndex == 5,
              onTap: () => _selectAndClose(context, 5),
            ),
            _DrawerItem(
              icon: Icons.card_membership,
              label: t.navigation.memberships,
              selected: selectedIndex == 6,
              onTap: () => _selectAndClose(context, 6),
            ),

            const Divider(),

            // Secondary navigation
            _DrawerItem(
              icon: Icons.analytics,
              label: t.navigation.reports,
              selected: selectedIndex == 7,
              onTap: () => _selectAndClose(context, 7),
            ),
            _DrawerItem(
              icon: Icons.business,
              label: t.navigation.organization,
              selected: selectedIndex == 8,
              onTap: () => _selectAndClose(context, 8),
            ),
            _DrawerItem(
              icon: Icons.settings,
              label: t.navigation.system,
              selected: selectedIndex == 9,
              onTap: () => _selectAndClose(context, 9),
            ),

            const Divider(),

            // Logout
            _DrawerItem(
              icon: Icons.logout,
              label: t.auth.logoutButton,
              selected: false,
              onTap: () => _confirmLogout(context, ref, t),
            ),
          ],
        ),
      ),
    );
  }

  void _selectAndClose(BuildContext context, int index) {
    Navigator.of(context).pop();
    onDestinationSelected(index);
  }

  void _confirmLogout(BuildContext context, WidgetRef ref, Translations t) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.auth.logoutButton),
        content: Text(t.auth.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.common.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              ref.read(authControllerProvider.notifier).logout();
            },
            child: Text(t.auth.logoutButton),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: selected,
      onTap: onTap,
    );
  }
}
