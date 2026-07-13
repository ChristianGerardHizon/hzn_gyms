import 'package:flutter_test/flutter_test.dart';
import 'package:ebe_gym/src/features/pos/domain/sale.dart';
import 'package:ebe_gym/src/features/pos/domain/sale_item.dart';

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
  });

  group('Sale.buildDescriptor', () {
    test('empty items falls back to customer or Sale', () {
      expect(Sale.buildDescriptor(items: const []), 'Sale');
      expect(
        Sale.buildDescriptor(items: const [], customerName: 'Jane'),
        'Jane',
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
