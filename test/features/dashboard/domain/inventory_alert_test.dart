import 'package:kylie_gym/src/features/dashboard/domain/inventory_alert.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('stockAlertTypeForQuantity', () {
    test('returns outOfStock when quantity is 0', () {
      expect(stockAlertTypeForQuantity(0), InventoryAlertType.outOfStock);
    });

    test('returns outOfStock when quantity is negative', () {
      expect(stockAlertTypeForQuantity(-1), InventoryAlertType.outOfStock);
    });

    test('returns lowStock when quantity is above zero', () {
      expect(stockAlertTypeForQuantity(1), InventoryAlertType.lowStock);
      expect(stockAlertTypeForQuantity(5), InventoryAlertType.lowStock);
    });
  });

  group('InventoryAlertsSummary', () {
    InventoryAlert alert({
      required InventoryAlertType type,
      required String id,
      num qty = 0,
    }) {
      return InventoryAlert(
        productId: id,
        productName: 'Product $id',
        alertType: type,
        isLotTracked: false,
        currentQuantity: qty,
        threshold: 5,
      );
    }

    test('counts and hasAlerts include out of stock separately from low stock',
        () {
      final summary = InventoryAlertsSummary(
        lowStockAlerts: [
          alert(type: InventoryAlertType.lowStock, id: 'a', qty: 2),
        ],
        outOfStockAlerts: [
          alert(type: InventoryAlertType.outOfStock, id: 'b', qty: 0),
          alert(type: InventoryAlertType.outOfStock, id: 'c', qty: 0),
        ],
      );

      expect(summary.lowStockCount, 1);
      expect(summary.outOfStockCount, 2);
      expect(summary.hasAlerts, isTrue);
    });

    test('hasAlerts is false when all lists are empty', () {
      const summary = InventoryAlertsSummary();
      expect(summary.hasAlerts, isFalse);
      expect(summary.lowStockCount, 0);
      expect(summary.outOfStockCount, 0);
    });
  });
}
