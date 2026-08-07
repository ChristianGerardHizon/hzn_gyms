import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/scroll_to_top_button.dart';
import '../../../check_in/presentation/widgets/rfid_listener_status_icon.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../controllers/dashboard_refresh.dart';
import 'dashboard_footer.dart';
import 'dashboard_members_section.dart';
import 'inventory_alerts_section.dart';
import 'kpi_summary_section.dart';
import 'quick_actions_section.dart';
import 'recent_transactions_section.dart';
import 'unpaid_sales_queue_section.dart';

/// Single-pane tablet layout for the dashboard.
///
/// Uses [CustomScrollView] with slivers so the members grid can be
/// virtualized (only visible cards are built).
class TabletDashboardLayout extends HookConsumerWidget {
  const TabletDashboardLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scrollController = useScrollController();
    final overviewKey = useMemoized(GlobalKey.new);
    final branchAsync = ref.watch(currentBranchControllerProvider);

    // Hide stale KPIs / members while switching branch (not on first resolve).
    if (branchAsync.isLoading && branchAsync.hasValue) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Switching branch...'),
          ],
        ),
      );
    }

    return Stack(
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
                      padding: const EdgeInsets.all(16),
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
                              const RfidListenerStatusIcon(),
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                tooltip: 'Refresh',
                                onPressed: () => refreshDashboard(ref),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const KpiSummarySection(),
                          const SizedBox(height: 24),
                          const QuickActionsSection(),
                          const SizedBox(height: 16),
                          const UnpaidSalesQueueSection(),
                          const SizedBox(height: 8),
                          const RecentTransactionsSection(),
                          const SizedBox(height: 24),
                          const InventoryAlertsSection(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Members Section (virtualized slivers)
              const DashboardMembersSection(),

              // Footer
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SizedBox(height: 24),
                      DashboardFooter(),
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
    );
  }
}
