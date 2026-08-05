import 'check_in.dart';

/// Outcome of an RFID/barcode card check-in attempt.
sealed class CardCheckInResult {
  const CardCheckInResult();
}

/// Check-in was recorded successfully.
class CardCheckInSuccess extends CardCheckInResult {
  const CardCheckInSuccess({
    required this.checkIn,
    required this.memberName,
    required this.membershipEndDate,
    this.membershipName,
    this.membershipDaysRemaining,
    this.memberPhoto,
  });

  final CheckIn checkIn;
  final String memberName;

  /// Plan display name (from expand), when available.
  final String? membershipName;

  /// Inclusive end/expiry date of the membership used for check-in.
  final DateTime membershipEndDate;

  /// Days left until expiry (`0` on the expiration day), when known.
  final int? membershipDaysRemaining;

  /// Member profile photo URL, when available.
  final String? memberPhoto;
}

/// No member card (or legacy RFID) matched the scanned value.
class CardCheckInCardNotFound extends CardCheckInResult {
  const CardCheckInCardNotFound();
}

/// Member was found but has no active membership.
class CardCheckInNoActiveMembership extends CardCheckInResult {
  const CardCheckInNoActiveMembership({required this.memberName});

  final String memberName;
}

/// Member has an active membership, but it is not valid at this branch.
class CardCheckInMembershipNotValidAtBranch extends CardCheckInResult {
  const CardCheckInMembershipNotValidAtBranch({required this.memberName});

  final String memberName;
}

/// No writable branch is selected (e.g. admin "All branches" mode).
class CardCheckInNoBranch extends CardCheckInResult {
  const CardCheckInNoBranch();
}

/// Repository/API failure while creating the check-in.
class CardCheckInFailed extends CardCheckInResult {
  const CardCheckInFailed();
}
