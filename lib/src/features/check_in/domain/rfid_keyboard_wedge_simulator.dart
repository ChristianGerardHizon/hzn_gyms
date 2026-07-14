import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// One synthetic key in a keyboard-wedge RFID burst (key down only).
class RfidWedgeKeyStroke {
  const RfidWedgeKeyStroke({
    required this.logicalKey,
    required this.physicalKey,
    this.character,
  });

  final LogicalKeyboardKey logicalKey;
  final PhysicalKeyboardKey physicalKey;
  final String? character;
}

/// Builds the key sequence a USB HID RFID reader would type: [cardId] + Enter.
///
/// Unsupported characters are skipped. Empty [cardId] yields only Enter.
List<RfidWedgeKeyStroke> buildRfidWedgeKeySequence(String cardId) {
  final strokes = <RfidWedgeKeyStroke>[];
  for (final rune in cardId.runes) {
    final ch = String.fromCharCode(rune);
    final mapped = mapCharacterToRfidWedgeKey(ch);
    if (mapped != null) {
      strokes.add(mapped);
    }
  }
  strokes.add(
    const RfidWedgeKeyStroke(
      logicalKey: LogicalKeyboardKey.enter,
      physicalKey: PhysicalKeyboardKey.enter,
    ),
  );
  return strokes;
}

/// Maps a single printable character to a wedge key stroke.
RfidWedgeKeyStroke? mapCharacterToRfidWedgeKey(String character) {
  if (character.length != 1) return null;
  final code = character.codeUnitAt(0);

  if (code >= 0x30 && code <= 0x39) {
    final digit = code - 0x30;
    return RfidWedgeKeyStroke(
      logicalKey: _digitLogicalKeys[digit],
      physicalKey: _digitPhysicalKeys[digit],
      character: character,
    );
  }

  final lower = character.toLowerCase();
  final lowerCode = lower.codeUnitAt(0);
  if (lowerCode >= 0x61 && lowerCode <= 0x7a) {
    final index = lowerCode - 0x61;
    return RfidWedgeKeyStroke(
      logicalKey: _letterLogicalKeys[index],
      physicalKey: _letterPhysicalKeys[index],
      character: character,
    );
  }

  // Common barcode/RFID punctuation some readers emit.
  return switch (character) {
    '-' => const RfidWedgeKeyStroke(
      logicalKey: LogicalKeyboardKey.minus,
      physicalKey: PhysicalKeyboardKey.minus,
      character: '-',
    ),
    '_' => const RfidWedgeKeyStroke(
      logicalKey: LogicalKeyboardKey.underscore,
      // Underscore is typically Shift+Minus on US keyboards.
      physicalKey: PhysicalKeyboardKey.minus,
      character: '_',
    ),
    '.' => const RfidWedgeKeyStroke(
      logicalKey: LogicalKeyboardKey.period,
      physicalKey: PhysicalKeyboardKey.period,
      character: '.',
    ),
    ':' => const RfidWedgeKeyStroke(
      logicalKey: LogicalKeyboardKey.colon,
      // Colon is typically Shift+Semicolon on US keyboards.
      physicalKey: PhysicalKeyboardKey.semicolon,
      character: ':',
    ),
    _ => null,
  };
}

/// Default inter-key delay matching a fast USB keyboard-wedge reader.
const kRfidWedgeInterKeyDelay = Duration(milliseconds: 20);

/// Injects synthetic key-down events into [HardwareKeyboard] so
/// [CheckInRfidListener] processes them like a real RFID scan (while
/// Check-In is open and no text field is focused).
Future<void> simulateRfidKeyboardWedgeScan(
  String cardId, {
  Duration interKeyDelay = kRfidWedgeInterKeyDelay,
  HardwareKeyboard? keyboard,
}) async {
  final hw = keyboard ?? HardwareKeyboard.instance;
  FocusManager.instance.primaryFocus?.unfocus();
  // Let focus settle before keys arrive (listener checks focused EditableText).
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(const Duration(milliseconds: 50));

  var elapsed = Duration.zero;
  for (final stroke in buildRfidWedgeKeySequence(cardId)) {
    hw.handleKeyEvent(
      KeyDownEvent(
        physicalKey: stroke.physicalKey,
        logicalKey: stroke.logicalKey,
        character: stroke.character,
        timeStamp: elapsed,
      ),
    );
    elapsed += interKeyDelay;
    await Future<void>.delayed(interKeyDelay);
  }
}

