import 'package:flutter_test/flutter_test.dart';
import 'package:ebe_gym/src/features/pos/domain/product_sale_line.dart';

void main() {
  test('hasLot is true when lotNumber is set', () {
    const line = ProductSaleLine(
      saleItemId: 'si-1',
      saleId: 'sale-1',
      receiptNumber: 'S-1',
      quantity: 1,
      unitPrice: 10,
      subtotal: 10,
      isPaid: true,
      status: 'completed',
      lotNumber: 'LOT-1',
    );
    expect(line.hasLot, isTrue);
  });

  test('hasLot is false when lotNumber is null or empty', () {
    const withoutLot = ProductSaleLine(
      saleItemId: 'si-1',
      saleId: 'sale-1',
      receiptNumber: 'S-1',
      quantity: 1,
      unitPrice: 10,
      subtotal: 10,
      isPaid: false,
      status: 'pending',
    );
    const emptyLot = ProductSaleLine(
      saleItemId: 'si-1',
      saleId: 'sale-1',
      receiptNumber: 'S-1',
      quantity: 1,
      unitPrice: 10,
      subtotal: 10,
      isPaid: false,
      status: 'pending',
      lotNumber: '',
    );
    expect(withoutLot.hasLot, isFalse);
    expect(emptyLot.hasLot, isFalse);
  });
}
