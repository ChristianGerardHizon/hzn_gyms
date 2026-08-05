import 'member_membership.dart';

/// Finds an active membership for the exact [planId], if any.
///
/// Prefers [MemberMembership.isCurrentlyActive] (status + date window).
MemberMembership? findActiveMembershipForPlan({
  required Iterable<MemberMembership> memberships,
  required String planId,
}) {
  final id = planId.trim();
  if (id.isEmpty) return null;
  for (final membership in memberships) {
    if (membership.membershipId == id && membership.isCurrentlyActive) {
      return membership;
    }
  }
  return null;
}
