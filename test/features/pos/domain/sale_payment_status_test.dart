import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/features/pos/domain/sale_payment_status.dart';

void main() {
  group('calculateNetPaidAmount', () {
    test('sums payments and subtracts refunds', () {
      final total = calculateNetPaidAmount([
        (type: 'payment', amount: 100),
        (type: 'deposit', amount: 50),
        (type: 'refund', amount: 20),
        (type: 'Refund', amount: 10),
      ]);
      expect(total, 120);
    });

    test('returns zero for empty list', () {
      expect(calculateNetPaidAmount([]), 0);
    });

    test('treats unknown types as additions', () {
      expect(
        calculateNetPaidAmount([(type: 'adjustment', amount: 25)]),
        25,
      );
    });

    test('net can go negative when refunds exceed payments', () {
      final total = calculateNetPaidAmount([
        (type: 'payment', amount: 30),
        (type: 'refund', amount: 50),
      ]);
      expect(total, -20);
    });

    test('refund type matching is case-insensitive', () {
      final total = calculateNetPaidAmount([
        (type: 'PAYMENT', amount: 100),
        (type: 'REFUND', amount: 40),
        (type: 'ReFuNd', amount: 10),
      ]);
      expect(total, 50);
    });
  });

  group('resolveSalePaymentState', () {
    test('fully paid', () {
      final result = resolveSalePaymentState(
        totalAmount: 100,
        totalPaid: 100,
        currentStatus: 'pending',
      );
      expect(result.isPaid, isTrue);
      expect(result.status, 'paid');
    });

    test('overpayment still marks paid', () {
      final result = resolveSalePaymentState(
        totalAmount: 100,
        totalPaid: 150,
        currentStatus: 'awaitingPayment',
      );
      expect(result.isPaid, isTrue);
      expect(result.status, 'paid');
    });

    test('partial payment', () {
      final result = resolveSalePaymentState(
        totalAmount: 100,
        totalPaid: 40,
        currentStatus: 'pending',
      );
      expect(result.isPaid, isFalse);
      expect(result.status, 'awaitingPayment');
    });

    test('no payment', () {
      final result = resolveSalePaymentState(
        totalAmount: 100,
        totalPaid: 0,
        currentStatus: 'awaitingPayment',
      );
      expect(result.isPaid, isFalse);
      expect(result.status, 'pending');
    });

    test('zero-total sale is paid with no payments', () {
      final result = resolveSalePaymentState(
        totalAmount: 0,
        totalPaid: 0,
        currentStatus: 'pending',
      );
      expect(result.isPaid, isTrue);
      expect(result.status, 'paid');
    });

    test('skips status update for voided but still reports isPaid', () {
      final voidedPaid = resolveSalePaymentState(
        totalAmount: 100,
        totalPaid: 80,
        currentStatus: 'voided',
      );
      expect(voidedPaid.isPaid, isFalse);
      expect(voidedPaid.status, isNull);

      final voidedUnpaid = resolveSalePaymentState(
        totalAmount: 100,
        totalPaid: 0,
        currentStatus: 'voided',
      );
      expect(voidedUnpaid.isPaid, isFalse);
      expect(voidedUnpaid.status, isNull);
    });

    test('skips status update for legacy refunded sales', () {
      final result = resolveSalePaymentState(
        totalAmount: 100,
        totalPaid: 50,
        currentStatus: 'refunded',
      );
      expect(result.isPaid, isFalse);
      expect(result.status, isNull);
      expect(isClosedSaleStatus('Refunded'), isTrue);
    });

    test('voiding all payments from paid status returns pending', () {
      // After voiding the only payment, totalPaid is 0 — sale should
      // move back to pending (mirrors deletePayment → _updateSaleIsPaid).
      final result = resolveSalePaymentState(
        totalAmount: 100,
        totalPaid: 0,
        currentStatus: 'paid',
      );
      expect(result.isPaid, isFalse);
      expect(result.status, 'pending');
    });

    test('voiding a partial payment leaves awaitingPayment when remainder > 0',
        () {
      final result = resolveSalePaymentState(
        totalAmount: 100,
        totalPaid: 25,
        currentStatus: 'paid',
      );
      expect(result.isPaid, isFalse);
      expect(result.status, 'awaitingPayment');
    });
  });
}
