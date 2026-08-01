import 'package:flutter/material.dart';

import '../../domain/check_in_chime.dart';
import '../utils/check_in_sound_player.dart';

/// Shows an error dialog after a failed RFID/card check-in.
Future<void> showCheckInErrorDialog(
  BuildContext context, {
  required String title,
  required String message,
}) {
  CheckInSoundPlayer.play(CheckInChime.failure);
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      icon: Icon(
        Icons.error_outline,
        color: Theme.of(context).colorScheme.error,
        size: 48,
      ),
      title: Text(title),
      content: SelectableText(message, textAlign: TextAlign.center),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
