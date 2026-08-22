import 'package:kylie_gym/src/features/memberships/domain/member_membership.dart';
import 'package:kylie_gym/src/features/memberships/domain/pick_renewable_membership.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('pickRenewableMembershipAtBranch', () {
    test('returns null when no memberships valid at branch', () {
      final result = pickRenewableMembershipAtBranch(
        [
          buildMemberMembership(
            membershipValidBranches: const ['branch-1'],
          ),
        ],
        'branch-2',
      );
      expect(result, isNull);
    });

    test('returns active membership at branch', () {
      final active = buildMemberMembership(
        id: 'mm-active',
        membershipValidBranches: const ['branch-2'],
      );
      final result = pickRenewableMembershipAtBranch(
        [active],
        'branch-2',
      );
      expect(result?.id, 'mm-active');
    });

    test('ignores cancelled memberships at branch', () {
      final result = pickRenewableMembershipAtBranch(
        [
          buildMemberMembership(
            status: MemberMembershipStatus.cancelled,
            membershipValidBranches: const ['branch-1'],
          ),
        ],
        'branch-1',
      );
      expect(result, isNull);
    });

    test('treats empty validBranches as all branches', () {
      final active = buildMemberMembership(
        membershipValidBranches: const [],
      );
      final result = pickRenewableMembershipAtBranch(
        [active],
        'any-branch',
      );
      expect(result, isNotNull);
    });

    test('prefers latest active end date among multiple at branch', () {
      final earlier = buildMemberMembership(
        id: 'mm-early',
        endDate: DateTime.now().add(const Duration(days: 10)),
        membershipValidBranches: const ['branch-1'],
      );
      final later = buildMemberMembership(
        id: 'mm-late',
        endDate: DateTime.now().add(const Duration(days: 30)),
        membershipValidBranches: const ['branch-1'],
      );
      final result = pickRenewableMembershipAtBranch(
        [earlier, later],
        'branch-1',
      );
      expect(result?.id, 'mm-late');
    });
  });
}
