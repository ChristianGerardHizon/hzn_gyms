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

/// Shown when payment dialog is cancelled/dismissed for a freshly created sale.
Future<PaymentDisposition?> showPaymentDispositionDialog(
  BuildContext context, {
  required Sale sale,
}) {
  return showDialog<PaymentDisposition>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text('Sale is unpaid'),
      content: Text(
        '${sale.shortReceiptNumber} · ${sale.listTitle}\n\n'
        'Payment was not recorded. What should we do with this sale?',
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(PaymentDisposition.keepUnpaid),
          child: const Text('Keep unpaid'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(PaymentDisposition.voidSale),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Void sale'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(PaymentDisposition.recordPayment),
          child: const Text('Record payment'),
        ),
      ],
    ),
  );
}
