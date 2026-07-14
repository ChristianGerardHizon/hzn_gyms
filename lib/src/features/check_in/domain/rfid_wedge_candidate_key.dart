import 'package:flutter/services.dart';

/// Whether a key-down is a plausible keyboard-wedge RFID character or Enter.
///
/// Used to skip modifiers/navigation keys before doing any decoder work.
bool isRfidWedgeCandidateKey({
  required LogicalKeyboardKey logicalKey,
  required String? character,
}) {
  if (logicalKey == LogicalKeyboardKey.enter ||
      logicalKey == LogicalKeyboardKey.numpadEnter) {
    return true;
  }
  if (character == null || character.isEmpty) return false;
  if (character == '\n' || character == '\r') return false;
  if (character.codeUnitAt(0) < 32) return false;
  return character.trim().isNotEmpty;
}
