import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/settings/presentation/controllers/current_branch_controller.dart';
import '../routing/routes/check_in.routes.dart';
import '../routing/routes/dashboard.routes.dart';
import '../routing/routes/organization.routes.dart';
import '../routing/routes/products.routes.dart';
import '../routing/routes/members.routes.dart';
import '../routing/routes/memberships.routes.dart';
import '../routing/routes/reports.routes.dart';
import '../routing/routes/sales.routes.dart';
import '../routing/routes/sales_history.routes.dart';
import '../routing/routes/system.routes.dart';
import '../utils/breakpoints.dart';
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
  const AppRoot({
    super.key,
    required this.child,
  });

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

  /// Route paths in order of navigation index.
  static const _routePaths = [
    DashboardRoute.path, // 0: /
    CheckInRoute.path, // 1: /check-in
    SalesRoute.path, // 2: /cashier
    SalesHistoryRoute.path, // 3: /sales
    ProductsRoute.path, // 4: /products
    MembersRoute.path, // 5: /members
    MembershipsRoute.path, // 6: /memberships
    ReportsRoute.path, // 7: /reports
    OrganizationRoute.path, // 8: /organization
    SystemRoute.path, // 9: /system
  ];

  /// Routes in order of navigation index.
  static const _routes = <GoRouteData>[
    DashboardRoute(), // 0
    CheckInRoute(), // 1
    SalesRoute(), // 2
    SalesHistoryRoute(), // 3
    ProductsRoute(), // 4
    MembersRoute(), // 5
    MembershipsRoute(), // 6
    ReportsRoute(), // 7
    OrganizationRoute(), // 8
    SystemRoute(), // 9
  ];

  /// Gets the selected index based on current route location.
  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    // Try exact match first
    final index = _routePaths.indexOf(location);
    if (index >= 0) return index;

    // For nested routes, check if location starts with any route path
    // Skip index 0 ('/') to prevent matching everything
    for (int i = 1; i < _routePaths.length; i++) {
      if (location.startsWith(_routePaths[i])) {
        return i;
      }
    }

    // Fallback to dashboard
    return 0;
  }

  void _onDestinationSelected(int index) {
    if (index >= 0 && index < _routes.length) {
      _routes[index].go(context);
    }
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);

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
            content: const Text(
              'Are you sure you want to close the app?',
            ),
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
          ? _buildMobileLayout(context)
          : _buildTabletLayout(context),
    );
  }

  Widget _buildBranchBar(BuildContext context) {
    final theme = Theme.of(context);
    final branchAsync = ref.watch(currentBranchControllerProvider);

    return branchAsync.when(
      data: (branch) {
        if (branch == null) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: theme.colorScheme.surfaceContainerHighest,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.store,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                branch.name,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final selectedIndex = _getSelectedIndex(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: MobileDrawer(
        selectedIndex: selectedIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
      body: SafeArea(
        child: ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              _buildBranchBar(context),
              Expanded(child: widget.child),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MobileBottomNav(
        selectedIndex: selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        onMoreTap: _openDrawer,
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    final selectedIndex = _getSelectedIndex(context);

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Navigation Rail
            TabletNavRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: _onDestinationSelected,
            ),

            const VerticalDivider(width: 1),

            // Main content area
            Expanded(
              child: Scaffold(
                body: ColoredBox(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBranchBar(context),
                      Expanded(child: widget.child),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
