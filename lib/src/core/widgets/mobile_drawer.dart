import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/check_in/presentation/controllers/rfid_listener_status.dart';
import '../../features/check_in/presentation/widgets/rfid_listener_status_icon.dart';
import '../assets/assets.gen.dart';
import '../i18n/strings.g.dart';
import '../navigation/app_nav_destination.dart';
import '../packages/pocketbase/pocketbase_provider.dart';
import 'branch_switcher.dart';
import 'outbox_queue_badge.dart';

/// Mobile drawer with permission-filtered navigation.
class MobileDrawer extends ConsumerWidget {
  const MobileDrawer({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final List<AppNavDestination> destinations;

  /// Currently selected navigation index into [destinations].
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
            const BranchSwitcher(),
            for (var i = 0; i < destinations.length; i++) ...[
              if (_shouldInsertDividerBefore(destinations, i)) const Divider(),
              _DrawerItem(
                icon: _iconFor(destinations[i].id),
                label: _labelFor(destinations[i].id, t),
                selected: selectedIndex == i,
                onTap: () => _selectAndClose(context, i),
                leading: destinations[i].id == AppNavId.outbox
                    ? const OutboxQueueBadge(child: Icon(Icons.cloud_sync))
                    : null,
              ),
            ],
            const Divider(),
            ListTile(
              leading: const RfidListenerStatusIcon(),
              title: const Text('RFID scanner'),
              subtitle: Text(
                ref.watch(rfidListenerStatusControllerProvider) ==
                        RfidListenerStatus.listening
                    ? 'Listening'
                    : 'Unavailable',
              ),
              dense: true,
            ),
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

  bool _shouldInsertDividerBefore(
    List<AppNavDestination> destinations,
    int index,
  ) {
    if (index == 0) return false;
    const secondary = {
      AppNavId.reports,
      AppNavId.organization,
      AppNavId.profile,
      AppNavId.outbox,
      AppNavId.system,
    };
    final prev = destinations[index - 1].id;
    final curr = destinations[index].id;
    return !secondary.contains(prev) && secondary.contains(curr);
  }

  IconData _iconFor(AppNavId id) {
    switch (id) {
      case AppNavId.dashboard:
        return Icons.dashboard;
      case AppNavId.checkIn:
        return Icons.how_to_reg;
      case AppNavId.cashier:
        return Icons.point_of_sale;
      case AppNavId.sales:
        return Icons.receipt_long;
      case AppNavId.products:
        return Icons.inventory_2;
      case AppNavId.members:
        return Icons.people;
      case AppNavId.memberships:
        return Icons.card_membership;
      case AppNavId.reports:
        return Icons.analytics;
      case AppNavId.organization:
        return Icons.business;
      case AppNavId.profile:
        return Icons.person;
      case AppNavId.outbox:
        return Icons.cloud_sync;
      case AppNavId.system:
        return Icons.settings;
    }
  }

  String _labelFor(AppNavId id, Translations t) {
    switch (id) {
      case AppNavId.dashboard:
        return t.navigation.dashboard;
      case AppNavId.checkIn:
        return t.navigation.checkIn;
      case AppNavId.cashier:
        return t.navigation.sales;
      case AppNavId.sales:
        return t.navigation.salesHistory;
      case AppNavId.products:
        return t.navigation.products;
      case AppNavId.members:
        return t.navigation.members;
      case AppNavId.memberships:
        return t.navigation.memberships;
      case AppNavId.reports:
        return t.navigation.reports;
      case AppNavId.organization:
        return t.navigation.organization;
      case AppNavId.profile:
        return t.navigation.profile;
      case AppNavId.outbox:
        return t.navigation.outbox;
      case AppNavId.system:
        return t.navigation.system;
    }
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
    this.leading,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading ?? Icon(icon),
      title: Text(label),
      selected: selected,
      onTap: onTap,
    );
  }
}
