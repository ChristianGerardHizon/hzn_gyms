import 'member_membership.dart';

/// Resolves membership status when its linked sale payment state changes.
///
/// - Sale becomes paid → [MemberMembershipStatus.active]
/// - Sale is voided → [MemberMembershipStatus.voided]
/// - Otherwise leaves [current] unchanged (`null` means no update)
MemberMembershipStatus? resolveMembershipStatusForSaleChange({
  required String saleStatus,
  required bool saleIsPaid,
  MemberMembershipStatus? current,
}) {
  final normalized = saleStatus.toLowerCase();
  if (normalized == 'voided') {
    return MemberMembershipStatus.voided;
  }
  if (saleIsPaid || normalized == 'paid') {
    return MemberMembershipStatus.active;
  }
  if (current == MemberMembershipStatus.pending) {
    return null;
  }
  return null;
}

/// Whether a membership may be used for check-in given linked sale payment.
///
/// Memberships without a [saleId] keep legacy behavior (status alone).
/// When [saleId] is set, [saleIsPaid] must be true (or [saleStatus] is `paid`).
bool isMembershipEligibleForCheckIn({
  required MemberMembershipStatus status,
  String? saleId,
  bool? saleIsPaid,
  String? saleStatus,
}) {
  if (status != MemberMembershipStatus.active) return false;

  final linkedSale = saleId?.trim();
  if (linkedSale == null || linkedSale.isEmpty) return true;

  if (saleIsPaid == true) return true;
  if ((saleStatus ?? '').toLowerCase() == 'paid') return true;
  return false;
}
