import 'package:dart_mappable/dart_mappable.dart';

part 'member_membership.mapper.dart';

/// Status of a member's membership subscription.
@MappableEnum()
enum MemberMembershipStatus {
  active,
  expired,
  cancelled,
  voided;

  String get displayName {
    switch (this) {
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
    this.saleId,
    this.soldBy,
    this.notes,
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

  /// Linked sale ID (if purchased through POS).
  final String? saleId;

  /// User who sold/activated this membership.
  final String? soldBy;

  /// Notes (optional).
  final String? notes;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// Whether this subscription is currently active.
  bool get isCurrentlyActive {
    if (status != MemberMembershipStatus.active) return false;
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Whether this subscription has expired based on date.
  bool get isExpired => DateTime.now().isAfter(endDate);

  /// Days remaining until expiry (0 if expired).
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }
}
