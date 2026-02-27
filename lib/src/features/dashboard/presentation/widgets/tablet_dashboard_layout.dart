import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../controllers/active_members_count_controller.dart';
import '../controllers/dashboard_members_controller.dart';
import '../controllers/expiring_memberships_controller.dart';
import '../controllers/inventory_alerts_controller.dart';
import '../controllers/dashboard_kpi_provider.dart';
import '../controllers/new_members_controller.dart';
import '../controllers/todays_checkins_controller.dart';
import '../controllers/todays_sales_controller.dart';
import 'dashboard_footer.dart';
import 'dashboard_members_section.dart';
import 'inventory_alerts_section.dart';
import 'kpi_summary_section.dart';
import 'quick_actions_section.dart';

/// Single-pane tablet layout for the dashboard.
///
/// Uses [CustomScrollView] with slivers so the members grid can be
/// virtualized (only visible cards are built).
class TabletDashboardLayout extends HookConsumerWidget {
  const TabletDashboardLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final branch = ref.watch(currentBranchControllerProvider).value;

    return RefreshIndicator(
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
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
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
                  const SizedBox(height: 24),
                  const KpiSummarySection(),
                  const SizedBox(height: 24),
                  const QuickActionsSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Members Section (virtualized slivers)
          const DashboardMembersSection(),

          // Inventory Alerts + Footer
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 24),
                  InventoryAlertsSection(),
                  SizedBox(height: 24),
                  DashboardFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
