import 'package:hzn_gyms/src/features/pos/presentation/utils/cashier_grid_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CashierGridLayout', () {
    test('maxCrossAxisExtent scales with width', () {
      expect(CashierGridLayout.maxCrossAxisExtent(320), 152);
      expect(CashierGridLayout.maxCrossAxisExtent(400), 168);
      expect(CashierGridLayout.maxCrossAxisExtent(700), 180);
      expect(CashierGridLayout.maxCrossAxisExtent(1000), 190);
      expect(CashierGridLayout.maxCrossAxisExtent(1400), 200);
    });

    test('childAspectRatio is taller on mobile than desktop', () {
      final mobile = CashierGridLayout.childAspectRatio(390);
      final tablet = CashierGridLayout.childAspectRatio(800);
      final desktop = CashierGridLayout.childAspectRatio(1400);

      expect(mobile, lessThan(tablet));
      expect(tablet, lessThanOrEqualTo(desktop));
      expect(mobile, 1.35);
      expect(desktop, 1.7);
    });

    test('spacing and padding are tighter on mobile', () {
      expect(CashierGridLayout.spacing(390), 8);
      expect(CashierGridLayout.spacing(900), 10);

      final mobilePadding = CashierGridLayout.padding(390);
      final desktopPadding = CashierGridLayout.padding(1200);
      expect(mobilePadding.left, 8);
      expect(desktopPadding.left, 12);
    });
  });
}
