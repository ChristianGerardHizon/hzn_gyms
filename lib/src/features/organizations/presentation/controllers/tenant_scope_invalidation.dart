import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../check_in/presentation/controllers/check_in_records_controller.dart';
import '../../../dashboard/presentation/controllers/active_members_count_controller.dart';
import '../../../dashboard/presentation/controllers/expiring_memberships_controller.dart';
import '../../../dashboard/presentation/controllers/inventory_alerts_controller.dart';
import '../../../dashboard/presentation/controllers/new_members_controller.dart';
import '../../../dashboard/presentation/controllers/todays_checkins_controller.dart';
import '../../../dashboard/presentation/controllers/todays_sales_controller.dart';
import '../../../dashboard/presentation/controllers/top_selling_controller.dart';
import '../../../members/presentation/controllers/members_controller.dart';
import '../../../members/presentation/controllers/paginated_members_controller.dart';
import '../../../memberships/presentation/controllers/memberships_controller.dart';
import '../../../products/presentation/controllers/paginated_products_controller.dart';
import '../../../sales/presentation/controllers/paginated_sales_controller.dart';
import '../../../settings/presentation/controllers/branches_controller.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../../users/presentation/controllers/paginated_users_controller.dart';

/// Invalidates keepAlive / tenant-scoped providers after an org switch.
///
/// Uses [ProviderContainer.invalidate] (not [Ref.invalidate]) so this is safe
/// to call from [CurrentOrganizationController]: many of these providers watch
/// [currentOrganizationIdProvider], and `ref.invalidate` would register a
/// circular dependency.
void invalidateTenantScopedProviders(ProviderContainer container) {
  container.invalidate(currentBranchControllerProvider);
  container.invalidate(branchesControllerProvider);
  container.invalidate(paginatedMembersControllerProvider);
  container.invalidate(membersControllerProvider);
  container.invalidate(paginatedSalesControllerProvider);
  container.invalidate(paginatedProductsControllerProvider);
  container.invalidate(membershipsControllerProvider);
  container.invalidate(paginatedUsersControllerProvider);
  container.invalidate(checkInRecordsControllerProvider);
  container.invalidate(activeMembersCountProvider);
  container.invalidate(activeMembersListProvider);
  container.invalidate(todaysCheckInsCountProvider);
  container.invalidate(todaySalesProvider);
  container.invalidate(todaySalesSummaryProvider);
  container.invalidate(todaysNewMembersCountProvider);
  container.invalidate(todaysNewMembersListProvider);
  container.invalidate(expiringMembershipsProvider);
  container.invalidate(inventoryAlertsSummaryProvider);
  container.invalidate(topSellingProductsProvider);
}
