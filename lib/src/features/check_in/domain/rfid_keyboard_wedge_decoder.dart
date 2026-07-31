import 'package:flutter/services.dart';

/// Decodes HID keyboard-wedge RFID/barcode input from rapid key bursts.
///
/// Cheap USB RFID readers emulate a keyboard: they type the card ID and then
/// Enter. Characters arrive in a fast burst; a longer gap means a human typed,
/// so the buffer is reset.
///
/// Platform-agnostic: works with [HardwareKeyboard] on Android, iOS, desktop,
/// and web (while the Flutter app/tab has OS focus).
class RfidKeyboardWedgeDecoder {
  /// Max gap between keys before input is treated as a new (human) sequence.
  static const maxInterKeyGap = Duration(milliseconds: 60);

  /// Minimum buffered length before Enter is treated as a completed scan.
  static const minCardLength = 4;

  final StringBuffer _buffer = StringBuffer();
  DateTime? _lastKeyTime;
  bool _inScanMode = false;

  /// Whether the current buffer is a fast scanner burst (≥2 keys within gap).
  bool get inScanMode => _inScanMode;

  /// Clears the buffer and scan state.
  void reset() {
    _buffer.clear();
    _lastKeyTime = null;
    _inScanMode = false;
  }

  /// Handles a key-down event.
  ///
  /// Returns `true` when the key should be consumed (scanner burst in progress
  /// or a scan was just emitted). Returns `false` when the event should pass
  /// through (human typing, incomplete single key, unsupported key).
  ///
  /// When a valid scan is complete, [onScan] is invoked with the card ID.
  bool handleKeyDown({
    required LogicalKeyboardKey logicalKey,
    required String? character,
    required DateTime now,
    required void Function(String cardId) onScan,
  }) {
    final isEnter =
        logicalKey == LogicalKeyboardKey.enter ||
        logicalKey == LogicalKeyboardKey.numpadEnter;

    if (isEnter) {
      final cardValue = _buffer.toString().trim();
      final isScan = _inScanMode && cardValue.length >= minCardLength;
      reset();
      if (isScan) {
        onScan(cardValue);
        return true;
      }
      return false;
    }

    if (character == null ||
        character.isEmpty ||
        character == '\n' ||
        character == '\r') {
      return false;
    }

    // Ignore pure control characters.
    if (character.codeUnitAt(0) < 32) return false;

    // Prefer single printable characters (wedge readers emit one char per key).
    if (character.trim().isEmpty) return false;

    if (_lastKeyTime != null &&
        now.difference(_lastKeyTime!) > maxInterKeyGap) {
      reset();
    }

    if (_lastKeyTime != null &&
        now.difference(_lastKeyTime!) <= maxInterKeyGap) {
      _inScanMode = true;
    }

    _buffer.write(character.length == 1 ? character : character.trim());
    _lastKeyTime = now;

    // Consume only once we treat input as a scanner burst so normal typing
    // shortcuts elsewhere in the app still work.
    return _inScanMode;
  }
}
