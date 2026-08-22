import 'package:kylie_gym/src/features/memberships/domain/member_membership.dart';
import 'package:kylie_gym/src/features/memberships/domain/membership_payment_lifecycle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveMembershipStatusForSaleChange', () {
    test('paid sale activates membership', () {
      expect(
        resolveMembershipStatusForSaleChange(
          saleStatus: 'paid',
          saleIsPaid: true,
          current: MemberMembershipStatus.pending,
        ),
        MemberMembershipStatus.active,
      );
    });

    test('voided sale voids membership', () {
      expect(
        resolveMembershipStatusForSaleChange(
          saleStatus: 'voided',
          saleIsPaid: false,
        ),
        MemberMembershipStatus.voided,
      );
    });

    test('still unpaid leaves pending unchanged', () {
      expect(
        resolveMembershipStatusForSaleChange(
          saleStatus: 'awaitingPayment',
          saleIsPaid: false,
          current: MemberMembershipStatus.pending,
        ),
        isNull,
      );
    });
  });

  group('isMembershipEligibleForCheckIn', () {
    test('active without sale is eligible', () {
      expect(
        isMembershipEligibleForCheckIn(
          status: MemberMembershipStatus.active,
        ),
        isTrue,
      );
    });

    test('pending is never eligible', () {
      expect(
        isMembershipEligibleForCheckIn(
          status: MemberMembershipStatus.pending,
          saleId: 'sale-1',
          saleIsPaid: true,
        ),
        isFalse,
      );
    });

    test('active with unpaid linked sale is not eligible', () {
      expect(
        isMembershipEligibleForCheckIn(
          status: MemberMembershipStatus.active,
          saleId: 'sale-1',
          saleIsPaid: false,
          saleStatus: 'awaitingPayment',
        ),
        isFalse,
      );
    });

    test('active with paid linked sale is eligible', () {
      expect(
        isMembershipEligibleForCheckIn(
          status: MemberMembershipStatus.active,
          saleId: 'sale-1',
          saleIsPaid: true,
          saleStatus: 'paid',
        ),
        isTrue,
      );
    });
  });
}
