import 'member_membership.dart';

/// Picks the best membership to renew from [memberships], or null if none qualify.
///
/// Excludes cancelled/voided. Prefers [MemberMembership.isCurrentlyActive],
/// otherwise the latest [MemberMembership.endDate].
MemberMembership? pickRenewableMembership(List<MemberMembership> memberships) {
  final candidates = memberships
      .where(
        (m) =>
            m.status != MemberMembershipStatus.cancelled &&
            m.status != MemberMembershipStatus.voided,
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

/// Picks the best membership to renew for [branchId], or null if none qualify.
MemberMembership? pickRenewableMembershipAtBranch(
  List<MemberMembership> memberships,
  String branchId,
) {
  return pickRenewableMembership(
    memberships.where((m) => m.isValidAtBranch(branchId)).toList(),
  );
}
