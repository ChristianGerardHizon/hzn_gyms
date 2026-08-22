import 'package:flutter_test/flutter_test.dart';
import 'package:kylie_gym/src/core/utils/date_utils.dart';
import 'package:kylie_gym/src/features/memberships/domain/member_membership.dart';
import 'package:kylie_gym/src/features/memberships/domain/membership.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('MemberMembership', () {
    test('isCurrentlyActive requires active status and date window', () {
      final active = buildMemberMembership(
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 5)),
      );
      expect(active.isCurrentlyActive, isTrue);

      final startsNow = buildMemberMembership(
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
      );
      expect(startsNow.isCurrentlyActive, isTrue);

      final cancelled = buildMemberMembership(
        status: MemberMembershipStatus.cancelled,
      );
      expect(cancelled.isCurrentlyActive, isFalse);

      final future = buildMemberMembership(
        startDate: DateTime.now().add(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 32)),
      );
      expect(future.isCurrentlyActive, isFalse);
    });

    test('isPrimaryActiveList includes active and upcoming, excludes expired',
        () {
      final active = buildMemberMembership(
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 5)),
      );
      expect(active.isPrimaryActiveList, isTrue);

      final upcoming = buildMemberMembership(
        startDate: DateTime.now().add(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 32)),
      );
      expect(upcoming.isPrimaryActiveList, isTrue);

      final dateExpired = buildMemberMembership(
        startDate: DateTime.now().subtract(const Duration(days: 40)),
        endDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(dateExpired.isPrimaryActiveList, isFalse);

      final cancelled = buildMemberMembership(
        status: MemberMembershipStatus.cancelled,
      );
      expect(cancelled.isPrimaryActiveList, isFalse);

      final pending = buildMemberMembership(
        status: MemberMembershipStatus.pending,
      );
      expect(pending.isPrimaryActiveList, isFalse);
    });

    test('isExpired uses inclusive end date', () {
      final endsToday = buildMemberMembership(endDate: DateTime.now());
      expect(endsToday.isExpired, isFalse);

      final endedYesterday = buildMemberMembership(
        endDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(endedYesterday.isExpired, isTrue);
    });

    test('daysRemaining is zero on expiration day and after', () {
      final endsToday = buildMemberMembership(endDate: DateTime.now());
      expect(endsToday.daysRemaining, 0);

      final ended = buildMemberMembership(
        endDate: DateTime.now().subtract(const Duration(days: 3)),
      );
      expect(ended.daysRemaining, 0);
    });

    test('isValidAtBranch treats empty list as all branches', () {
      final allBranches = buildMemberMembership();
      expect(allBranches.isValidAtBranch('any'), isTrue);

      final limited = buildMemberMembership(
        membershipValidBranches: const ['branch-1'],
      );
      expect(limited.isValidAtBranch('branch-1'), isTrue);
      expect(limited.isValidAtBranch('branch-2'), isFalse);
    });
  });

  group('Membership', () {
    test('isValidAtBranch and durationDisplay', () {
      const open = Membership(
        id: '1',
        name: 'Open',
        durationValue: 1,
        durationUnit: MembershipDurationUnit.months,
        price: 1,
        branchId: 'b',
      );
      expect(open.isValidAtBranch('x'), isTrue);
      expect(open.durationDisplay, '1 month');
      expect(open.memberNotRequired, isFalse);

      const limited = Membership(
        id: '2',
        name: 'Limited',
        durationValue: 1,
        durationUnit: MembershipDurationUnit.weeks,
        price: 1,
        branchId: 'b',
        validBranches: ['a'],
      );
      expect(limited.isValidAtBranch('a'), isTrue);
      expect(limited.isValidAtBranch('b'), isFalse);
      expect(limited.durationDisplay, '1 week');
    });

    test('memberNotRequired marks day-pass plans', () {
      final walkIn = buildMembership(
        name: 'Day Pass',
        durationValue: 1,
        durationUnit: MembershipDurationUnit.days,
        memberNotRequired: true,
      );
      expect(walkIn.memberNotRequired, isTrue);
      expect(buildMembership().memberNotRequired, isFalse);
    });
  });
}
