import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hzn_gyms/src/features/check_in/domain/rfid_keyboard_wedge_simulator.dart';

void main() {
  group('mapCharacterToRfidWedgeKey', () {
    test('maps digits', () {
      final stroke = mapCharacterToRfidWedgeKey('7');
      expect(stroke?.logicalKey, LogicalKeyboardKey.digit7);
      expect(stroke?.character, '7');
    });

    test('maps letters preserving case in character', () {
      final upper = mapCharacterToRfidWedgeKey('A');
      expect(upper?.logicalKey, LogicalKeyboardKey.keyA);
      expect(upper?.character, 'A');

      final lower = mapCharacterToRfidWedgeKey('b');
      expect(lower?.logicalKey, LogicalKeyboardKey.keyB);
      expect(lower?.character, 'b');
    });

    test('maps common punctuation', () {
      expect(mapCharacterToRfidWedgeKey('-')?.logicalKey, LogicalKeyboardKey.minus);
      expect(
        mapCharacterToRfidWedgeKey('_')?.logicalKey,
        LogicalKeyboardKey.underscore,
      );
    });

    test('returns null for unsupported characters', () {
      expect(mapCharacterToRfidWedgeKey(' '), isNull);
      expect(mapCharacterToRfidWedgeKey('あ'), isNull);
      expect(mapCharacterToRfidWedgeKey('ab'), isNull);
    });
  });

  group('buildRfidWedgeKeySequence', () {
    test('appends Enter after card characters', () {
      final sequence = buildRfidWedgeKeySequence('A1');
      expect(sequence.length, 3);
      expect(sequence[0].character, 'A');
      expect(sequence[1].character, '1');
      expect(sequence[2].logicalKey, LogicalKeyboardKey.enter);
      expect(sequence[2].character, isNull);
    });

    test('skips unsupported characters but still ends with Enter', () {
      final sequence = buildRfidWedgeKeySequence('12 34');
      expect(
        sequence.map((s) => s.character).whereType<String>().toList(),
        ['1', '2', '3', '4'],
      );
      expect(sequence.last.logicalKey, LogicalKeyboardKey.enter);
    });

    test('empty card still yields Enter only', () {
      final sequence = buildRfidWedgeKeySequence('');
      expect(sequence.length, 1);
      expect(sequence.single.logicalKey, LogicalKeyboardKey.enter);
    });
  });
}
