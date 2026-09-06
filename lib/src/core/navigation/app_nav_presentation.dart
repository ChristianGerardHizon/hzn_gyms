import 'package:flutter/material.dart';

import '../i18n/strings.g.dart';
import '../routing/routes/dashboard.routes.dart';
import 'app_nav_destination.dart';

/// Sidebar grouping for Firebase-style desktop navigation.
enum AppNavCategory {
  operations,
  people,
  insights,
  administration,
  account,
}

/// Default daily shortcuts shown before "Show more".
const List<AppNavId> defaultShortcutIds = [
  AppNavId.checkIn,
  AppNavId.members,
  AppNavId.sales,
  AppNavId.products,
];

/// All categories in display order.
const List<AppNavCategory> appNavCategories = [
  AppNavCategory.operations,
  AppNavCategory.people,
  AppNavCategory.insights,
  AppNavCategory.administration,
  AppNavCategory.account,
];

/// Maps a destination to its sidebar category, if any.
AppNavCategory? appNavCategoryFor(AppNavId id) {
  switch (id) {
    case AppNavId.checkIn:
    case AppNavId.cashier:
    case AppNavId.sales:
    case AppNavId.products:
      return AppNavCategory.operations;
    case AppNavId.members:
    case AppNavId.memberships:
      return AppNavCategory.people;
    case AppNavId.reports:
      return AppNavCategory.insights;
    case AppNavId.users:
    case AppNavId.roles:
    case AppNavId.branches:
    case AppNavId.organizations:
      return AppNavCategory.administration;
    case AppNavId.profile:
      return AppNavCategory.account;
    case AppNavId.dashboard:
    case AppNavId.outbox:
    case AppNavId.system:
      return null;
  }
}

/// All destination ids that belong to [category].
List<AppNavId> categoryIdsFor(AppNavCategory category) {
  return AppNavId.values
      .where((id) => appNavCategoryFor(id) == category)
      .toList(growable: false);
}

/// Icon for [id]; outline vs filled based on [selected].
IconData appNavIcon(AppNavId id, {required bool selected}) {
  switch (id) {
    case AppNavId.dashboard:
      return selected ? Icons.dashboard : Icons.dashboard_outlined;
    case AppNavId.checkIn:
      return selected ? Icons.how_to_reg : Icons.how_to_reg_outlined;
    case AppNavId.cashier:
      return selected ? Icons.point_of_sale : Icons.point_of_sale_outlined;
    case AppNavId.sales:
      return selected ? Icons.receipt_long : Icons.receipt_long_outlined;
    case AppNavId.products:
      return selected ? Icons.inventory_2 : Icons.inventory_2_outlined;
    case AppNavId.members:
      return selected ? Icons.people : Icons.people_outlined;
    case AppNavId.memberships:
      return selected
          ? Icons.card_membership
          : Icons.card_membership_outlined;
    case AppNavId.reports:
      return selected ? Icons.analytics : Icons.analytics_outlined;
    case AppNavId.users:
      return selected ? Icons.people : Icons.people_outlined;
    case AppNavId.roles:
      return selected
          ? Icons.admin_panel_settings
          : Icons.admin_panel_settings_outlined;
    case AppNavId.branches:
      return selected ? Icons.store : Icons.store_outlined;
    case AppNavId.organizations:
      return selected ? Icons.apartment : Icons.apartment_outlined;
    case AppNavId.profile:
      return selected ? Icons.person : Icons.person_outline;
    case AppNavId.outbox:
      return selected ? Icons.cloud_sync : Icons.cloud_sync_outlined;
    case AppNavId.system:
      return selected ? Icons.settings : Icons.settings_outlined;
  }
}

