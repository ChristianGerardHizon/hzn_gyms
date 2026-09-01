/// Minimum time between check-ins for the same member at the same branch.
const kCheckInCooldown = Duration(seconds: 30);

/// Remaining cooldown after [lastCheckInTime], or `null` if cooldown has elapsed.
///
/// When [now] is omitted, uses [DateTime.now].
Duration? checkInCooldownRemaining(
  DateTime lastCheckInTime, {
  DateTime? now,
  Duration cooldown = kCheckInCooldown,
}) {
  final elapsed = (now ?? DateTime.now()).difference(lastCheckInTime);
  if (elapsed >= cooldown) return null;
  if (elapsed.isNegative) return cooldown;
  return cooldown - elapsed;
}

/// User-facing message when a check-in is blocked by cooldown.
String checkInCooldownMessage(Duration remaining) {
  final seconds = remaining.inSeconds.clamp(1, kCheckInCooldown.inSeconds);
  final unit = seconds == 1 ? 'second' : 'seconds';
  return 'This member checked in recently. '
      'Wait $seconds $unit before checking in again to avoid duplicates.';
}
