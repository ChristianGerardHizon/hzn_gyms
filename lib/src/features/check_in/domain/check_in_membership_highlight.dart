import '../../memberships/domain/member_membership.dart';
import 'check_in_chime.dart';

/// Visual membership status for check-in sidebar highlights.
enum CheckInMembershipHighlight {
  /// Active membership with more than [nearExpiryThresholdDays] remaining.
  active,

  /// Active membership expiring within [nearExpiryThresholdDays].
  nearExpiry,

  /// No active membership.
  expired,
}

/// Resolves the sidebar highlight for a member's active membership.
CheckInMembershipHighlight resolveCheckInMembershipHighlight(
  MemberMembership? membership,
) {
  if (membership == null) return CheckInMembershipHighlight.expired;
  if (membership.daysRemaining <= nearExpiryThresholdDays) {
    return CheckInMembershipHighlight.nearExpiry;
  }
  return CheckInMembershipHighlight.active;
}
