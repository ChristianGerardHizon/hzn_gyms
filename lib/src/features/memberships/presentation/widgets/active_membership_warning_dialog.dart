import 'package:flutter/material.dart';

/// Warns when purchasing a plan the member already has active.
///
/// Returns `true` if the user chooses to continue, `false`/`null` to cancel.
Future<bool?> showActiveMembershipWarningDialog(
  BuildContext context, {
  required String memberName,
  required String planName,
}) {
  final name = memberName.trim().isEmpty ? 'This member' : memberName.trim();
  final plan = planName.trim().isEmpty ? 'this membership' : planName.trim();
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Membership already active'),
      content: Text(
        '$name already has an active $plan membership.\n\n'
        'Do you want to continue and create another purchase?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Continue'),
        ),
      ],
    ),
  );
}
