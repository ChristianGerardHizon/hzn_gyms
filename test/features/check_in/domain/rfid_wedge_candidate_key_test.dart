import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kylie_gym/src/features/check_in/domain/rfid_wedge_candidate_key.dart';

void main() {
  group('isRfidWedgeCandidateKey', () {
    test('accepts Enter and printable characters', () {
      expect(
        isRfidWedgeCandidateKey(
          logicalKey: LogicalKeyboardKey.enter,
          character: null,
        ),
        isTrue,
      );
      expect(
        isRfidWedgeCandidateKey(
          logicalKey: LogicalKeyboardKey.digit1,
          character: '1',
        ),
        isTrue,
      );
    });

    test('rejects modifiers and navigation keys', () {
      expect(
        isRfidWedgeCandidateKey(
          logicalKey: LogicalKeyboardKey.shiftLeft,
          character: null,
        ),
        isFalse,
      );
      expect(
        isRfidWedgeCandidateKey(
          logicalKey: LogicalKeyboardKey.arrowDown,
          character: null,
        ),
        isFalse,
      );
      expect(
        isRfidWedgeCandidateKey(
          logicalKey: LogicalKeyboardKey.space,
          character: ' ',
        ),
        isFalse,
      );
    });
  });
}
