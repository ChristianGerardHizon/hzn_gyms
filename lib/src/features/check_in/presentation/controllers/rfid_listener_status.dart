import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rfid_listener_status.g.dart';

/// Whether Check-In RFID keyboard-wedge scanning is enabled.
enum RfidListenerStatus {
  /// Scanning is off (default). Tap the NFC icon to enable.
  off,

  /// Hardware keyboard handler is registered and accepting scans.
  listening,
}

/// Exposes RFID listener on/off state for the Check-In app bar toggle.
@Riverpod(keepAlive: true)
class RfidListenerStatusController extends _$RfidListenerStatusController {
  @override
  RfidListenerStatus build() => RfidListenerStatus.off;

  void enable() => state = RfidListenerStatus.listening;

  void disable() => state = RfidListenerStatus.off;

  void toggle() {
    state = state == RfidListenerStatus.listening
        ? RfidListenerStatus.off
        : RfidListenerStatus.listening;
  }
}
