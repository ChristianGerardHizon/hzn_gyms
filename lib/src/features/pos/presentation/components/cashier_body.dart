import 'package:flutter/material.dart';

import '../../domain/pos_group.dart';
import 'cashier_cart_bar.dart';
import 'cashier_check_in_strip.dart';
import 'cashier_search_dropdown.dart';
import 'cart_view.dart';
import 'grouped_cashier_view.dart';
import 'product_grid.dart';

/// Shared cashier body used by [PosScreen] and [CashierDialog].
///
/// Desktop / tablet: product pane + side cart.
/// Mobile: product pane + sticky [CashierCartBar] (cart opens as a sheet).
class CashierBody extends StatelessWidget {
  const CashierBody({
    super.key,
    required this.hasGroups,
    required this.groups,
    this.isMobile = false,
    this.compactSearch = false,
    this.bottomPaddingForNav = false,
    this.showCheckIn = true,
  });

  final bool hasGroups;
  final List<PosGroup> groups;

  /// When true, uses the compact single-column + cart bar layout.
  final bool isMobile;

  /// Dense search field for narrow screens / dialog chrome.
  final bool compactSearch;

  /// Extra bottom padding so the product grid clears mobile bottom nav.
  final bool bottomPaddingForNav;

  /// When false, hides the member check-in strip (e.g. dashboard cashier).
  final bool showCheckIn;

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return _MobileCashierBody(
        hasGroups: hasGroups,
        groups: groups,
        compactSearch: compactSearch,
        bottomPaddingForNav: bottomPaddingForNav,
        showCheckIn: showCheckIn,
      );
    }
    return _DesktopCashierBody(
      hasGroups: hasGroups,
      groups: groups,
      compactSearch: compactSearch,
      showCheckIn: showCheckIn,
    );
  }
}

class _DesktopCashierBody extends StatelessWidget {
  const _DesktopCashierBody({
    required this.hasGroups,
    required this.groups,
    required this.compactSearch,
    required this.showCheckIn,
  });

  final bool hasGroups;
  final List<PosGroup> groups;
  final bool compactSearch;
  final bool showCheckIn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    // Give cart a bit more room on tablet; products dominate on wide desktops.
    final productFlex = width >= 1200 ? 7 : 6;
    final cartFlex = width >= 1200 ? 3 : 4;

    return Row(
      children: [
        Expanded(
          flex: productFlex,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showCheckIn) CashierCheckInStrip(dense: compactSearch),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  compactSearch ? 8 : 12,
                  compactSearch ? 8 : 12,
                  compactSearch ? 8 : 12,
                  0,
                ),
                child: CashierSearchDropdown(isDense: compactSearch),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: hasGroups
                    ? GroupedCashierView(groups: groups)
                    : const ProductGrid(),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: cartFlex,
          child: Material(
            color: theme.colorScheme.surfaceContainerLowest,
            child: const CartView(),
          ),
        ),
      ],
    );
  }
}

class _MobileCashierBody extends StatelessWidget {
  const _MobileCashierBody({
    required this.hasGroups,
    required this.groups,
    required this.compactSearch,
    required this.bottomPaddingForNav,
    required this.showCheckIn,
  });

  final bool hasGroups;
  final List<PosGroup> groups;
  final bool compactSearch;
  final bool bottomPaddingForNav;
  final bool showCheckIn;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showCheckIn) CashierCheckInStrip(dense: compactSearch),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: CashierSearchDropdown(isDense: compactSearch),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: hasGroups
              ? GroupedCashierView(
                  groups: groups,
                  bottomPadding: bottomPaddingForNav ? 16 : 8,
                )
              : const ProductGrid(),
        ),
        const CashierCartBar(),
      ],
    );
  }
}
