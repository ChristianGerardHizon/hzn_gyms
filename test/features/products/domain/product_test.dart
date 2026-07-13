import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('Product stock helpers', () {
    test('isLowStock ignores out of stock and untracked', () {
      expect(
        buildProduct(quantity: 3, stockThreshold: 5).isLowStock,
        isTrue,
      );
      expect(
        buildProduct(quantity: 0, stockThreshold: 5).isLowStock,
        isFalse,
      );
      expect(
        buildProduct(trackStock: false, quantity: 1, stockThreshold: 5)
            .isLowStock,
        isFalse,
      );
    });

    test('expiration helpers', () {
      final expired = buildProduct(
        expiration: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(expired.isExpired, isTrue);
      expect(expired.isNearExpiration, isFalse);

      final near = buildProduct(
        expiration: DateTime.now().add(const Duration(days: 10)),
      );
      expect(near.isExpired, isFalse);
      expect(near.isNearExpiration, isTrue);

      final far = buildProduct(
        expiration: DateTime.now().add(const Duration(days: 60)),
      );
      expect(far.isNearExpiration, isFalse);
    });
  });

  group('ProductLot', () {
    test('stock and expiry flags', () {
      final lot = buildProductLot(quantity: 0);
      expect(lot.isOutOfStock, isTrue);
      expect(lot.hasStock, isFalse);

      final near = buildProductLot(
        expiration: DateTime.now().add(const Duration(days: 5)),
      );
      expect(near.isNearExpiration, isTrue);
    });
  });

  group('Product stockStatus and display', () {
    test('stockStatus for tracked products', () {
      expect(
        buildProduct(quantity: 0, stockThreshold: 5).stockStatus.name,
        'outOfStock',
      );
      expect(
        buildProduct(quantity: 3, stockThreshold: 5).stockStatus.name,
        'lowStock',
      );
      expect(
        buildProduct(quantity: 20, stockThreshold: 5).stockStatus.name,
        'inStock',
      );
      expect(
        buildProduct(trackStock: false).stockStatus.name,
        'noThreshold',
      );
    });

    test('lot-tracked null quantity is out of stock', () {
      final product = buildProduct(
        trackByLot: true,
        quantity: null,
        stockThreshold: 5,
      );
      expect(product.isOutOfStock, isTrue);
      expect(product.stockStatus.name, 'outOfStock');
    });

    test('variable price and displays', () {
      final variable = buildProduct(price: 0);
      expect(variable.isVariablePrice, isTrue);
      expect(variable.priceDisplay, 'Variable');

      final fixed = buildProduct(price: 12.5, quantity: 3);
      expect(fixed.isVariablePrice, isFalse);
      expect(fixed.priceDisplay, '₱12.50');
      expect(fixed.quantityDisplay, '3');
      expect(fixed.formatQuantity(1), '1 pc');
      expect(fixed.formatQuantity(2), '2 pcs');
    });
  });
}
