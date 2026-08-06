import '../../memberships/domain/member_membership.dart';
import '../../pos/data/repositories/sales_repository.dart';
import 'check_in_membership_eligibility.dart';

/// Why a member cannot check in at the current branch.
enum CheckInBlockReason {
  /// No membership with status active.
  noActiveMembership,

  /// Active membership exists here, but linked sale is unpaid.
  unpaidMembership,

  /// Active (and paid) membership exists, but not at this branch.
  notValidAtBranch,
}

/// Concise dialog/snackbar title for [reason].
String checkInBlockTitle(CheckInBlockReason reason) {
  return switch (reason) {
    CheckInBlockReason.noActiveMembership => 'No Active Membership',
    CheckInBlockReason.unpaidMembership => 'Membership Unpaid',
    CheckInBlockReason.notValidAtBranch => 'Wrong Branch',
  };
}

/// Concise explanation for [reason], including [memberName].
String checkInBlockMessage(CheckInBlockReason reason, String memberName) {
  return switch (reason) {
    CheckInBlockReason.noActiveMembership =>
      '$memberName has no active membership.',
    CheckInBlockReason.unpaidMembership =>
      '$memberName\'s membership is unpaid. Record payment before check-in.',
    CheckInBlockReason.notValidAtBranch =>
      '$memberName\'s membership is not valid at this branch.',
  };
}

/// Result of resolving which membership (if any) can be used for check-in.
class CheckInMembershipResolution {
  const CheckInMembershipResolution.allowed(this.membership)
      : reason = null;

  const CheckInMembershipResolution.blocked(this.reason) : membership = null;

  final MemberMembership? membership;
  final CheckInBlockReason? reason;

  bool get isAllowed => membership != null;
}

/// Picks a check-in-eligible membership at [branchId], or a block reason.
///
/// Order: no active → wrong branch → unpaid at this branch → allowed.
Future<CheckInMembershipResolution> resolveCheckInMembership({
  required List<MemberMembership> activeMemberships,
  required String branchId,
  required SalesRepository salesRepo,
}) async {
  if (activeMemberships.isEmpty) {
    return const CheckInMembershipResolution.blocked(
      CheckInBlockReason.noActiveMembership,
    );
  }

  final atBranch = activeMemberships
      .where((m) => m.isValidAtBranch(branchId))
      .toList();
  if (atBranch.isEmpty) {
    return const CheckInMembershipResolution.blocked(
      CheckInBlockReason.notValidAtBranch,
    );
  }

  final paidEligible = await filterCheckInEligibleMemberships(
    memberships: atBranch,
    salesRepo: salesRepo,
  );
  if (paidEligible.isEmpty) {
    return const CheckInMembershipResolution.blocked(
      CheckInBlockReason.unpaidMembership,
    );
  }

  return CheckInMembershipResolution.allowed(paidEligible.first);
}
