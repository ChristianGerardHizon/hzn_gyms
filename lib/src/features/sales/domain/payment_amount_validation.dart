/// Validates a payment amount string against [balanceDue].
///
/// Returns an error message when invalid, or `null` when valid.
String? validatePaymentAmount(String? raw, num balanceDue) {
  final text = raw?.toString().trim() ?? '';
  if (text.isEmpty) {
    return 'Amount is required';
  }

  final amount = num.tryParse(text);
  if (amount == null) {
    return 'Enter a valid number';
  }

  if (amount < 0) {
    return 'Amount cannot be less than 0';
  }

  if (amount == 0) {
    return 'Amount must be greater than 0';
  }

  if (amount > balanceDue) {
    return 'Amount cannot exceed balance due';
  }

  return null;
}
