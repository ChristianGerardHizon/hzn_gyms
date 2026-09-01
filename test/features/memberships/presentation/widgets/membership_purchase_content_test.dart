import 'package:hzn_gyms/src/features/memberships/presentation/widgets/membership_purchase_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shouldSkipMembershipSale', () {
    test('skips sale when permitted and excludeFromSales is checked', () {
      expect(
        shouldSkipMembershipSale(
          guestMode: false,
          excludeFromSales: true,
          canExcludeFromSales: true,
        ),
        isTrue,
      );
    });

    test('does not skip without permission even if checked', () {
      expect(
        shouldSkipMembershipSale(
          guestMode: false,
          excludeFromSales: true,
          canExcludeFromSales: false,
        ),
        isFalse,
      );
    });

    test('does not skip when unchecked', () {
      expect(
        shouldSkipMembershipSale(
          guestMode: false,
          excludeFromSales: false,
          canExcludeFromSales: true,
        ),
        isFalse,
      );
    });

    test('never skips in guest mode', () {
      expect(
        shouldSkipMembershipSale(
          guestMode: true,
          excludeFromSales: true,
          canExcludeFromSales: true,
        ),
        isFalse,
      );
    });
  });
}
