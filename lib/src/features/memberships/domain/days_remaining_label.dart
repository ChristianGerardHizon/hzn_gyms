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

/// Short label for membership months remaining on dashboard cards.
///
/// - `1` → `1 month left`
/// - `n` → `n months left`
String formatMonthsRemainingLabel(int monthsRemaining) {
  if (monthsRemaining == 1) return '1 month left';
  return '$monthsRemaining months left';
}
