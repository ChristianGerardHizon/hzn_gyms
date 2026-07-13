/// Pure helpers for sale payment totals and status transitions.

/// Net paid amount from payment line items (refunds subtract).
num calculateNetPaidAmount(Iterable<({String type, num amount})> payments) {
  num total = 0;
  for (final payment in payments) {
    if (payment.type.toLowerCase() == 'refund') {
      total -= payment.amount;
    } else {
      total += payment.amount;
    }
  }
  return total;
}

/// Resolves [isPaid] and the next sale [status] from payment totals.
///
/// When [currentStatus] is `refunded` or `voided`, [status] is `null` so
/// callers leave the existing status unchanged.
({bool isPaid, String? status}) resolveSalePaymentState({
  required num totalAmount,
  required num totalPaid,
  required String currentStatus,
}) {
  final isPaid = totalPaid >= totalAmount;

  if (currentStatus == 'refunded' || currentStatus == 'voided') {
    return (isPaid: isPaid, status: null);
  }

  if (isPaid) {
    return (isPaid: true, status: 'paid');
  }
  if (totalPaid > 0) {
    return (isPaid: false, status: 'awaitingPayment');
  }
  return (isPaid: false, status: 'pending');
}
