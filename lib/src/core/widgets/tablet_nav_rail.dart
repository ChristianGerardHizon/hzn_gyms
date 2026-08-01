import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../assets/assets.gen.dart';
import '../i18n/strings.g.dart';
import '../navigation/app_nav_destination.dart';
import '../sync/outbox_sync_worker.dart';
import '../utils/breakpoints.dart';
import 'outbox_queue_badge.dart';

/// Navigation rail for tablet and desktop layouts.
///
/// Destinations are filtered by the signed-in user's role permissions.
class TabletNavRail extends ConsumerWidget {
  const TabletNavRail({
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
    final isLargeTablet = Breakpoints.isTabletLargeOrLarger(context);
    // Rebuild destinations when queue count changes (NavigationRail caches icons).
    ref.watch(outboxPendingCountProvider);

    final railDestinations = destinations.map((dest) {
      final icon = Icon(_iconFor(dest.id, selected: false));
      final selectedIcon = Icon(_iconFor(dest.id, selected: true));
      return NavigationRailDestination(
        icon: dest.id == AppNavId.outbox ? OutboxQueueBadge(child: icon) : icon,
        selectedIcon: dest.id == AppNavId.outbox
            ? OutboxQueueBadge(child: selectedIcon)
            : selectedIcon,
        label: Text(_labelFor(dest.id, t)),
      );
    }).toList();

    // NavigationRail requires non-empty destinations.
    if (railDestinations.isEmpty) {
      return const SizedBox(width: 72);
    }

    final safeSelected = selectedIndex.clamp(0, railDestinations.length - 1);

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: IntrinsicHeight(
          child: NavigationRail(
            selectedIndex: safeSelected,
            onDestinationSelected: onDestinationSelected,
            labelType: isLargeTablet
                ? NavigationRailLabelType.all
                : NavigationRailLabelType.selected,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Assets.icons.appIconTransparent.image(
                width: 40,
                height: 40,
              ),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.logout),
                        tooltip: t.auth.logoutButton,
                        onPressed: () => _confirmLogout(context, ref, t),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            destinations: railDestinations,
          ),
        ),
      ),
    );
  }

  IconData _iconFor(AppNavId id, {required bool selected}) {
    switch (id) {
      case AppNavId.dashboard:
        return selected ? Icons.dashboard : Icons.dashboard_outlined;
      case AppNavId.checkIn:
        return selected ? Icons.how_to_reg : Icons.how_to_reg_outlined;
      case AppNavId.cashier:
        return selected ? Icons.point_of_sale : Icons.point_of_sale_outlined;
      case AppNavId.sales:
        return selected ? Icons.receipt_long : Icons.receipt_long_outlined;
      case AppNavId.products:
        return selected ? Icons.inventory_2 : Icons.inventory_2_outlined;
      case AppNavId.members:
        return selected ? Icons.people : Icons.people_outlined;
      case AppNavId.memberships:
        return selected
            ? Icons.card_membership
            : Icons.card_membership_outlined;
      case AppNavId.reports:
        return selected ? Icons.analytics : Icons.analytics_outlined;
      case AppNavId.organization:
        return selected ? Icons.business : Icons.business_outlined;
      case AppNavId.profile:
        return selected ? Icons.person : Icons.person_outline;
      case AppNavId.outbox:
        return selected ? Icons.cloud_sync : Icons.cloud_sync_outlined;
      case AppNavId.system:
        return selected ? Icons.settings : Icons.settings_outlined;
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
              ref.read(authControllerProvider.notifier).logout();
            },
            child: Text(t.auth.logoutButton),
          ),
        ],
      ),
    );
  }
}
