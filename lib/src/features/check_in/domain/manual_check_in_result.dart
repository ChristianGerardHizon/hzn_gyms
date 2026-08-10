import 'check_in.dart';

/// Outcome of a manual check-in attempt.
sealed class ManualCheckInResult {
  const ManualCheckInResult();
}

/// Check-in was recorded successfully.
class ManualCheckInSuccess extends ManualCheckInResult {
  const ManualCheckInSuccess(this.checkIn);

  final CheckIn checkIn;
}

/// Blocked because the member checked in within the cooldown window.
class ManualCheckInCooldown extends ManualCheckInResult {
  const ManualCheckInCooldown({required this.remaining});

  final Duration remaining;
}

/// No writable branch is selected (e.g. admin "All branches" mode).
class ManualCheckInNoBranch extends ManualCheckInResult {
  const ManualCheckInNoBranch();
}

/// Repository/API failure while creating the check-in.
class ManualCheckInFailed extends ManualCheckInResult {
  const ManualCheckInFailed();
}