/// Localized label for [id].
String appNavLabel(AppNavId id, Translations t) {
  switch (id) {
    case AppNavId.dashboard:
      return t.navigation.dashboard;
    case AppNavId.checkIn:
      return t.navigation.checkIn;
    case AppNavId.cashier:
      return t.navigation.sales;
    case AppNavId.sales:
      return t.navigation.salesHistory;
    case AppNavId.products:
      return t.navigation.products;
    case AppNavId.members:
      return t.navigation.members;
    case AppNavId.memberships:
      return t.navigation.memberships;
    case AppNavId.reports:
      return t.navigation.reports;
    case AppNavId.users:
      return t.navigation.users;
    case AppNavId.roles:
      return t.navigation.roles;
    case AppNavId.branches:
      return t.navigation.branches;
    case AppNavId.organizations:
      return t.navigation.organizations;
    case AppNavId.profile:
      return t.navigation.profile;
    case AppNavId.outbox:
      return t.navigation.outbox;
    case AppNavId.system:
      return t.navigation.system;
  }
}

/// Localized label for [category].
String appNavCategoryLabel(AppNavCategory category, Translations t) {
  switch (category) {
    case AppNavCategory.operations:
      return t.navigation.operations;
    case AppNavCategory.people:
      return t.navigation.people;
    case AppNavCategory.insights:
      return t.navigation.insights;
    case AppNavCategory.administration:
      return t.navigation.administration;
    case AppNavCategory.account:
      return t.navigation.account;
  }
}

IconData appNavCategoryIcon(AppNavCategory category) {
  switch (category) {
    case AppNavCategory.operations:
      return Icons.storefront_outlined;
    case AppNavCategory.people:
      return Icons.groups_outlined;
    case AppNavCategory.insights:
      return Icons.insights_outlined;
    case AppNavCategory.administration:
      return Icons.admin_panel_settings_outlined;
    case AppNavCategory.account:
      return Icons.account_circle_outlined;
  }
}

/// Visible shortcut ids from [destinations], preserving [defaultShortcutIds] order.
List<AppNavId> visibleShortcutIds(List<AppNavDestination> destinations) {
  final visible = destinations.map((d) => d.id).toSet();
  return defaultShortcutIds
      .where(visible.contains)
      .toList(growable: false);
}

/// Extra visible destinations suitable for "Show more" (not dashboard/system/shortcuts).
List<AppNavId> extraShortcutCandidates(
  List<AppNavDestination> destinations,
  List<AppNavId> shownShortcutIds,
) {
  final shown = {...shownShortcutIds, AppNavId.dashboard, AppNavId.system};
  return destinations
      .map((d) => d.id)
      .where((id) => !shown.contains(id))
      .toList(growable: false);
}

/// Category items from [destinations] excluding ids already shown as shortcuts.
List<AppNavDestination> categoryDestinations(
  AppNavCategory category,
  List<AppNavDestination> destinations,
  Set<AppNavId> excludedIds,
) {
  return destinations
      .where(
        (dest) =>
            appNavCategoryFor(dest.id) == category &&
            !excludedIds.contains(dest.id),
      )
      .toList(growable: false);
}

/// Categories that have at least one visible destination after exclusions.
List<AppNavCategory> visibleCategories(
  List<AppNavDestination> destinations,
  Set<AppNavId> excludedIds,
) {
  return appNavCategories
      .where(
        (category) =>
            categoryDestinations(category, destinations, excludedIds)
                .isNotEmpty,
      )
      .toList(growable: false);
}

/// Whether [location] matches the destination for [id] in [destinations].
bool isNavDestinationSelected(
  String location,
  AppNavId id,
  List<AppNavDestination> destinations,
) {
  for (final dest in destinations) {
    if (dest.id != id) continue;
    if (dest.path == DashboardRoute.path) {
      return location == dest.path;
    }
    return location == dest.path || location.startsWith('${dest.path}/');
  }
  return false;
}

/// Whether any destination in [category] is active for [location].
bool isNavCategorySelected(
  String location,
  AppNavCategory category,
  List<AppNavDestination> destinations,
  Set<AppNavId> excludedIds,
) {
  final items = categoryDestinations(category, destinations, excludedIds);
  return items.any(
    (dest) => isNavDestinationSelected(location, dest.id, destinations),
  );
}
