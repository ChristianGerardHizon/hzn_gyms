import 'member_membership.dart';

/// Branches where a member currently has check-in access via active memberships.
class MemberBranchActivity {
  const MemberBranchActivity({required this.branchIds});

  /// Branch IDs where the member is currently active.
  final Set<String> branchIds;

  /// No active branch access.
  bool get isEmpty => branchIds.isEmpty;

  /// Active at exactly one branch.
  bool get isSingle => branchIds.length == 1;

  /// Active at two or more branches.
  bool get isMultiple => branchIds.length > 1;

  /// Active at every branch in the organization.
  bool coversAllBranches(List<String> allBranchIds) {
    if (allBranchIds.isEmpty) return false;
    return branchIds.length == allBranchIds.length &&
        allBranchIds.every(branchIds.contains);
  }
}

/// Union of branches where any [isCurrentlyActive] membership grants access.
MemberBranchActivity resolveMemberActiveBranchIds({
  required Iterable<MemberMembership> memberships,
  required List<String> allBranchIds,
}) {
  final activeIds = <String>{};

  for (final membership in memberships) {
    if (!membership.isCurrentlyActive) continue;

    if (membership.membershipValidBranches.isEmpty) {
      activeIds.addAll(allBranchIds);
    } else {
      activeIds.addAll(membership.membershipValidBranches);
    }
  }

  return MemberBranchActivity(branchIds: activeIds);
}
