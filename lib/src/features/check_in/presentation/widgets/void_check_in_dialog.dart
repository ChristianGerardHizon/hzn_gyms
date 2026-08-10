import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/permissions/current_user_permissions.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../domain/check_in.dart';
import '../controllers/check_in_controller.dart';

/// Confirms voiding a check-in; returns true when void succeeded.
Future<bool> showVoidCheckInDialog(
  BuildContext context,
  WidgetRef ref, {
  required CheckIn checkIn,
}) async {
  final canVoid =
      ref.read(currentUserPermissionsProvider).value?.canVoidCheckIns ?? false;
  if (!canVoid) return false;

  final reasonController = TextEditingController();
  try {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Void Check-In'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Void this check-in for '
                '${checkIn.memberName ?? 'this member'}? '
                'It will be removed from today\'s active list but kept for audit.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Void'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return false;

    final voided = await ref
        .read(checkInControllerProvider.notifier)
        .voidCheckIn(id: checkIn.id, reason: reasonController.text);

    if (!context.mounted) return voided != null;

    if (voided != null) {
      showSuccessSnackBar(context, message: 'Check-in voided');
      return true;
    }

    showErrorSnackBar(context, message: 'Could not void check-in');
    return false;
  } finally {
    reasonController.dispose();
  }
}
