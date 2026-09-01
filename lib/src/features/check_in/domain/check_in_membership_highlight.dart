import 'package:flutter/material.dart';

import '../../memberships/domain/member_membership.dart';
import '../../memberships/domain/membership_status_colors.dart';

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

/// Tint / accent color for a check-in membership highlight.
Color checkInMembershipHighlightColor(CheckInMembershipHighlight highlight) {
  return switch (highlight) {
    CheckInMembershipHighlight.active => Colors.green,
    CheckInMembershipHighlight.nearExpiry => Colors.orange,
    CheckInMembershipHighlight.expired => Colors.red,
  };
}

/// Trailing / status icon for a check-in membership highlight.
IconData checkInMembershipHighlightIcon(CheckInMembershipHighlight highlight) {
  return switch (highlight) {
    CheckInMembershipHighlight.active => Icons.verified,
    CheckInMembershipHighlight.nearExpiry => Icons.warning_amber_rounded,
    CheckInMembershipHighlight.expired => Icons.cancel_outlined,
  };
}
