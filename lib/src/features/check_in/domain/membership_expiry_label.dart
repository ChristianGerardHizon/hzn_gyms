import 'package:intl/intl.dart';

/// Formats membership expiry for check-in success UI.
///
/// Examples:
/// - `Expires today (Aug 01, 2026)`
/// - `Expires tomorrow (Aug 02, 2026)`
/// - `Expires Aug 15, 2026 (14 days left)`
String formatMembershipExpiryLabel({
  required DateTime endDate,
  int? daysRemaining,
  DateFormat? dateFormat,
}) {
  final format = dateFormat ?? DateFormat('MMM dd, yyyy');
  final dateText = format.format(endDate);
  if (daysRemaining == null) return 'Expires $dateText';
  if (daysRemaining == 0) return 'Expires today ($dateText)';
  if (daysRemaining == 1) return 'Expires tomorrow ($dateText)';
  return 'Expires $dateText ($daysRemaining days left)';
}
