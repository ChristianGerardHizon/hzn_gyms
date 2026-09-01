import 'package:hzn_gyms/src/features/memberships/presentation/widgets/purchase_membership_dialog.dart';
import 'package:hzn_gyms/src/features/pos/domain/sale.dart';
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

    test('returns true when a sale exists (purchase or renew)', () {
      expect(
        shouldOpenRecordPaymentAfterPurchase(
          result: result(sale: buildSale()),
        ),
        isTrue,
      );
    });

    test('returns false when excluded from sales', () {
      expect(
        shouldOpenRecordPaymentAfterPurchase(
          result: result(),
        ),
        isFalse,
      );
    });

    test('returns false when queued offline', () {
      expect(
        shouldOpenRecordPaymentAfterPurchase(
          result: result(sale: buildSale(), queuedOffline: true),
        ),
        isFalse,
      );
    });

    test('returns false when sale is missing without excluded flag', () {
      expect(
        shouldOpenRecordPaymentAfterPurchase(
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
