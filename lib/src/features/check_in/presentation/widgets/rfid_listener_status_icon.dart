import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../controllers/rfid_listener_status.dart';

/// Compact NFC/RFID status indicator for nav chrome (above logout).
class RfidListenerStatusIcon extends ConsumerWidget {
  const RfidListenerStatusIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(rfidListenerStatusControllerProvider);
    final isListening = status == RfidListenerStatus.listening;
    final color = isListening ? Colors.green : Colors.red;
    final tooltip = isListening
        ? 'RFID scanner listening'
        : 'RFID scanner unavailable';

    return Tooltip(
      message: tooltip,
      child: Icon(Icons.nfc, color: color, size: 22),
    );
  }
}
