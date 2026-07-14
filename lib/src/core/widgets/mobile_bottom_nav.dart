import 'package:flutter/material.dart';

import '../i18n/strings.g.dart';
import '../navigation/app_nav_destination.dart';

/// Bottom navigation bar for mobile layout.
///
/// Primary destinations when available: Dashboard, Check-In, Cashier + More.
class MobileBottomNav extends StatelessWidget {
  const MobileBottomNav({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.onMoreTap,
  });

  final List<AppNavDestination> destinations;

  /// Currently selected navigation index into [destinations].
  final int selectedIndex;

  /// Callback when a destination is selected (passes destinations index).
  final ValueChanged<int> onDestinationSelected;

  /// Callback when "More" is tapped to open the drawer.
  final VoidCallback? onMoreTap;

  static const _primaryIds = [
    AppNavId.dashboard,
    AppNavId.checkIn,
    AppNavId.cashier,
  ];

  List<int> get _primaryIndices {
    final indices = <int>[];
    for (final id in _primaryIds) {
      final index = destinations.indexWhere((d) => d.id == id);
      if (index >= 0) indices.add(index);
    }
    return indices;
  }

  int _getBottomNavIndex() {
    final primary = _primaryIndices;
    final localIndex = primary.indexOf(selectedIndex);
    if (localIndex >= 0) return localIndex;
    return primary.length; // "More"
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final primary = _primaryIndices;

    return NavigationBar(
      selectedIndex: _getBottomNavIndex(),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      height: 60,
      onDestinationSelected: (index) {
        if (index >= primary.length) {
          onMoreTap?.call();
          return;
        }
        onDestinationSelected(primary[index]);
      },
      destinations: [
        for (final destIndex in primary)
          NavigationDestination(
            icon: Icon(_outlinedIcon(destinations[destIndex].id)),
            selectedIcon: Icon(_filledIcon(destinations[destIndex].id)),
            label: _label(destinations[destIndex].id, t),
          ),
        NavigationDestination(
          icon: const Icon(Icons.more_horiz),
          selectedIcon: const Icon(Icons.more_horiz),
          label: t.navigation.more,
        ),
      ],
    );
  }

  IconData _outlinedIcon(AppNavId id) {
    switch (id) {
      case AppNavId.dashboard:
        return Icons.dashboard_outlined;
      case AppNavId.checkIn:
        return Icons.how_to_reg_outlined;
      case AppNavId.cashier:
        return Icons.point_of_sale_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  IconData _filledIcon(AppNavId id) {
    switch (id) {
      case AppNavId.dashboard:
        return Icons.dashboard;
      case AppNavId.checkIn:
        return Icons.how_to_reg;
      case AppNavId.cashier:
        return Icons.point_of_sale;
      default:
        return Icons.circle;
    }
  }

  String _label(AppNavId id, Translations t) {
    switch (id) {
      case AppNavId.dashboard:
        return t.navigation.dashboard;
      case AppNavId.checkIn:
        return t.navigation.checkIn;
      case AppNavId.cashier:
        return t.navigation.sales;
      default:
        return '';
    }
  }
}
