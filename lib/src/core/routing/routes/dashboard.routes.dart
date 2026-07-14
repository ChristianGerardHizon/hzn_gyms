import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../features/dashboard/presentation/controllers/dashboard_refresh.dart';
import '../../../features/dashboard/presentation/widgets/dashboard_members_section.dart';
import '../../../features/dashboard/presentation/widgets/inventory_alerts_section.dart';
import '../../../features/dashboard/presentation/widgets/kpi_summary_section.dart';
import '../../../features/dashboard/presentation/widgets/quick_actions_section.dart';
import '../../../features/dashboard/presentation/widgets/recent_transactions_section.dart';
import '../../../features/dashboard/presentation/widgets/tablet_dashboard_layout.dart';
import '../../../features/dashboard/presentation/widgets/dashboard_footer.dart';
import '../../../features/settings/presentation/controllers/current_branch_controller.dart';
import '../../utils/breakpoints.dart';
import '../../widgets/scroll_to_top_button.dart';

part 'dashboard.routes.g.dart';

/// Dashboard/home page route.
@TypedGoRoute<DashboardRoute>(path: DashboardRoute.path)
class DashboardRoute extends GoRouteData with $DashboardRoute {
  const DashboardRoute();

  static const path = '/';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const DashboardPage();
  }
}

/// Dashboard page content.
///
/// This is rendered within the [AppRoot] shell which provides
/// the AppBar and navigation. Only the body content is defined here.
///
/// On tablet: Shows single-pane overview layout
/// On mobile: Shows single-column list
class DashboardPage extends HookConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTablet = Breakpoints.isTabletOrLarger(context);
    final scrollController = useScrollController();
    final overviewKey = useMemoized(GlobalKey.new);
    final branchAsync = ref.watch(currentBranchControllerProvider);

    // Hide stale KPIs / members while switching branch (not on first resolve).
    if (branchAsync.isLoading && branchAsync.hasValue) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Switching branch...'),
            ],
          ),
        ),
      );
    }

    if (isTablet) {
      return const Scaffold(
        body: TabletDashboardLayout(),
      );
    }

    // Mobile: CustomScrollView so the members grid is virtualized
    return Scaffold(
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => refreshDashboard(ref),
            child: CustomScrollView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Header + KPI + Quick Actions + Recent Transactions
                // Keyed so scroll-to-top shows after this block scrolls away.
                SliverToBoxAdapter(
                  child: NotificationListener<SizeChangedLayoutNotification>(
                    onNotification: (_) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (scrollController.hasClients) {
                          scrollController.position.notifyListeners();
                        }
                      });
                      return true;
                    },
                    child: SizeChangedLayoutNotifier(
                      child: Padding(
                        key: overviewKey,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _MobileDashboardHeader(),
                            SizedBox(height: 16),
                            KpiSummarySection(),
                            SizedBox(height: 20),
                            QuickActionsSection(),
                            SizedBox(height: 24),
                            RecentTransactionsSection(),
                            SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Members Section (virtualized slivers)
                const DashboardMembersSection(),

                // Inventory Alerts + Footer
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SizedBox(height: 24),
                        InventoryAlertsSection(),
                        SizedBox(height: 24),
                        DashboardFooter(),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          ScrollToTopButton(
            scrollController: scrollController,
            anchorKey: overviewKey,
          ),
        ],
      ),
    );
  }
}

/// Mobile dashboard header widget.
class _MobileDashboardHeader extends ConsumerWidget {
  const _MobileDashboardHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selection = ref.watch(currentBranchControllerProvider).value;
    final branchLabel = selection == null
        ? null
        : selection.isAll
            ? 'All Branches'
            : selection.branch?.name;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.dashboard,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Dashboard Overview',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: () => refreshDashboard(ref),
              ),
            ],
          ),
          // Show current branch if available
          if (branchLabel != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.store,
                    size: 16,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    branchLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
