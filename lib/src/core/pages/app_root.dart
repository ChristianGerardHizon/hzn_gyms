import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../navigation/app_nav_destination.dart';
import '../packages/pocketbase/pb_connectivity_provider.dart';
import '../permissions/current_user_permissions.dart';
import '../sync/outbox_sync_worker.dart';
import '../routing/routes/check_in.routes.dart';
import '../routing/routes/dashboard.routes.dart';
import '../routing/routes/organization.routes.dart';
import '../routing/routes/organizations.routes.dart';
import '../routing/routes/outbox.routes.dart';
import '../routing/routes/products.routes.dart';
import '../routing/routes/members.routes.dart';
import '../routing/routes/memberships.routes.dart';
import '../routing/routes/profile.routes.dart';
import '../routing/routes/reports.routes.dart';
import '../routing/routes/sales.routes.dart';
import '../routing/routes/sales_history.routes.dart';
import '../routing/routes/system.routes.dart';
import '../utils/breakpoints.dart';
import '../widgets/branch_switcher.dart';
import '../widgets/organization_switcher.dart';
import '../widgets/mobile_bottom_nav.dart';
import '../widgets/mobile_drawer.dart';
import '../widgets/tablet_nav_rail.dart';

/// Main adaptive shell widget that wraps authenticated app content.
///
/// Provides responsive navigation:
/// - Mobile (< 600px): Bottom navigation + drawer
/// - Tablet (600-1200px): Navigation rail
/// - Desktop (>= 1200px): Expanded navigation rail
class AppRoot extends ConsumerStatefulWidget {
  const AppRoot({super.key, required this.child});

  /// The child widget from the router (page content).
  final Widget child;

  @override
  ConsumerState<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<AppRoot> {
  /// Key for the scaffold to control drawer.
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Dismiss keyboard when entering authenticated shell (e.g., after login)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  void _goToDestination(AppNavDestination destination) {
    switch (destination.id) {
      case AppNavId.dashboard:
        const DashboardRoute().go(context);
      case AppNavId.checkIn:
        const CheckInRoute().go(context);
      case AppNavId.cashier:
        const SalesRoute().go(context);
      case AppNavId.sales:
        const SalesHistoryRoute().go(context);
      case AppNavId.products:
        const ProductsRoute().go(context);
      case AppNavId.members:
        const MembersRoute().go(context);
      case AppNavId.memberships:
        const MembershipsRoute().go(context);
      case AppNavId.reports:
        const ReportsRoute().go(context);
      case AppNavId.organization:
        const OrganizationRoute().go(context);
      case AppNavId.organizations:
        const OrganizationsRoute().go(context);
      case AppNavId.profile:
        const ProfileRoute().go(context);
      case AppNavId.outbox:
        const OutboxRoute().go(context);
      case AppNavId.system:
        const SystemRoute().go(context);
    }
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  List<AppNavDestination> _visibleDestinations() {
    final permsAsync = ref.watch(currentUserPermissionsProvider);
    // Avoid flashing admin destinations before role permissions resolve.
    if (!permsAsync.hasValue) {
      return const [
        AppNavDestination(id: AppNavId.dashboard, path: DashboardRoute.path),
      ];
    }
    return visibleAppNavDestinations(permsAsync.requireValue);
  }

  @override
  Widget build(BuildContext context) {
    // Keep PocketBase health polling alive for the authenticated shell.
    ref.watch(pbConnectivityProvider);
    // Start outbox sync worker (drains when online).
    ref.watch(outboxSyncWorkerProvider);

    // Redirect when current path is not allowed for this role.
    ref.listen(currentUserPermissionsProvider, (previous, next) {
      final perms = next.value;
      if (perms == null || !context.mounted) return;
      final location = GoRouterState.of(context).uri.path;
      if (!canAccessPath(location, perms)) {
        context.go(fallbackPathFor(perms));
      }
    });

    final isMobile = Breakpoints.isMobile(context);
    final destinations = _visibleDestinations();
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = selectedNavIndexForPath(location, destinations);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        // Check if the router can pop (i.e. we're on a nested page)
        if (GoRouter.of(context).canPop()) {
          GoRouter.of(context).pop();
          return;
        }

        // We're at a root page — confirm exit
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to close the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        if (shouldExit ?? false) {
          SystemNavigator.pop();
        }
      },
      child: isMobile
          ? _buildMobileLayout(context, destinations, selectedIndex)
          : _buildTabletLayout(context, destinations, selectedIndex),
    );
  }

  Widget _buildBranchBar(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OrganizationSwitcher(compact: true),
        BranchSwitcher(compact: true),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    List<AppNavDestination> destinations,
    int selectedIndex,
  ) {
    // Use Scaffold.backgroundColor — not a ColoredBox around [child] — so
    // ListTile ink/background still paint on the nearest Material (Flutter
    // asserts when a ColoredBox sits between Material and ListTile).
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: MobileDrawer(
        destinations: destinations,
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          if (index >= 0 && index < destinations.length) {
            _goToDestination(destinations[index]);
          }
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildBranchBar(context),
            Expanded(child: widget.child),
          ],
        ),
      ),
      bottomNavigationBar: MobileBottomNav(
        destinations: destinations,
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          if (index >= 0 && index < destinations.length) {
            _goToDestination(destinations[index]);
          }
        },
        onMoreTap: _openDrawer,
      ),
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    List<AppNavDestination> destinations,
    int selectedIndex,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Row(
          children: [
            // Navigation Rail
            TabletNavRail(
              destinations: destinations,
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                if (index >= 0 && index < destinations.length) {
                  _goToDestination(destinations[index]);
                }
              },
            ),

            const VerticalDivider(width: 1),

            // Main content area
            Expanded(
              child: Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBranchBar(context),
                    Expanded(child: widget.child),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
