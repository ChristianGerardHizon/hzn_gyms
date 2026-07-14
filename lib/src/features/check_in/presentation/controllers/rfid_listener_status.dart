import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rfid_listener_status.g.dart';

/// Whether the global RFID keyboard-wedge listener is active.
enum RfidListenerStatus {
  /// Hardware keyboard handler is registered and accepting scans.
  listening,

  /// Listener is inactive (web, not mounted, or failed to attach).
  unavailable,
}

/// Exposes RFID listener availability for the nav status icon.
@Riverpod(keepAlive: true)
class RfidListenerStatusController extends _$RfidListenerStatusController {
  @override
  RfidListenerStatus build() => RfidListenerStatus.unavailable;

  void setListening() => state = RfidListenerStatus.listening;

  void setUnavailable() => state = RfidListenerStatus.unavailable;
}
