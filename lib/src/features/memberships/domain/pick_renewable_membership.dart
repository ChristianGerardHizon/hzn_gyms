import 'member_membership.dart';

/// Picks the best membership to renew for [branchId], or null if none qualify.
MemberMembership? pickRenewableMembershipAtBranch(
  List<MemberMembership> memberships,
  String branchId,
) {
  final candidates = memberships
      .where(
        (m) =>
            m.status != MemberMembershipStatus.cancelled &&
            m.status != MemberMembershipStatus.voided &&
            m.isValidAtBranch(branchId),
      )
      .toList();
  if (candidates.isEmpty) return null;

  final active = candidates.where((m) => m.isCurrentlyActive).toList();
  if (active.isNotEmpty) {
    active.sort((a, b) => b.endDate.compareTo(a.endDate));
    return active.first;
  }

  candidates.sort((a, b) => b.endDate.compareTo(a.endDate));
  return candidates.first;
}
