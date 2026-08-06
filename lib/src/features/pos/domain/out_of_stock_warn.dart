/// Result of the out-of-stock continue dialog.
class OutOfStockContinueResult {
  const OutOfStockContinueResult({
    required this.continueSale,
    required this.snoozeUntilTomorrow,
  });

  /// User chose to add the product anyway.
  final bool continueSale;

  /// Persist a snooze so the warning is skipped until tomorrow.
  final bool snoozeUntilTomorrow;
}

/// Preference key for snoozing the out-of-stock cashier warning for [productId].
String outOfStockWarnSnoozeKey(String productId) =>
    'pos.outOfStockWarnSnoozeUntil.$productId';

/// Start of the next local calendar day (when a "until tomorrow" snooze expires).
DateTime startOfNextLocalDay([DateTime? now]) {
  final local = (now ?? DateTime.now()).toLocal();
  return DateTime(local.year, local.month, local.day + 1);
}

/// Whether [snoozeUntilIso] (UTC ISO-8601) is still active at [now].
bool isOutOfStockWarnSnoozeActive(String? snoozeUntilIso, [DateTime? now]) {
  if (snoozeUntilIso == null || snoozeUntilIso.isEmpty) return false;
  final until = DateTime.tryParse(snoozeUntilIso);
  if (until == null) return false;
  final current = now ?? DateTime.now();
  return current.toUtc().isBefore(until.toUtc());
}
