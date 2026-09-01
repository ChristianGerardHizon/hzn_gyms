import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/features/pos/domain/cart_item.dart';
import 'package:hzn_gyms/src/features/pos/presentation/cart_controller.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('CartItem', () {
    test('effectivePrice prefers customPrice', () {
      final item = buildCartItem(
        product: buildProduct(price: 50),
        customPrice: 40,
        quantity: 2,
      );
      expect(item.effectivePrice, 40);
      expect(item.total, 80);
      expect(item.hasCustomPrice, isTrue);
    });

    test('falls back to product price then zero', () {
      expect(
        buildCartItem(product: buildProduct(price: 12)).effectivePrice,
        12,
      );
      const bare = CartItem(productId: 'x');
      expect(bare.effectivePrice, 0);
      expect(bare.total, 0);
    });
  });

  group('CartState', () {
    test('totals and emptiness', () {
      const empty = CartState();
      expect(empty.isEmpty, isTrue);
      expect(empty.total, 0);

      final cart = CartState(
        items: [
          buildCartItem(quantity: 2, product: buildProduct(price: 10)),
          buildCartItem(
            id: 'ci-2',
            quantity: 1,
            customPrice: 5,
            product: buildProduct(price: 99),
          ),
        ],
      );
      expect(cart.isNotEmpty, isTrue);
      expect(cart.total, 25);
      expect(cart.totalItemCount, 2);
    });
  });
}
