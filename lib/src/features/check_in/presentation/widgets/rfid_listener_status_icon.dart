import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../controllers/rfid_listener_status.dart';

/// Toggles RFID keyboard-wedge listening on the Check-In app bar.
///
/// Off by default (grey). Tap to enable (green); tap again to disable.
class RfidListenerStatusIcon extends ConsumerWidget {
  const RfidListenerStatusIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(rfidListenerStatusControllerProvider);
    final isListening = status == RfidListenerStatus.listening;
    final color = isListening
        ? Colors.green
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return IconButton(
      tooltip: isListening
          ? 'RFID scanning on — tap to turn off'
          : 'Tap to enable RFID scanning',
      onPressed: () {
        final notifier = ref.read(
          rfidListenerStatusControllerProvider.notifier,
        );
        if (isListening) {
          notifier.disable();
        } else {
          // Unfocus search field so wedge keystrokes reach the listener.
          FocusManager.instance.primaryFocus?.unfocus();
          notifier.enable();
        }
      },
      icon: Icon(Icons.nfc, color: color),
    );
  }
}
