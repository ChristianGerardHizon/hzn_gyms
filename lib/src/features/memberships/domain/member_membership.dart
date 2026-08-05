import 'package:dart_mappable/dart_mappable.dart';

import '../../../core/utils/date_utils.dart';

part 'member_membership.mapper.dart';

/// Status of a member's membership subscription.
@MappableEnum()
enum MemberMembershipStatus {
  /// Sold but linked sale is not paid yet — not valid for check-in.
  pending,
  active,
  expired,
  cancelled,
  voided;

  String get displayName {
    switch (this) {
      case MemberMembershipStatus.pending:
        return 'Pending payment';
      case MemberMembershipStatus.active:
        return 'Active';
      case MemberMembershipStatus.expired:
        return 'Expired';
      case MemberMembershipStatus.cancelled:
        return 'Cancelled';
      case MemberMembershipStatus.voided:
        return 'Voided';
    }
  }
}

/// A member's active/past membership subscription.
///
/// Links a [Member] to a [Membership] plan with start/end dates.
@MappableClass()
class MemberMembership with MemberMembershipMappable {
  const MemberMembership({
    required this.id,
    required this.memberId,
    required this.membershipId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.branchId,
    this.memberName,
    this.membershipName,
    this.membershipValidBranches = const [],
    this.saleId,
    this.soldBy,
    this.notes,
    this.idempotencyKey,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Member who purchased the membership.
  final String memberId;

  /// Membership plan ID.
  final String membershipId;

  /// Start date of the subscription.
  final DateTime startDate;

  /// End/expiry date of the subscription.
  final DateTime endDate;

  /// Current status.
  final MemberMembershipStatus status;

  /// Branch where this was sold.
  final String branchId;

  /// Member name (for display, from expand).
  final String? memberName;

  /// Membership plan name (for display, from expand).
  final String? membershipName;

  /// Plan `validBranches` from expand. Empty = valid at all branches.
  final List<String> membershipValidBranches;

  /// Linked sale ID (if purchased through POS).
  final String? saleId;

  /// User who sold/activated this membership.
  final String? soldBy;

  /// Notes (optional).
  final String? notes;

  /// Client-generated key so retries reuse this record instead of duplicating.
  final String? idempotencyKey;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// Whether this subscription is currently active.
  ///
  /// Aligns with server `fetchActive` (`startDate <= now`): the start
  /// instant itself counts as active, not only moments strictly after it.
  bool get isCurrentlyActive {
    if (status != MemberMembershipStatus.active) return false;
    final now = DateTime.now();
    return !now.isBefore(startDate) && !isBeforeToday(endDate);
  }

  /// Whether this membership belongs in the primary list on member detail.
  ///
  /// Includes active and not-yet-started plans; excludes expired-by-date
  /// (even if status is still active), pending, cancelled, and voided.
  bool get isPrimaryActiveList =>
      status == MemberMembershipStatus.active && !isExpired;

  /// Whether the linked plan grants access at [branchId].
  ///
  /// Empty [membershipValidBranches] means all branches.
  bool isValidAtBranch(String branchId) =>
      membershipValidBranches.isEmpty ||
      membershipValidBranches.contains(branchId);

  /// Whether this subscription has expired based on date.
  ///
  /// The end date is inclusive — still active through that calendar day.
  bool get isExpired => isBeforeToday(endDate);

  /// Days remaining until expiry (`0` on the expiration day).
  int get daysRemaining {
    final days = calendarDaysUntil(endDate);
    return days < 0 ? 0 : days;
  }
}
