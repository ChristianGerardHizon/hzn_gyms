import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'active_members_count_controller.dart';
import 'dashboard_kpi_provider.dart';
import 'dashboard_members_controller.dart';
import 'expiring_memberships_controller.dart';
import 'inventory_alerts_controller.dart';
import 'new_members_controller.dart';
import 'todays_checkins_controller.dart';
import 'todays_sales_controller.dart';

/// Invalidates all dashboard data providers so KPI, members, sales, and alerts
/// reload from the server.
Future<void> refreshDashboard(WidgetRef ref) async {
  ref.invalidate(inventoryAlertsSummaryProvider);
  ref.invalidate(todaySalesSummaryProvider);
  ref.invalidate(todaySalesProvider);
  ref.invalidate(todaysCheckInsCountProvider);
  ref.invalidate(activeMembersCountProvider);
  ref.invalidate(activeMembersListProvider);
  ref.invalidate(todaysNewMembersCountProvider);
  ref.invalidate(todaysNewMembersListProvider);
  ref.invalidate(expiringMembershipsProvider);
  ref.invalidate(dashboardMembersPageProvider);
  ref.invalidate(productsNearExpirationCountProvider);
  ref.invalidate(productsExpiredCountProvider);
  ref.invalidate(lowStockProductsCountProvider);
}
