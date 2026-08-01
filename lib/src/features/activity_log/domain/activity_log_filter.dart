import '../../../core/packages/pocketbase/pb_filter.dart';
import '../../../core/utils/date_utils.dart';

/// Filter parameters for querying activity logs.
class ActivityLogQuery {
  const ActivityLogQuery({
    this.startDate,
    this.endDate,
    this.collection,
    this.actorId,
    this.branchId,
    this.searchQuery,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final String? collection;
  final String? actorId;
  final String? branchId;
  final String? searchQuery;
}

/// Default lookback when no start date is provided (7 days).
const activityLogDefaultLookbackDays = 7;

/// Builds a PocketBase filter string for activity log queries.
String buildActivityLogFilter(ActivityLogQuery query) {
  final filter = PBFilter();

  final start = query.startDate ??
      DateTime.now().subtract(const Duration(days: activityLogDefaultLookbackDays));
  filter.greaterOrEqual(
    'created',
    start.toPocketBaseUtc(),
  );

  if (query.endDate != null) {
    final endExclusive = query.endDate!.add(const Duration(days: 1));
    filter.lessThan(
      'created',
      endExclusive.toPocketBaseUtc(),
    );
  }

  if (query.collection != null && query.collection!.isNotEmpty) {
    filter.equals('collection', query.collection!);
  }

  if (query.actorId != null && query.actorId!.isNotEmpty) {
    filter.relation('actor', query.actorId!);
  }

  if (query.branchId != null && query.branchId!.isNotEmpty) {
    filter.relation('branch', query.branchId!);
  }

  if (query.searchQuery != null && query.searchQuery!.trim().isNotEmpty) {
    filter.contains('summary', query.searchQuery!.trim());
  }

  return filter.build() ?? '';
}

/// Trackable business collections shown in the filter dropdown.
const activityLogCollectionOptions = <String, String>{
  'members': 'Members',
  'memberCards': 'Member Cards',
  'memberships': 'Membership Plans',
  'memberMemberships': 'Member Memberships',
  'membershipAddOns': 'Membership Add-ons',
  'memberMembershipAddOns': 'Member Add-ons',
  'checkIns': 'Check-ins',
  'products': 'Products',
  'productCategories': 'Product Categories',
  'productStocks': 'Product Stock',
  'productLots': 'Product Lots',
  'productAdjustments': 'Stock Adjustments',
  'posGroups': 'Cashier Groups',
  'posGroupItems': 'Cashier Group Items',
  'sales': 'Sales',
  'saleItems': 'Sale Items',
  'payments': 'Payments',
  'users': 'Users',
  'userRoles': 'Roles',
  'branches': 'Branches',
  'printerConfigs': 'Printers',
  'quantityUnits': 'Quantity Units',
};
