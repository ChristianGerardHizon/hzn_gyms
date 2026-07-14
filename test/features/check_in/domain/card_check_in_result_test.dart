import 'package:flutter_test/flutter_test.dart';
import 'package:ebe_gym/src/features/check_in/domain/card_check_in_result.dart';

import '../../../helpers/fixtures.dart';

void main() {
  test('CardCheckInResult sealed outcomes are distinct types', () {
    final results = <CardCheckInResult>[
      CardCheckInSuccess(
        checkIn: buildCheckIn(),
        memberName: 'Jane',
        membershipName: 'Monthly Plan',
        membershipEndDate: DateTime(2026, 8, 1),
        membershipDaysRemaining: 17,
      ),
      const CardCheckInCardNotFound(),
      const CardCheckInNoActiveMembership(memberName: 'Jane'),
      const CardCheckInMembershipNotValidAtBranch(memberName: 'Jane'),
      const CardCheckInNoBranch(),
      const CardCheckInFailed(),
    ];

    expect(results.whereType<CardCheckInSuccess>(), hasLength(1));
    expect(results.whereType<CardCheckInCardNotFound>(), hasLength(1));
    expect(results.whereType<CardCheckInNoActiveMembership>(), hasLength(1));
    expect(
      results.whereType<CardCheckInMembershipNotValidAtBranch>(),
      hasLength(1),
    );
    expect(results.whereType<CardCheckInNoBranch>(), hasLength(1));
    expect(results.whereType<CardCheckInFailed>(), hasLength(1));
  });
}
