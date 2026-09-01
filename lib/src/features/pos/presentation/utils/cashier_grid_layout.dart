import 'package:flutter/painting.dart';

/// Pure layout helpers for the cashier product grid.
///
/// Keeps column / aspect-ratio math out of widgets so it can be unit-tested
/// and shared by ProductGrid and GroupedCashierView.
abstract final class CashierGridLayout {
  /// Target tile width used with [SliverGridDelegateWithMaxCrossAxisExtent].
  ///
  /// Narrower tiles on small screens keep 2 columns readable; wider tiles on
  /// desktop avoid sparse empty cards.
  static double maxCrossAxisExtent(double width) {
    if (width < 360) return 152;
    if (width < 600) return 168;
    if (width < 900) return 180;
    if (width < 1200) return 190;
    return 200;
  }

  /// Card aspect ratio (width / height).
  ///
  /// Slightly taller on narrow grids so name + price + stock chip fit;
  /// wider on desktop for denser POS tapping.
  static double childAspectRatio(double width) {
    if (width < 600) return 1.35;
    if (width < 900) return 1.55;
    return 1.7;
  }

  /// Spacing between tiles.
  static double spacing(double width) => width < 600 ? 8 : 10;

  /// Outer padding around the grid.
  static EdgeInsets padding(double width) {
    final horizontal = width < 600 ? 8.0 : 12.0;
    return EdgeInsets.fromLTRB(horizontal, 4, horizontal, 12);
  }
}
