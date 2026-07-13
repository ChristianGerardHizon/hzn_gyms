import 'package:flutter_test/flutter_test.dart';
import 'package:ebe_gym/src/core/utils/date_utils.dart';

void main() {
  group('PocketBaseDateExtensions', () {
    test('toPocketBaseUtc formats as Y-m-d H:i:s.uZ', () {
      final utc = DateTime.utc(2024, 1, 23, 5, 6, 7, 8);
      expect(utc.toPocketBaseUtc(), '2024-01-23 05:06:07.008Z');
    });

    test('toUtcIso8601 returns UTC ISO string', () {
      final local = DateTime(2024, 6, 15, 12);
      expect(local.toUtcIso8601(), local.toUtc().toIso8601String());
    });
  });

  group('parseToLocal', () {
    test('returns null for null or empty', () {
      expect(parseToLocal(null), isNull);
      expect(parseToLocal(''), isNull);
    });

    test('parses UTC string to local', () {
      final parsed = parseToLocal('2024-01-23T00:00:00.000Z');
      expect(parsed, isNotNull);
      expect(parsed!.isUtc, isFalse);
    });

    test('parseToLocalOrDefault falls back', () {
      final fallback = DateTime(2020);
      expect(parseToLocalOrDefault(null, fallback), fallback);
    });
  });

  group('toLocalDateOnly', () {
    test('strips time to midnight local', () {
      final dt = DateTime(2024, 3, 10, 15, 45);
      expect(toLocalDateOnly(dt), DateTime(2024, 3, 10));
    });
  });

  group('computeMembershipStartDate', () {
    // isBeforeToday uses DateTime.now(); keep fixtures relative to today.
    final now = DateTime.now();

    test('returns now when latestActiveEndDate is null', () {
      expect(
        computeMembershipStartDate(now: now),
        now,
      );
    });

    test('returns now when latest end date is before today', () {
      final expired = DateTime.now().subtract(const Duration(days: 5));
      expect(
        computeMembershipStartDate(latestActiveEndDate: expired, now: now),
        now,
      );
    });

    test('stacks to day after inclusive end date when still active', () {
      final activeEnd = DateTime.now().add(const Duration(days: 5));
      final expected = toLocalDateOnly(activeEnd).add(const Duration(days: 1));
      expect(
        computeMembershipStartDate(latestActiveEndDate: activeEnd, now: now),
        expected,
      );
    });

    test('stacks when end date is today (inclusive)', () {
      final endsToday = DateTime.now();
      final expected = toLocalDateOnly(endsToday).add(const Duration(days: 1));
      expect(
        computeMembershipStartDate(latestActiveEndDate: endsToday, now: now),
        expected,
      );
    });
  });

  group('computeMembershipEndDate', () {
    test('adds durationDays to start', () {
      final start = DateTime(2024, 1, 1);
      expect(
        computeMembershipEndDate(startDate: start, durationDays: 30),
        DateTime(2024, 1, 31),
      );
    });
  });
}
