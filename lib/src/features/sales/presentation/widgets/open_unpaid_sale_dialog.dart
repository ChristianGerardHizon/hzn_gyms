import 'package:flutter/material.dart';

import '../../../pos/domain/sale.dart';

/// Choice when an open unpaid sale already exists for the same person.
enum OpenUnpaidSaleAction {
  /// Navigate / focus the existing unpaid sale (do not create another).
  openExisting,

  /// Void the existing unpaid sale so a new one can be created.
  voidAndRecreate,

  /// Abort.
  cancel,
}

/// Prompts when a duplicate open unpaid sale is found.
Future<OpenUnpaidSaleAction?> showOpenUnpaidSaleDialog(
  BuildContext context, {
  required Sale existingSale,
}) {
  final label = existingSale.listTitle;
  final receipt = existingSale.shortReceiptNumber;
  return showDialog<OpenUnpaidSaleAction>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Unpaid sale already exists'),
      content: Text(
        'There is already an unpaid sale for this customer '
        '($receipt · $label).\n\n'
        'Open it to record payment, or void it before creating a new sale.',
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(OpenUnpaidSaleAction.cancel),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(OpenUnpaidSaleAction.openExisting),
          child: const Text('Open existing'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(OpenUnpaidSaleAction.voidAndRecreate),
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Void & recreate'),
        ),
      ],
    ),
  );
}
