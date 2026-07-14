import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ebe_gym/src/features/check_in/domain/rfid_keyboard_wedge_decoder.dart';

void main() {
  group('RfidKeyboardWedgeDecoder', () {
    late RfidKeyboardWedgeDecoder decoder;
    late List<String> scans;

    setUp(() {
      decoder = RfidKeyboardWedgeDecoder();
      scans = [];
    });

    bool feed(
      LogicalKeyboardKey key, {
      String? character,
      required DateTime now,
    }) {
      return decoder.handleKeyDown(
        logicalKey: key,
        character: character,
        now: now,
        onScan: scans.add,
      );
    }

    LogicalKeyboardKey digitKey(String digit) {
      return switch (digit) {
        '0' => LogicalKeyboardKey.digit0,
        '1' => LogicalKeyboardKey.digit1,
        '2' => LogicalKeyboardKey.digit2,
        '3' => LogicalKeyboardKey.digit3,
        '4' => LogicalKeyboardKey.digit4,
        '5' => LogicalKeyboardKey.digit5,
        '6' => LogicalKeyboardKey.digit6,
        '7' => LogicalKeyboardKey.digit7,
        '8' => LogicalKeyboardKey.digit8,
        '9' => LogicalKeyboardKey.digit9,
        _ => LogicalKeyboardKey.keyA,
      };
    }

    void feedBurst(String cardId, {required DateTime start}) {
      var t = start;
      for (final ch in cardId.split('')) {
        feed(digitKey(ch), character: ch, now: t);
        t = t.add(const Duration(milliseconds: 20));
      }
      feed(LogicalKeyboardKey.enter, now: t);
    }

    test('emits card id on rapid burst ending with Enter', () {
      final start = DateTime(2026, 1, 1, 12);
      feedBurst('12345678', start: start);

      expect(scans, ['12345678']);
    });

    test('does not emit when buffer is shorter than min length', () {
      final start = DateTime(2026, 1, 1, 12);
      feedBurst('12', start: start);

      expect(scans, isEmpty);
    });

    test('does not emit single slow key then Enter (human typing)', () {
      final start = DateTime(2026, 1, 1, 12);
      expect(
        feed(LogicalKeyboardKey.digit1, character: '1', now: start),
        isFalse,
      );
      expect(
        feed(
          LogicalKeyboardKey.enter,
          now: start.add(const Duration(milliseconds: 200)),
        ),
        isFalse,
      );
      expect(scans, isEmpty);
    });

    test('resets buffer when gap exceeds maxInterKeyGap', () {
      final start = DateTime(2026, 1, 1, 12);
      feed(LogicalKeyboardKey.digit1, character: '1', now: start);
      feed(
        LogicalKeyboardKey.digit2,
        character: '2',
        now: start.add(const Duration(milliseconds: 20)),
      );
      // Gap too large — previous buffer discarded, new sequence starts.
      feed(
        LogicalKeyboardKey.digit9,
        character: '9',
        now: start.add(const Duration(milliseconds: 200)),
      );
      feed(
        LogicalKeyboardKey.digit8,
        character: '8',
        now: start.add(const Duration(milliseconds: 220)),
      );
      feed(
        LogicalKeyboardKey.digit7,
        character: '7',
        now: start.add(const Duration(milliseconds: 240)),
      );
      feed(
        LogicalKeyboardKey.digit6,
        character: '6',
        now: start.add(const Duration(milliseconds: 260)),
      );
      expect(
        feed(
          LogicalKeyboardKey.enter,
          now: start.add(const Duration(milliseconds: 280)),
        ),
        isTrue,
      );
      expect(scans, ['9876']);
    });

    test('consumes keys only after scan-mode burst is detected', () {
      final start = DateTime(2026, 1, 1, 12);
      expect(
        feed(LogicalKeyboardKey.digit1, character: '1', now: start),
        isFalse,
      );
      expect(
        feed(
          LogicalKeyboardKey.digit2,
          character: '2',
          now: start.add(const Duration(milliseconds: 20)),
        ),
        isTrue,
      );
      expect(decoder.inScanMode, isTrue);
    });

    test('accepts numpad Enter as terminator', () {
      final start = DateTime(2026, 1, 1, 12);
      var t = start;
      for (final ch in 'ABCD'.split('')) {
        feed(LogicalKeyboardKey.keyA, character: ch, now: t);
        t = t.add(const Duration(milliseconds: 15));
      }
      expect(feed(LogicalKeyboardKey.numpadEnter, now: t), isTrue);
      expect(scans, ['ABCD']);
    });

    test('ignores whitespace-only characters', () {
      final start = DateTime(2026, 1, 1, 12);
      expect(
        feed(LogicalKeyboardKey.space, character: ' ', now: start),
        isFalse,
      );
      expect(scans, isEmpty);
    });

    test('reset clears in-progress scan', () {
      final start = DateTime(2026, 1, 1, 12);
      feed(LogicalKeyboardKey.digit1, character: '1', now: start);
      feed(
        LogicalKeyboardKey.digit2,
        character: '2',
        now: start.add(const Duration(milliseconds: 20)),
      );
      decoder.reset();
      expect(decoder.inScanMode, isFalse);
      expect(
        feed(
          LogicalKeyboardKey.enter,
          now: start.add(const Duration(milliseconds: 40)),
        ),
        isFalse,
      );
      expect(scans, isEmpty);
    });

    test('rapid consecutive scans do not merge', () {
      final start = DateTime(2026, 1, 1, 12);
      feedBurst('1111', start: start);
      feedBurst(
        '2222',
        start: start.add(const Duration(milliseconds: 500)),
      );

      expect(scans, ['1111', '2222']);
    });
  });
}
