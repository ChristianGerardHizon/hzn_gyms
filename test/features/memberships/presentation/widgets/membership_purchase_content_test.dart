import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/features/memberships/domain/membership.dart';
import 'package:hzn_gyms/src/features/memberships/presentation/widgets/membership_purchase_content.dart';

import '../../../../helpers/fixtures.dart';

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

  group('soleAvailableMembershipPlan', () {
    Membership plan({
      required String id,
      bool isActive = true,
    }) =>
        buildMembership(id: id, isActive: isActive);

    test('returns the only active plan', () {
      final sole = plan(id: 'solo');
      expect(
        soleAvailableMembershipPlan([
          sole,
          plan(id: 'inactive', isActive: false),
        ]),
        same(sole),
      );
    });

    test('returns null when multiple active plans exist', () {
      expect(
        soleAvailableMembershipPlan([
          plan(id: 'a'),
          plan(id: 'b'),
        ]),
        isNull,
      );
    });

    test('returns null when no active plans exist', () {
      expect(
        soleAvailableMembershipPlan([
          plan(id: 'inactive', isActive: false),
        ]),
        isNull,
      );
    });

    test('returns null for an empty catalog', () {
      expect(soleAvailableMembershipPlan(const []), isNull);
    });
  });
}
