import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rfid_listener_status.g.dart';

/// Whether Check-In RFID keyboard-wedge scanning is active.
enum RfidListenerStatus {
  /// Check-In page not mounted (or listener disposed).
  off,

  /// Hardware keyboard handler is registered and accepting scans.
  listening,

  /// Check-In is open but the app/window lacks OS focus — scans paused.
  paused,
}

/// Exposes RFID listener state for the Check-In app bar indicator.
@Riverpod(keepAlive: true)
class RfidListenerStatusController extends _$RfidListenerStatusController {
  /// Refcount of UIs that need exclusive RFID capture (e.g. Add Card).
  ///
  /// Does not notify listeners — read synchronously from the key handler.
  int _checkInHoldCount = 0;

  @override
  RfidListenerStatus build() => RfidListenerStatus.off;

  /// Whether check-in should ignore wedge scans (Add Card / card entry open).
  bool get isCheckInHeld => _checkInHoldCount > 0;

  void enable() => state = RfidListenerStatus.listening;

  void pause() => state = RfidListenerStatus.paused;

  void disable() => state = RfidListenerStatus.off;

  void acquireCheckInHold() => _checkInHoldCount++;

  void releaseCheckInHold() {
    if (_checkInHoldCount > 0) _checkInHoldCount--;
  }
}
