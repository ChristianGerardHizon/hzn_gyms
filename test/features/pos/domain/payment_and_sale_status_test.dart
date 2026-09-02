import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/features/pos/domain/payment_method.dart';
import 'package:hzn_gyms/src/features/pos/domain/payment_type.dart';
import 'package:hzn_gyms/src/features/pos/domain/sale_status.dart';

void main() {
  group('PaymentType.displayName', () {
    test('maps each type', () {
      expect(PaymentType.payment.displayName, 'Payment');
      expect(PaymentType.deposit.displayName, 'Deposit');
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
      expect(PaymentMethod.card.displayName, 'GCash');
      expect(PaymentMethod.bankTransfer.displayName, 'Bank Transfer');
      expect(PaymentMethod.check.displayName, 'Check');
    });
  });

  group('PaymentMethod.forRecording', () {
    test('includes all payment methods', () {
      expect(
        PaymentMethod.forRecording,
        [
          PaymentMethod.cash,
          PaymentMethod.card,
          PaymentMethod.bankTransfer,
          PaymentMethod.check,
        ],
      );
    });
  });

  group('PaymentMethod.recordingPaymentType', () {
    test('maps cash to payment and others to deposit', () {
      expect(PaymentMethod.cash.recordingPaymentType, PaymentType.payment);
      expect(PaymentMethod.card.recordingPaymentType, PaymentType.deposit);
      expect(
        PaymentMethod.bankTransfer.recordingPaymentType,
        PaymentType.deposit,
      );
      expect(PaymentMethod.check.recordingPaymentType, PaymentType.deposit);
    });
  });

  group('PaymentMethod proof and reference visibility', () {
    test('cash hides proof and reference; others show both', () {
      expect(PaymentMethod.cash.showsPaymentProof, isFalse);
      expect(PaymentMethod.cash.showsPaymentReference, isFalse);

      for (final method in [
        PaymentMethod.card,
        PaymentMethod.bankTransfer,
        PaymentMethod.check,
      ]) {
        expect(method.showsPaymentProof, isTrue, reason: method.name);
        expect(method.showsPaymentReference, isTrue, reason: method.name);
      }
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