const _digitLogicalKeys = <LogicalKeyboardKey>[
  LogicalKeyboardKey.digit0,
  LogicalKeyboardKey.digit1,
  LogicalKeyboardKey.digit2,
  LogicalKeyboardKey.digit3,
  LogicalKeyboardKey.digit4,
  LogicalKeyboardKey.digit5,
  LogicalKeyboardKey.digit6,
  LogicalKeyboardKey.digit7,
  LogicalKeyboardKey.digit8,
  LogicalKeyboardKey.digit9,
];

const _digitPhysicalKeys = <PhysicalKeyboardKey>[
  PhysicalKeyboardKey.digit0,
  PhysicalKeyboardKey.digit1,
  PhysicalKeyboardKey.digit2,
  PhysicalKeyboardKey.digit3,
  PhysicalKeyboardKey.digit4,
  PhysicalKeyboardKey.digit5,
  PhysicalKeyboardKey.digit6,
  PhysicalKeyboardKey.digit7,
  PhysicalKeyboardKey.digit8,
  PhysicalKeyboardKey.digit9,
];

const _letterLogicalKeys = <LogicalKeyboardKey>[
  LogicalKeyboardKey.keyA,
  LogicalKeyboardKey.keyB,
  LogicalKeyboardKey.keyC,
  LogicalKeyboardKey.keyD,
  LogicalKeyboardKey.keyE,
  LogicalKeyboardKey.keyF,
  LogicalKeyboardKey.keyG,
  LogicalKeyboardKey.keyH,
  LogicalKeyboardKey.keyI,
  LogicalKeyboardKey.keyJ,
  LogicalKeyboardKey.keyK,
  LogicalKeyboardKey.keyL,
  LogicalKeyboardKey.keyM,
  LogicalKeyboardKey.keyN,
  LogicalKeyboardKey.keyO,
  LogicalKeyboardKey.keyP,
  LogicalKeyboardKey.keyQ,
  LogicalKeyboardKey.keyR,
  LogicalKeyboardKey.keyS,
  LogicalKeyboardKey.keyT,
  LogicalKeyboardKey.keyU,
  LogicalKeyboardKey.keyV,
  LogicalKeyboardKey.keyW,
  LogicalKeyboardKey.keyX,
  LogicalKeyboardKey.keyY,
  LogicalKeyboardKey.keyZ,
];

const _letterPhysicalKeys = <PhysicalKeyboardKey>[
  PhysicalKeyboardKey.keyA,
  PhysicalKeyboardKey.keyB,
  PhysicalKeyboardKey.keyC,
  PhysicalKeyboardKey.keyD,
  PhysicalKeyboardKey.keyE,
  PhysicalKeyboardKey.keyF,
  PhysicalKeyboardKey.keyG,
  PhysicalKeyboardKey.keyH,
  PhysicalKeyboardKey.keyI,
  PhysicalKeyboardKey.keyJ,
  PhysicalKeyboardKey.keyK,
  PhysicalKeyboardKey.keyL,
  PhysicalKeyboardKey.keyM,
  PhysicalKeyboardKey.keyN,
  PhysicalKeyboardKey.keyO,
  PhysicalKeyboardKey.keyP,
  PhysicalKeyboardKey.keyQ,
  PhysicalKeyboardKey.keyR,
  PhysicalKeyboardKey.keyS,
  PhysicalKeyboardKey.keyT,
  PhysicalKeyboardKey.keyU,
  PhysicalKeyboardKey.keyV,
  PhysicalKeyboardKey.keyW,
  PhysicalKeyboardKey.keyX,
  PhysicalKeyboardKey.keyY,
  PhysicalKeyboardKey.keyZ,
];
