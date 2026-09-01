import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/features/memberships/domain/member_branch_activity.dart';
import 'package:hzn_gyms/src/features/memberships/domain/member_membership.dart';

import '../../../helpers/fixtures.dart';

void main() {
  const allBranchIds = ['branch-1', 'branch-2', 'branch-3'];

  group('resolveMemberActiveBranchIds', () {
    test('returns empty when no memberships', () {
      final result = resolveMemberActiveBranchIds(
        memberships: const [],
        allBranchIds: allBranchIds,
      );
      expect(result.isEmpty, isTrue);
      expect(result.branchIds, isEmpty);
    });

    test('returns empty when memberships are not currently active', () {
      final result = resolveMemberActiveBranchIds(
        memberships: [
          buildMemberMembership(
            status: MemberMembershipStatus.cancelled,
            membershipValidBranches: const ['branch-1'],
          ),
          buildMemberMembership(
            startDate: DateTime.now().add(const Duration(days: 5)),
            endDate: DateTime.now().add(const Duration(days: 35)),
            membershipValidBranches: const ['branch-2'],
          ),
        ],
        allBranchIds: allBranchIds,
      );
      expect(result.isEmpty, isTrue);
    });

    test('returns single branch for one limited plan', () {
      final result = resolveMemberActiveBranchIds(
        memberships: [
          buildMemberMembership(
            membershipValidBranches: const ['branch-2'],
          ),
        ],
        allBranchIds: allBranchIds,
      );
      expect(result.isSingle, isTrue);
      expect(result.branchIds, {'branch-2'});
    });

    test('unions branches from multiple active memberships', () {
      final result = resolveMemberActiveBranchIds(
        memberships: [
          buildMemberMembership(
            id: 'mm-1',
            membershipValidBranches: const ['branch-1'],
          ),
          buildMemberMembership(
            id: 'mm-2',
            membershipValidBranches: const ['branch-3'],
          ),
        ],
        allBranchIds: allBranchIds,
      );
      expect(result.isMultiple, isTrue);
      expect(result.branchIds, {'branch-1', 'branch-3'});
    });

    test('dedupes overlapping branch access', () {
      final result = resolveMemberActiveBranchIds(
        memberships: [
          buildMemberMembership(
            id: 'mm-1',
            membershipValidBranches: const ['branch-1', 'branch-2'],
          ),
          buildMemberMembership(
            id: 'mm-2',
            membershipValidBranches: const ['branch-2'],
          ),
        ],
        allBranchIds: allBranchIds,
      );
      expect(result.branchIds, {'branch-1', 'branch-2'});
    });

    test('all-branches plan adds every org branch', () {
      final result = resolveMemberActiveBranchIds(
        memberships: [buildMemberMembership()],
        allBranchIds: allBranchIds,
      );
      expect(result.coversAllBranches(allBranchIds), isTrue);
      expect(result.branchIds, allBranchIds.toSet());
    });

    test('mixes all-branches and limited plans', () {
      final result = resolveMemberActiveBranchIds(
        memberships: [
          buildMemberMembership(id: 'mm-1'),
          buildMemberMembership(
            id: 'mm-2',
            membershipValidBranches: const ['branch-1'],
          ),
        ],
        allBranchIds: allBranchIds,
      );
      expect(result.coversAllBranches(allBranchIds), isTrue);
    });
  });

  group('MemberBranchActivity', () {
    test('coversAllBranches is false when subset only', () {
      const activity = MemberBranchActivity(branchIds: {'branch-1'});
      expect(activity.coversAllBranches(allBranchIds), isFalse);
    });
  });
}
