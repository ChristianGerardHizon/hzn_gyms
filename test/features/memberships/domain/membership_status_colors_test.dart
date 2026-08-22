import 'package:kylie_gym/src/features/memberships/domain/member_membership.dart';
import 'package:kylie_gym/src/features/memberships/domain/membership_status_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('nearExpiryThresholdDays', () {
    test('matches reports expiring-soon window of 7 days', () {
      expect(nearExpiryThresholdDays, 7);
    });
  });

  group('membershipStatusColor', () {
    test('pending is amber', () {
      expect(
        membershipStatusColor(
          MemberMembershipStatus.pending,
          effectiveExpired: false,
        ),
        Colors.amber,
      );
    });

    test('active is green', () {
      expect(
        membershipStatusColor(
          MemberMembershipStatus.active,
          effectiveExpired: false,
        ),
        Colors.green,
      );
    });

    test('expired is red', () {
      expect(
        membershipStatusColor(
          MemberMembershipStatus.expired,
          effectiveExpired: false,
        ),
        Colors.red,
      );
    });

    test('voided is red like expired', () {
      expect(
        membershipStatusColor(
          MemberMembershipStatus.voided,
          effectiveExpired: false,
        ),
        Colors.red,
      );
    });

    test('cancelled is blueGrey', () {
      expect(
        membershipStatusColor(
          MemberMembershipStatus.cancelled,
          effectiveExpired: false,
        ),
        Colors.blueGrey,
      );
    });

    test('effectiveExpired overrides active to red', () {
      expect(
        membershipStatusColor(
          MemberMembershipStatus.active,
          effectiveExpired: true,
        ),
        Colors.red,
      );
    });
  });

  group('membershipLifecycleColor', () {
    test('healthy active is green', () {
      expect(
        membershipLifecycleColor(daysRemaining: nearExpiryThresholdDays + 1),
        Colors.green,
      );
    });

    test('almost expiring at threshold is orange', () {
      expect(
        membershipLifecycleColor(daysRemaining: nearExpiryThresholdDays),
        Colors.orange,
      );
    });

    test('expires today (0 days) is orange', () {
      expect(membershipLifecycleColor(daysRemaining: 0), Colors.orange);
    });

    test('past end date (negative) is red', () {
      expect(membershipLifecycleColor(daysRemaining: -1), Colors.red);
    });
  });

  group('membershipExpiringUrgencyColor', () {
    test('one day or less is red', () {
      expect(membershipExpiringUrgencyColor(daysRemaining: 0), Colors.red);
      expect(membershipExpiringUrgencyColor(daysRemaining: 1), Colors.red);
    });

    test('two through threshold days is orange', () {
      expect(membershipExpiringUrgencyColor(daysRemaining: 2), Colors.orange);
      expect(
        membershipExpiringUrgencyColor(daysRemaining: nearExpiryThresholdDays),
        Colors.orange,
      );
    });
  });
}
