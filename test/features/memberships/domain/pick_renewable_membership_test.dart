import 'package:hzn_gyms/src/features/memberships/domain/member_membership.dart';
import 'package:hzn_gyms/src/features/memberships/domain/pick_renewable_membership.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('pickRenewableMembership', () {
    test('returns null when only cancelled or voided', () {
      final result = pickRenewableMembership([
        buildMemberMembership(status: MemberMembershipStatus.cancelled),
        buildMemberMembership(
          id: 'mm-void',
          status: MemberMembershipStatus.voided,
        ),
      ]);
      expect(result, isNull);
    });

    test('returns active membership regardless of validBranches', () {
      final active = buildMemberMembership(
        id: 'mm-active',
        membershipValidBranches: const ['branch-1'],
      );
      final result = pickRenewableMembership([active]);
      expect(result?.id, 'mm-active');
    });

    test('prefers currently active over pending', () {
      final pending = buildMemberMembership(
        id: 'mm-pending',
        status: MemberMembershipStatus.pending,
        endDate: DateTime.now().add(const Duration(days: 60)),
      );
      final active = buildMemberMembership(
        id: 'mm-active',
        endDate: DateTime.now().add(const Duration(days: 10)),
      );
      final result = pickRenewableMembership([pending, active]);
      expect(result?.id, 'mm-active');
    });

    test('prefers latest end date among currently active', () {
      final earlier = buildMemberMembership(
        id: 'mm-early',
        endDate: DateTime.now().add(const Duration(days: 10)),
      );
      final later = buildMemberMembership(
        id: 'mm-late',
        endDate: DateTime.now().add(const Duration(days: 30)),
      );
      final result = pickRenewableMembership([earlier, later]);
      expect(result?.id, 'mm-late');
    });
  });

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
