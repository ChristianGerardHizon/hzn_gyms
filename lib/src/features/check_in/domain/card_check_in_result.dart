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
  });

  final CheckIn checkIn;
  final String memberName;
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

/// No writable branch is selected (e.g. admin "All branches" mode).
class CardCheckInNoBranch extends CardCheckInResult {
  const CardCheckInNoBranch();
}

/// Repository/API failure while creating the check-in.
class CardCheckInFailed extends CardCheckInResult {
  const CardCheckInFailed();
}
