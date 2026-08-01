import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../controllers/rfid_listener_status.dart';

/// Shows RFID keyboard-wedge listening status (Check-In / Dashboard).
///
/// Green while listening; red when paused or off. Tap unfocuses any text
/// field so the next scan reaches the listener.
class RfidListenerStatusIcon extends ConsumerWidget {
  const RfidListenerStatusIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(rfidListenerStatusControllerProvider);
    final isActive = status == RfidListenerStatus.listening;

    final tooltip = switch (status) {
      RfidListenerStatus.listening => 'RFID scanning on',
      RfidListenerStatus.paused => 'RFID paused — window not in focus',
      RfidListenerStatus.off => 'RFID scanning off',
    };

    return IconButton(
      tooltip: tooltip,
      onPressed: () {
        // Unfocus search field so wedge keystrokes reach the listener.
        FocusManager.instance.primaryFocus?.unfocus();
      },
      icon: Icon(Icons.nfc, color: isActive ? Colors.green : Colors.red),
    );
  }
}
