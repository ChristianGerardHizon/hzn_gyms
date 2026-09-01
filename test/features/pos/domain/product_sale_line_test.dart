import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/features/pos/domain/product_sale_line.dart';

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

  group('countsTowardSalesTotals', () {
    ProductSaleLine lineWithStatus(String status) => ProductSaleLine(
          saleItemId: 'si-1',
          saleId: 'sale-1',
          receiptNumber: 'S-1',
          quantity: 2,
          unitPrice: 10,
          subtotal: 20,
          isPaid: status == 'paid' || status == 'completed',
          status: status,
        );

    test('includes completed and paid', () {
      expect(lineWithStatus('completed').countsTowardSalesTotals, isTrue);
      expect(lineWithStatus('paid').countsTowardSalesTotals, isTrue);
    });

    test('excludes voided, pending, and awaiting payment', () {
      expect(lineWithStatus('voided').countsTowardSalesTotals, isFalse);
      expect(lineWithStatus('pending').countsTowardSalesTotals, isFalse);
      expect(
        lineWithStatus('awaitingPayment').countsTowardSalesTotals,
        isFalse,
      );
    });
  });
}
