import 'package:flutter/material.dart';

import 'member_membership.dart';

/// Days remaining at or below this value are treated as "almost expiring".
///
/// Matches reports/dashboard "Expiring Soon (7d)" and check-in near-expiry.
const int nearExpiryThresholdDays = 7;

/// Color for a [MemberMembershipStatus] badge/chip.
///
/// When [effectiveExpired] is true (status still `active` but past end date),
/// returns red like an expired membership.
Color membershipStatusColor(
  MemberMembershipStatus status, {
  required bool effectiveExpired,
}) {
  if (effectiveExpired) return Colors.red;
  return switch (status) {
    MemberMembershipStatus.pending => Colors.amber,
    MemberMembershipStatus.active => Colors.green,
    MemberMembershipStatus.expired => Colors.red,
    MemberMembershipStatus.voided => Colors.red,
    MemberMembershipStatus.cancelled => Colors.blueGrey,
  };
}

/// Lifecycle color from days remaining for an active membership.
///
/// - Expired / past end (`daysRemaining < 0`): red
/// - Almost expiring (`<= [nearExpiryThresholdDays]`): orange
/// - Healthy active: green
///
/// Note: [MemberMembership.daysRemaining] clamps at 0 on the expiry day,
/// so callers with a clamped value treat "expires today" as near-expiry (orange).
/// Use a negative value when distinguishing fully expired from expiry-day.
Color membershipLifecycleColor({required int daysRemaining}) {
  if (daysRemaining < 0) return Colors.red;
  if (daysRemaining <= nearExpiryThresholdDays) return Colors.orange;
  return Colors.green;
}

/// Urgency color for dashboard "expiring soon" rows (still not expired).
///
/// - ≤1 day left: red
/// - 2–[nearExpiryThresholdDays] days: orange
Color membershipExpiringUrgencyColor({required int daysRemaining}) {
  if (daysRemaining <= 1) return Colors.red;
  return Colors.orange;
}
