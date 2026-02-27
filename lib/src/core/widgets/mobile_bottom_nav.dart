import 'package:flutter/material.dart';

import '../i18n/strings.g.dart';

/// Bottom navigation bar for mobile layout.
///
/// Displays 4 primary navigation destinations:
/// - Dashboard (Home)
/// - Check-In
/// - Cashier
/// - More (opens drawer for additional options)
class MobileBottomNav extends StatelessWidget {
  const MobileBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.onMoreTap,
  });

  /// Currently selected navigation index (from app_root).
  final int selectedIndex;

  /// Callback when a destination is selected (passes app_root index).
  final ValueChanged<int> onDestinationSelected;

  /// Callback when "More" is tapped to open the drawer.
  final VoidCallback? onMoreTap;

  /// Maps bottom nav local indices to app_root indices.
  static const _bottomNavToAppIndex = [0, 1, 2];

  /// Gets the bottom nav index from the app_root selected index.
  int _getBottomNavIndex() {
    final localIndex = _bottomNavToAppIndex.indexOf(selectedIndex);
    // If current route is one of the bottom nav items, highlight it
    if (localIndex >= 0) return localIndex;
    // Otherwise, highlight "More"
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    return NavigationBar(
      selectedIndex: _getBottomNavIndex(),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      height: 60,
      onDestinationSelected: (index) {
        if (index == 3) {
          // "More" tapped - open drawer
          onMoreTap?.call();
        } else {
          // Map bottom nav index to app_root index
          onDestinationSelected(_bottomNavToAppIndex[index]);
        }
      },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.dashboard_outlined),
          selectedIcon: const Icon(Icons.dashboard),
          label: t.navigation.dashboard,
        ),
        NavigationDestination(
          icon: const Icon(Icons.how_to_reg_outlined),
          selectedIcon: const Icon(Icons.how_to_reg),
          label: t.navigation.checkIn,
        ),
        NavigationDestination(
          icon: const Icon(Icons.point_of_sale_outlined),
          selectedIcon: const Icon(Icons.point_of_sale),
          label: t.navigation.sales,
        ),
        NavigationDestination(
          icon: const Icon(Icons.more_horiz),
          selectedIcon: const Icon(Icons.more_horiz),
          label: t.navigation.more,
        ),
      ],
    );
  }
}
