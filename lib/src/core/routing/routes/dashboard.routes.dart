import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../features/dashboard/presentation/controllers/active_members_count_controller.dart';
import '../../../features/dashboard/presentation/controllers/dashboard_kpi_provider.dart';
import '../../../features/dashboard/presentation/controllers/expiring_memberships_controller.dart';
import '../../../features/dashboard/presentation/controllers/inventory_alerts_controller.dart';
import '../../../features/dashboard/presentation/controllers/new_members_controller.dart';
import '../../../features/dashboard/presentation/controllers/dashboard_members_controller.dart';
import '../../../features/dashboard/presentation/controllers/todays_checkins_controller.dart';
import '../../../features/dashboard/presentation/controllers/todays_sales_controller.dart';
import '../../../features/dashboard/presentation/widgets/dashboard_members_section.dart';
import '../../../features/dashboard/presentation/widgets/inventory_alerts_section.dart';
import '../../../features/dashboard/presentation/widgets/kpi_summary_section.dart';
import '../../../features/dashboard/presentation/widgets/quick_actions_section.dart';
import '../../../features/dashboard/presentation/widgets/tablet_dashboard_layout.dart';
import '../../../features/dashboard/presentation/widgets/dashboard_footer.dart';
import '../../../features/settings/presentation/controllers/current_branch_controller.dart';
import '../../utils/breakpoints.dart';

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
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTablet = Breakpoints.isTabletOrLarger(context);

    if (isTablet) {
      return const Scaffold(
        body: TabletDashboardLayout(),
      );
    }

    // Mobile: CustomScrollView so the members grid is virtualized
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(inventoryAlertsSummaryProvider);
          ref.invalidate(todaySalesSummaryProvider);
          ref.invalidate(todaysCheckInsCountProvider);
          ref.invalidate(activeMembersCountProvider);
          ref.invalidate(todaysNewMembersCountProvider);
          ref.invalidate(expiringMembershipsProvider);
          ref.invalidate(dashboardMembersPageProvider);
          ref.invalidate(productsNearExpirationCountProvider);
          ref.invalidate(productsExpiredCountProvider);
          ref.invalidate(lowStockProductsCountProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header + KPI + Quick Actions
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _MobileDashboardHeader(),
                    SizedBox(height: 16),
                    KpiSummarySection(),
                    SizedBox(height: 20),
                    QuickActionsSection(),
                    SizedBox(height: 24),
                  ],
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
    );
  }
}

/// Mobile dashboard header widget.
class _MobileDashboardHeader extends ConsumerWidget {
  const _MobileDashboardHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final branch = ref.watch(currentBranchControllerProvider).value;

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
            ],
          ),
          // Show current branch if available
          if (branch != null)
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
                    branch.name,
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
