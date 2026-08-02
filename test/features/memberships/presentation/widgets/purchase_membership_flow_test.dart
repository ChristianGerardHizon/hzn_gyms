import 'package:ebe_gym/src/features/memberships/presentation/widgets/purchase_membership_dialog.dart';
import 'package:ebe_gym/src/features/pos/domain/sale.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('shouldOpenRecordPaymentAfterPurchase', () {
    MembershipPurchaseResult result({
      Sale? sale,
      bool queuedOffline = false,
    }) {
      return MembershipPurchaseResult(
        sale: sale,
        totalPrice: 100,
        queuedOffline: queuedOffline,
      );
    }

    test('returns false for renewals even when a sale exists', () {
      expect(
        shouldOpenRecordPaymentAfterPurchase(
          isRenewal: true,
          result: result(sale: buildSale()),
        ),
        isFalse,
      );
    });

    test('returns false when excluded from sales', () {
      expect(
        shouldOpenRecordPaymentAfterPurchase(
          isRenewal: false,
          result: result(),
        ),
        isFalse,
      );
    });

    test('returns false when queued offline', () {
      expect(
        shouldOpenRecordPaymentAfterPurchase(
          isRenewal: false,
          result: result(sale: buildSale(), queuedOffline: true),
        ),
        isFalse,
      );
    });

    test('returns true for a normal purchase with a sale', () {
      expect(
        shouldOpenRecordPaymentAfterPurchase(
          isRenewal: false,
          result: result(sale: buildSale()),
        ),
        isTrue,
      );
    });

    test('returns false when sale is missing without excluded flag', () {
      expect(
        shouldOpenRecordPaymentAfterPurchase(
          isRenewal: false,
          result: MembershipPurchaseResult(
            sale: null,
            totalPrice: 100,
            queuedOffline: false,
          ),
        ),
        isFalse,
      );
    });
  });
}
