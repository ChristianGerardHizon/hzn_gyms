import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/features/pos/domain/payment_method.dart';
import 'package:hzn_gyms/src/features/pos/domain/payment_type.dart';
import 'package:hzn_gyms/src/features/pos/domain/sale_status.dart';

void main() {
  group('PaymentType.displayName', () {
    test('maps each type', () {
      expect(PaymentType.payment.displayName, 'Cash');
      expect(PaymentType.deposit.displayName, 'GCash/Bank');
      expect(PaymentType.refund.displayName, 'Refund');
    });
  });

  group('PaymentType.forRecording', () {
    test('includes payment and deposit but not refund', () {
      expect(
        PaymentType.forRecording,
        [PaymentType.payment, PaymentType.deposit],
      );
      expect(PaymentType.forRecording, isNot(contains(PaymentType.refund)));
    });
  });

  group('PaymentMethod.displayName', () {
    test('maps each method', () {
      expect(PaymentMethod.cash.displayName, 'Cash');
      expect(PaymentMethod.card.displayName, 'Card');
      expect(PaymentMethod.bankTransfer.displayName, 'Bank Transfer');
      expect(PaymentMethod.check.displayName, 'Check');
    });
  });

  group('SaleStatus.displayName', () {
    test('maps each status including voided', () {
      expect(SaleStatus.pending.displayName, 'Pending');
      expect(SaleStatus.awaitingPayment.displayName, 'Awaiting Payment');
      expect(SaleStatus.paid.displayName, 'Paid');
      expect(SaleStatus.completed.displayName, 'Completed');
      expect(SaleStatus.voided.displayName, 'Voided');
    });
  });
}
