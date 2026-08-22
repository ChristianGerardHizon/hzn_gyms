import 'package:kylie_gym/src/features/sales/domain/payment_amount_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validatePaymentAmount', () {
    const balanceDue = 100.0;

    test('rejects empty input', () {
      expect(validatePaymentAmount('', balanceDue), isNotNull);
      expect(validatePaymentAmount(null, balanceDue), isNotNull);
    });

    test('rejects non-numeric input', () {
      expect(validatePaymentAmount('abc', balanceDue), isNotNull);
    });

    test('rejects negative amounts', () {
      expect(validatePaymentAmount('-1', balanceDue), isNotNull);
    });

    test('rejects zero on submit', () {
      expect(validatePaymentAmount('0', balanceDue), isNotNull);
    });

    test('accepts valid partial payment', () {
      expect(validatePaymentAmount('50', balanceDue), isNull);
    });

    test('accepts exact balance due', () {
      expect(validatePaymentAmount('100', balanceDue), isNull);
    });

    test('rejects amount above balance due', () {
      expect(validatePaymentAmount('100.01', balanceDue), isNotNull);
      expect(validatePaymentAmount('150', balanceDue), isNotNull);
    });

    test('accepts decimal amounts within balance', () {
      expect(validatePaymentAmount('99.99', balanceDue), isNull);
      expect(validatePaymentAmount('100.00', balanceDue), isNull);
    });
  });
}
