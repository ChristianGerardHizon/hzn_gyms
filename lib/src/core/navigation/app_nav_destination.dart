import '../routing/routes/check_in.routes.dart';
import '../routing/routes/dashboard.routes.dart';
import '../routing/routes/memberships.routes.dart';
import '../routing/routes/members.routes.dart';
import '../routing/routes/organization.routes.dart';
import '../routing/routes/outbox.routes.dart';
import '../routing/routes/products.routes.dart';
import '../routing/routes/profile.routes.dart';
import '../routing/routes/reports.routes.dart';
import '../routing/routes/sales.routes.dart';
import '../routing/routes/sales_history.routes.dart';
import '../routing/routes/system.routes.dart';
import '../../features/users/domain/user_role.dart';
import '../permissions/current_user_permissions.dart';

/// Stable identity for top-level shell destinations.
enum AppNavId {
  dashboard,
  checkIn,
  checkInRecords,
  cashier,
  sales,
  products,
  members,
  memberships,
  reports,
  organization,
  profile,
  outbox,
  system,
}

/// A top-level navigation destination with its route path.
class AppNavDestination {
  const AppNavDestination({required this.id, required this.path});

  final AppNavId id;
  final String path;
}

/// Canonical ordered list of all shell destinations.
const List<AppNavDestination> allAppNavDestinations = [
  AppNavDestination(id: AppNavId.dashboard, path: DashboardRoute.path),
  AppNavDestination(id: AppNavId.checkIn, path: CheckInRoute.path),
  AppNavDestination(
    id: AppNavId.checkInRecords,
    path: CheckInRecordsRoute.path,
  ),
  AppNavDestination(id: AppNavId.cashier, path: SalesRoute.path),
  AppNavDestination(id: AppNavId.sales, path: SalesHistoryRoute.path),
  AppNavDestination(id: AppNavId.products, path: ProductsRoute.path),
  AppNavDestination(id: AppNavId.members, path: MembersRoute.path),
  AppNavDestination(id: AppNavId.memberships, path: MembershipsRoute.path),
  AppNavDestination(id: AppNavId.reports, path: ReportsRoute.path),
  AppNavDestination(id: AppNavId.organization, path: OrganizationRoute.path),
  AppNavDestination(id: AppNavId.profile, path: ProfileRoute.path),
  AppNavDestination(id: AppNavId.outbox, path: OutboxRoute.path),
  AppNavDestination(id: AppNavId.system, path: SystemRoute.path),
];

/// Returns destinations visible for [permissions].
///
/// Organization and Profile are mutually exclusive: users with
/// [Permissions.usersView] see Organization; everyone else sees Profile.
List<AppNavDestination> visibleAppNavDestinations(
  CurrentUserPermissions permissions,
) {
  return allAppNavDestinations
      .where((dest) {
        switch (dest.id) {
          case AppNavId.dashboard:
            return true;
          case AppNavId.checkIn:
            return permissions.has(Permissions.checkInsView);
          case AppNavId.checkInRecords:
            return permissions.has(Permissions.checkInsView);
          case AppNavId.cashier:
            return permissions.has(Permissions.salesCreate);
          case AppNavId.sales:
            return permissions.has(Permissions.salesView);
          case AppNavId.products:
            return permissions.has(Permissions.productsView);
          case AppNavId.members:
            return permissions.has(Permissions.membersView);
          case AppNavId.memberships:
            return permissions.has(Permissions.membershipsView);
          case AppNavId.reports:
            return permissions.has(Permissions.reportsView);
          case AppNavId.organization:
            return permissions.canManageUsers;
          case AppNavId.profile:
            return !permissions.canManageUsers;
          case AppNavId.outbox:
            return permissions.canManageSystem;
          case AppNavId.system:
            return permissions.canViewSettings;
        }
      })
      .toList(growable: false);
}

/// Maps a location path to an index in [destinations], or 0 (dashboard).
int selectedNavIndexForPath(
  String location,
  List<AppNavDestination> destinations,
) {
  for (var i = 0; i < destinations.length; i++) {
    final path = destinations[i].path;
    if (path == DashboardRoute.path) {
      if (location == path) return i;
      continue;
    }
    if (location == path || location.startsWith('$path/')) {
      return i;
    }
  }
  return 0;
}

/// True when [location] is [path] or a nested path under it (`/path/...`).
///
/// Unlike [String.startsWith], this does not treat `/memberships` as under
/// `/members`.
bool matchesRoutePath(String location, String path) {
  return location == path || location.startsWith('$path/');
}

/// Whether [location] is allowed for [permissions].
bool canAccessPath(String location, CurrentUserPermissions permissions) {
  if (location == DashboardRoute.path || location == ProfileRoute.path) {
    return true;
  }

  if (matchesRoutePath(location, CheckInRoute.path)) {
    return permissions.has(Permissions.checkInsView);
  }
  if (matchesRoutePath(location, CheckInRecordsRoute.path)) {
    return permissions.has(Permissions.checkInsView);
  }
  if (matchesRoutePath(location, SalesRoute.path)) {
    return permissions.has(Permissions.salesCreate);
  }
  if (matchesRoutePath(location, SalesHistoryRoute.path)) {
    return permissions.has(Permissions.salesView);
  }
  if (matchesRoutePath(location, ProductsRoute.path)) {
    return permissions.has(Permissions.productsView);
  }
  if (matchesRoutePath(location, MembersRoute.path)) {
    return permissions.has(Permissions.membersView);
  }
  if (matchesRoutePath(location, MembershipsRoute.path)) {
    return permissions.has(Permissions.membershipsView);
  }
  if (matchesRoutePath(location, ReportsRoute.path)) {
    return permissions.has(Permissions.reportsView);
  }
  if (matchesRoutePath(location, OrganizationRoute.path)) {
    return permissions.canManageUsers;
  }
  if (matchesRoutePath(location, OutboxRoute.path)) {
    return permissions.canManageSystem;
  }
  if (matchesRoutePath(location, SystemRoute.path)) {
    if (!permissions.canViewSettings) return false;
    // Appearance is allowed with settings.view; other system tabs need admin.
    if (location == SystemRoute.path ||
        location.startsWith('${SystemRoute.path}/appearance')) {
      return true;
    }
    return permissions.canManageSystem;
  }
  return true;
}

/// Paths that must not be reached before role permissions resolve.
bool isPermissionSensitivePath(String location) {
  return matchesRoutePath(location, OrganizationRoute.path) ||
      matchesRoutePath(location, ReportsRoute.path) ||
      matchesRoutePath(location, OutboxRoute.path) ||
      (matchesRoutePath(location, SystemRoute.path) &&
          location != SystemRoute.path &&
          !location.startsWith('${SystemRoute.path}/appearance'));
}

/// First fallback path when access is denied.
String fallbackPathFor(CurrentUserPermissions permissions) {
  final visible = visibleAppNavDestinations(permissions);
  if (visible.isEmpty) return DashboardRoute.path;
  return visible.first.path;
}
