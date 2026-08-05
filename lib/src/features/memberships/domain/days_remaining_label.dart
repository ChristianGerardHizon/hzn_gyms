/// Short label for membership days remaining in badges and summary rows.
///
/// - `0` → `Expires today` (end date is inclusive)
/// - `1` → `1 day left`
/// - `n` → `n days left`
String formatDaysRemainingLabel(int daysRemaining) {
  if (daysRemaining == 0) return 'Expires today';
  if (daysRemaining == 1) return '1 day left';
  return '$daysRemaining days left';
}
