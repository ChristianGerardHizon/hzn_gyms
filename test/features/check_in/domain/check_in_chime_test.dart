import 'package:flutter_test/flutter_test.dart';
import 'package:ebe_gym/src/features/check_in/domain/card_check_in_result.dart';
import 'package:ebe_gym/src/features/check_in/domain/check_in_chime.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('resolveCheckInSuccessChime', () {
    test('returns success when days remaining is unknown', () {
      expect(resolveCheckInSuccessChime(null), CheckInChime.success);
    });

    test('returns success when days remaining is above threshold', () {
      expect(resolveCheckInSuccessChime(8), CheckInChime.success);
      expect(resolveCheckInSuccessChime(14), CheckInChime.success);
    });

    test('returns nearExpiry at and below threshold', () {
      expect(resolveCheckInSuccessChime(7), CheckInChime.nearExpiry);
      expect(resolveCheckInSuccessChime(1), CheckInChime.nearExpiry);
      expect(resolveCheckInSuccessChime(0), CheckInChime.nearExpiry);
    });
  });

  group('resolveCheckInChime', () {
    test('maps success by days remaining', () {
      expect(
        resolveCheckInChime(
          CardCheckInSuccess(
            checkIn: buildCheckIn(),
            memberName: 'Jane',
            membershipEndDate: DateTime(2026, 8, 15),
            membershipDaysRemaining: 14,
          ),
        ),
        CheckInChime.success,
      );
      expect(
        resolveCheckInChime(
          CardCheckInSuccess(
            checkIn: buildCheckIn(),
            memberName: 'Jane',
            membershipEndDate: DateTime(2026, 8, 5),
            membershipDaysRemaining: 4,
          ),
        ),
        CheckInChime.nearExpiry,
      );
    });

    test('maps all deny outcomes to failure', () {
      const denies = <CardCheckInResult>[
        CardCheckInCardNotFound(),
        CardCheckInNoActiveMembership(memberName: 'Jane'),
        CardCheckInUnpaidMembership(memberName: 'Jane'),
        CardCheckInMembershipNotValidAtBranch(memberName: 'Jane'),
        CardCheckInNoBranch(),
        CardCheckInFailed(),
        CardCheckInCooldown(remaining: Duration(seconds: 5)),
      ];
      for (final result in denies) {
        expect(resolveCheckInChime(result), CheckInChime.failure);
      }
    });
  });

  test('nearExpiryThresholdDays matches reports expiring-soon window', () {
    expect(nearExpiryThresholdDays, 7);
  });
}
