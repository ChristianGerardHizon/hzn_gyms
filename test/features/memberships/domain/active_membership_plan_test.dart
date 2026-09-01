import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/features/memberships/domain/active_membership_plan.dart';
import 'package:hzn_gyms/src/features/memberships/domain/member_membership.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('findActiveMembershipForPlan', () {
    test('returns matching currently active plan', () {
      final match = buildMemberMembership(
        id: 'mm-1',
        membershipId: 'plan-a',
        status: MemberMembershipStatus.active,
      );
      final other = buildMemberMembership(
        id: 'mm-2',
        membershipId: 'plan-b',
        status: MemberMembershipStatus.active,
      );

      final found = findActiveMembershipForPlan(
        memberships: [other, match],
        planId: 'plan-a',
      );
      expect(found?.id, 'mm-1');
    });

    test('ignores non-active or different plan', () {
      final expired = buildMemberMembership(
        membershipId: 'plan-a',
        status: MemberMembershipStatus.expired,
        endDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      final pending = buildMemberMembership(
        id: 'mm-p',
        membershipId: 'plan-a',
        status: MemberMembershipStatus.pending,
      );

      expect(
        findActiveMembershipForPlan(
          memberships: [expired, pending],
          planId: 'plan-a',
        ),
        isNull,
      );
    });

    test('returns null for blank planId', () {
      expect(
        findActiveMembershipForPlan(
          memberships: [buildMemberMembership()],
          planId: '  ',
        ),
        isNull,
      );
    });
  });
}
