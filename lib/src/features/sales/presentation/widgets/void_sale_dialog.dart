import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Confirms voiding a sale and collects a required reason.
///
/// Returns the trimmed reason when confirmed, or null when cancelled.
Future<String?> showVoidSaleDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => const _VoidSaleDialog(),
  );
}

class _VoidSaleDialog extends HookWidget {
  const _VoidSaleDialog();

  @override
  Widget build(BuildContext context) {
    final reasonController = useTextEditingController();
    final reason = useState('');

    final canSubmit = reason.value.trim().isNotEmpty;

    return AlertDialog(
      title: const Text('Void Sale?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Are you sure you want to void this sale? Linked memberships will be voided and product stock restored. This action cannot be undone.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: reasonController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Reason',
              hintText: 'Why is this sale being voided?',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (value) => reason.value = value,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: canSubmit
              ? () => Navigator.of(context).pop(reason.value.trim())
              : null,
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Void'),
        ),
      ],
    );
  }
}
