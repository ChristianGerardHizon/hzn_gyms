import 'package:flutter/material.dart';

import '../../../pos/domain/sale.dart';

/// What to do when Record Payment is dismissed after creating a sale.
enum PaymentDisposition {
  /// Re-open the record payment dialog.
  recordPayment,

  /// Leave the sale unpaid (membership stays pending / no check-in).
  keepUnpaid,

  /// Void the sale (and cascade side effects).
  voidSale,
}

/// Confirms leaving a sale unpaid after dismissing record payment.
///
/// Returns `true` when the user confirms, or `false`/`null` when cancelled.
Future<bool?> showKeepUnpaidConfirmDialog(
  BuildContext context, {
  required Sale sale,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Keep sale unpaid?'),
      content: Text(
        '${sale.shortReceiptNumber} · ${sale.listTitle}\n\n'
        'This transaction will remain unpaid. Finish payment later from '
        'Unpaid today or Sales.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Keep unpaid'),
        ),
      ],
    ),
  );
}

/// Shown when payment dialog is cancelled/dismissed for a freshly created sale.
Future<PaymentDisposition?> showPaymentDispositionDialog(
  BuildContext context, {
  required Sale sale,
}) {
  return showDialog<PaymentDisposition>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Sale is unpaid'),
      content: Text(
        '${sale.shortReceiptNumber} · ${sale.listTitle}\n\n'
        'Payment was not recorded. What should we do with this sale?',
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final confirmed = await showKeepUnpaidConfirmDialog(
              dialogContext,
              sale: sale,
            );
            if (confirmed == true && dialogContext.mounted) {
              Navigator.of(dialogContext).pop(PaymentDisposition.keepUnpaid);
            }
          },
          child: const Text('Keep unpaid'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(dialogContext).pop(PaymentDisposition.voidSale),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Void sale'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(dialogContext).pop(PaymentDisposition.recordPayment),
          child: const Text('Record payment'),
        ),
      ],
    ),
  );
}
