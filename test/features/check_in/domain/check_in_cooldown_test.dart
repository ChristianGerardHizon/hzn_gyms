import 'package:flutter_test/flutter_test.dart';
import 'package:kylie_gym/src/features/check_in/domain/check_in_cooldown.dart';

void main() {
  group('checkInCooldownRemaining', () {
    final now = DateTime(2026, 8, 10, 12, 0, 30);

    test('returns null when cooldown has elapsed', () {
      final last = now.subtract(const Duration(seconds: 30));
      expect(checkInCooldownRemaining(last, now: now), isNull);
    });

    test('returns remaining when within cooldown', () {
      final last = now.subtract(const Duration(seconds: 10));
      expect(
        checkInCooldownRemaining(last, now: now),
        const Duration(seconds: 20),
      );
    });

    test('clamps future last check-in to full cooldown', () {
      final last = now.add(const Duration(seconds: 5));
      expect(checkInCooldownRemaining(last, now: now), kCheckInCooldown);
    });
  });

  group('checkInCooldownMessage', () {
    test('uses singular second', () {
      expect(
        checkInCooldownMessage(const Duration(seconds: 1)),
        contains('1 second'),
      );
    });

    test('uses plural seconds', () {
      expect(
        checkInCooldownMessage(const Duration(seconds: 12)),
        contains('12 seconds'),
      );
    });
  });
}
