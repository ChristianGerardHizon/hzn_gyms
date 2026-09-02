import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../i18n/strings.g.dart';
import '../navigation/app_nav_destination.dart';
import '../navigation/app_nav_presentation.dart';
import '../permissions/current_user_permissions.dart';
import '../routing/routes/platform.routes.dart';
import '../sync/outbox_sync_worker.dart';
import '../utils/breakpoints.dart';
import 'org_logo.dart';
import 'outbox_queue_badge.dart';

/// Navigation rail for tablet layouts (600–899px).
///
/// Destinations are filtered by the signed-in user's role permissions.
/// For tablet-large and desktop (>=900px), see [DesktopSideNav].
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
      final icon = Icon(appNavIcon(dest.id, selected: false));
      final selectedIcon = Icon(appNavIcon(dest.id, selected: true));
      return NavigationRailDestination(
        icon: dest.id == AppNavId.outbox ? OutboxQueueBadge(child: icon) : icon,
        selectedIcon: dest.id == AppNavId.outbox
            ? OutboxQueueBadge(child: selectedIcon)
            : selectedIcon,
        label: Text(appNavLabel(dest.id, t)),
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
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 16),
              child: const OrgLogo(width: 64, height: 64),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (ref
                              .watch(currentUserPermissionsProvider)
                              .value
                              ?.canManageOrganizations ??
                          false)
                        IconButton(
                          icon: const Icon(Icons.admin_panel_settings_outlined),
                          tooltip: t.organizations.platformTitle,
                          onPressed: () =>
                              const PlatformDashboardRoute().go(context),
                        ),
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
