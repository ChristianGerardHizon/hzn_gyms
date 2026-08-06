import '../../memberships/domain/membership_status_colors.dart';
import 'card_check_in_result.dart';

export '../../memberships/domain/membership_status_colors.dart'
    show nearExpiryThresholdDays;

/// Audible feedback for a check-in outcome.
enum CheckInChime {
  /// Valid membership, not near expiry.
  success,

  /// Valid membership that expires within [nearExpiryThresholdDays].
  nearExpiry,

  /// Denied or failed check-in.
  failure,
}

/// Resolves the chime for a successful check-in with optional days remaining.
///
/// When [daysRemaining] is unknown (`null`), treats as not near expiry.
CheckInChime resolveCheckInSuccessChime(int? daysRemaining) {
  if (daysRemaining != null && daysRemaining <= nearExpiryThresholdDays) {
    return CheckInChime.nearExpiry;
  }
  return CheckInChime.success;
}

/// Maps a card check-in result to the chime that should play.
CheckInChime resolveCheckInChime(CardCheckInResult result) {
  return switch (result) {
    CardCheckInSuccess(:final membershipDaysRemaining) =>
      resolveCheckInSuccessChime(membershipDaysRemaining),
    CardCheckInCardNotFound() ||
    CardCheckInNoActiveMembership() ||
    CardCheckInUnpaidMembership() ||
    CardCheckInMembershipNotValidAtBranch() ||
    CardCheckInNoBranch() ||
    CardCheckInFailed() =>
      CheckInChime.failure,
  };
}
