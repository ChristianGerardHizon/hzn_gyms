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
void invalidateTenantScopedProviders(Ref ref) {
  ref.invalidate(currentBranchControllerProvider);
  ref.invalidate(branchesControllerProvider);
  ref.invalidate(paginatedMembersControllerProvider);
  ref.invalidate(membersControllerProvider);
  ref.invalidate(paginatedSalesControllerProvider);
  ref.invalidate(paginatedProductsControllerProvider);
  ref.invalidate(membershipsControllerProvider);
  ref.invalidate(paginatedUsersControllerProvider);
  ref.invalidate(checkInRecordsControllerProvider);
  ref.invalidate(activeMembersCountProvider);
  ref.invalidate(activeMembersListProvider);
  ref.invalidate(todaysCheckInsCountProvider);
  ref.invalidate(todaySalesProvider);
  ref.invalidate(todaySalesSummaryProvider);
  ref.invalidate(todaysNewMembersCountProvider);
  ref.invalidate(todaysNewMembersListProvider);
  ref.invalidate(expiringMembershipsProvider);
  ref.invalidate(inventoryAlertsSummaryProvider);
  ref.invalidate(topSellingProductsProvider);
}
