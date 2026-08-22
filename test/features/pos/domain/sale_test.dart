import 'package:flutter_test/flutter_test.dart';
import 'package:kylie_gym/src/features/pos/domain/sale.dart';
import 'package:kylie_gym/src/features/pos/domain/sale_item.dart';

import '../../../helpers/fixtures.dart';

SaleItem _item({
  required String name,
  String? itemType,
}) {
  return SaleItem(
    id: '1',
    saleId: 's1',
    productId: 'p1',
    productName: name,
    quantity: 1,
    unitPrice: 10,
    subtotal: 10,
    itemType: itemType,
  );
}

void main() {
  group('Sale display helpers', () {
    test('shortReceiptNumber uses last 4 chars', () {
      final sale = buildSale(receiptNumber: 'S-250101-ABCD');
      expect(sale.shortReceiptNumber, '#ABCD');
      expect(buildSale(receiptNumber: 'AB').shortReceiptNumber, '#AB');
    });

    test('listTitle prefers descriptor', () {
      final withDescriptor = buildSale().copyWith(descriptor: 'WATER');
      expect(withDescriptor.listTitle, 'WATER');
      expect(buildSale(receiptNumber: 'S-250101-WXYZ').listTitle, '#WXYZ');
    });

    test('customerDisplay falls back to Walk-in when unlinked', () {
      expect(buildSale().customerDisplay, 'Walk-in');
      expect(buildSale().isWalkIn, isTrue);
      expect(buildSale().hasCustomer, isFalse);
      expect(
        buildSale().copyWith(customerName: '  Jane Doe  ').customerDisplay,
        'Jane Doe',
      );
      expect(
        buildSale().copyWith(customerName: 'Jane Doe').hasCustomer,
        isTrue,
      );
      expect(
        buildSale().copyWith(customerName: Sale.walkInLabel).hasCustomer,
        isFalse,
      );
      expect(
        buildSale().copyWith(customerId: 'm1').hasCustomer,
        isTrue,
      );
      expect(
        buildSale().copyWith(customerId: 'm1').isWalkIn,
        isFalse,
      );
    });

    test('resolveCustomerName stores Walk-in for unlinked sales', () {
      expect(
        Sale.resolveCustomerName(customerId: null, customerName: null),
        Sale.walkInLabel,
      );
      expect(
        Sale.resolveCustomerName(customerId: '', customerName: '  '),
        Sale.walkInLabel,
      );
      expect(
        Sale.resolveCustomerName(customerId: null, customerName: 'Jane'),
        'Jane',
      );
      expect(
        Sale.resolveCustomerName(customerId: 'm1', customerName: 'Jane'),
        'Jane',
      );
      expect(
        Sale.resolveCustomerName(customerId: 'm1', customerName: null),
        isNull,
      );
    });

    test('detailTitle prefers descriptor, then customer, then receipt', () {
      expect(
        buildSale().copyWith(descriptor: 'WATER +1 more').detailTitle,
        'WATER +1 more',
      );
      expect(
        buildSale()
            .copyWith(customerName: 'Jane Doe', descriptor: '  ')
            .detailTitle,
        'Jane Doe',
      );
      expect(
        buildSale(receiptNumber: 'S-250101-WXYZ').detailTitle,
        'S-250101-WXYZ',
      );
    });
  });

  group('Sale.buildDescriptor', () {
    test('empty items falls back to customer or Sale', () {
      expect(Sale.buildDescriptor(items: const []), 'Sale');
      expect(
        Sale.buildDescriptor(items: const [], customerName: 'Jane'),
        'Jane',
      );
      expect(
        Sale.buildDescriptor(items: const [], isWalkIn: true),
        'Walk-in',
      );
    });

    test('membership with optional add-ons', () {
      expect(
        Sale.buildDescriptor(
          items: [_item(name: 'Monthly', itemType: 'membership')],
          customerName: 'Jane Doe',
        ),
        'Jane Doe · Monthly',
      );
      expect(
        Sale.buildDescriptor(
          items: [
            _item(name: 'Monthly', itemType: 'membership'),
            _item(name: 'Locker', itemType: 'addon'),
            _item(name: 'Pool', itemType: 'addon'),
          ],
          customerName: 'Jane',
        ),
        'Jane · Monthly +2 add-ons',
      );
      expect(
        Sale.buildDescriptor(
          items: [
            _item(name: 'Monthly', itemType: 'membership'),
            _item(name: 'Locker', itemType: 'addon'),
          ],
        ),
        'Monthly +1 add-on',
      );
    });

    test('walk-in membership descriptors are prefixed', () {
      expect(
        Sale.buildDescriptor(
          items: [_item(name: 'Day Pass', itemType: 'membership')],
          customerName: 'Jane',
          isWalkIn: true,
        ),
        'Walk-in · Jane · Day Pass',
      );
      expect(
        Sale.buildDescriptor(
          items: [_item(name: 'Day Pass', itemType: 'membership')],
          isWalkIn: true,
        ),
        'Walk-in · Day Pass',
      );
      expect(
        Sale.buildDescriptor(
          items: [
            _item(name: 'Day Pass', itemType: 'membership'),
            _item(name: 'Locker', itemType: 'addon'),
          ],
          customerName: 'Jane',
          isWalkIn: true,
        ),
        'Walk-in · Jane · Day Pass +1 add-on',
      );
    });

    test('walk-in product-typed guest day-pass descriptors are prefixed', () {
      expect(
        Sale.buildDescriptor(
          items: [_item(name: 'Day Pass', itemType: 'product')],
          customerName: 'Jane',
          isWalkIn: true,
        ),
        'Walk-in · Jane · Day Pass',
      );
      expect(
        Sale.buildDescriptor(
          items: [
            _item(name: 'Day Pass', itemType: 'product'),
            _item(name: 'Locker', itemType: 'product'),
          ],
          customerName: 'Jane',
          isWalkIn: true,
        ),
        'Walk-in · Jane · Day Pass +1 add-on',
      );
    });

    test('walk-in itemType guest day-pass descriptors are prefixed', () {
      expect(
        Sale.buildDescriptor(
          items: [_item(name: 'Day Pass', itemType: 'walkIn')],
          customerName: 'Jane',
          isWalkIn: true,
        ),
        'Walk-in · Jane · Day Pass',
      );
      expect(
        Sale.buildDescriptor(
          items: [
            _item(name: 'Day Pass', itemType: 'walkIn'),
            _item(name: 'Locker', itemType: 'walkIn'),
          ],
          customerName: 'Jane',
          isWalkIn: true,
        ),
        'Walk-in · Jane · Day Pass +1 add-on',
      );
    });

    test('product lines', () {
      expect(
        Sale.buildDescriptor(items: [_item(name: 'WATER')]),
        'WATER',
      );
      expect(
        Sale.buildDescriptor(
          items: [
            _item(name: 'WATER'),
            _item(name: 'SNACK'),
            _item(name: 'SHAKE'),
          ],
        ),
        'WATER +2 more',
      );
    });
  });
}
