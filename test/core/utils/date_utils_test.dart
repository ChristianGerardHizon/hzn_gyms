import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/core/utils/date_utils.dart';

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

  group('calendarMonthsUntil', () {
    test('counts complete months with day-of-month awareness', () {
      final now = DateTime(2026, 1, 15);
      expect(
        calendarMonthsUntil(DateTime(2026, 2, 14), now: now),
        0,
      );
      expect(
        calendarMonthsUntil(DateTime(2026, 2, 15), now: now),
        1,
      );
      expect(
        calendarMonthsUntil(DateTime(2026, 10, 9), now: now),
        8,
      );
    });

    test('returns negative when date is before today', () {
      final now = DateTime(2026, 3, 15);
      expect(
        calendarMonthsUntil(DateTime(2026, 1, 15), now: now),
        -2,
      );
    });
  });

  group('computeMembershipStartDate', () {
    // isBeforeToday uses DateTime.now(); keep fixtures relative to today.
    final now = DateTime.now();

    test('returns now when latestActiveEndDate is null', () {
      expect(computeMembershipStartDate(now: now), now);
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

  group('MembershipDurationUnit', () {
    test('fromName parses each PocketBase select value', () {
      expect(MembershipDurationUnit.fromName('days'), MembershipDurationUnit.days);
      expect(
        MembershipDurationUnit.fromName('weeks'),
        MembershipDurationUnit.weeks,
      );
      expect(
        MembershipDurationUnit.fromName('months'),
        MembershipDurationUnit.months,
      );
      expect(
        MembershipDurationUnit.fromName('years'),
        MembershipDurationUnit.years,
      );
    });

    test('fromName defaults to days for null or unknown input', () {
      expect(MembershipDurationUnit.fromName(null), MembershipDurationUnit.days);
      expect(
        MembershipDurationUnit.fromName(''),
        MembershipDurationUnit.days,
      );
      expect(
        MembershipDurationUnit.fromName('fortnights'),
        MembershipDurationUnit.days,
      );
    });

    test('label pluralizes only when value != 1', () {
      expect(MembershipDurationUnit.days.label(1), '1 day');
      expect(MembershipDurationUnit.days.label(5), '5 days');
      expect(MembershipDurationUnit.weeks.label(1), '1 week');
      expect(MembershipDurationUnit.weeks.label(2), '2 weeks');
      expect(MembershipDurationUnit.months.label(1), '1 month');
      expect(MembershipDurationUnit.months.label(3), '3 months');
      expect(MembershipDurationUnit.years.label(1), '1 year');
      expect(MembershipDurationUnit.years.label(2), '2 years');
    });
  });

  group('addCalendarDuration', () {
    test('days adds exact day count', () {
      final start = DateTime(2024, 1, 1);
      expect(
        addCalendarDuration(
          start,
          unit: MembershipDurationUnit.days,
          value: 30,
        ),
        DateTime(2024, 1, 31),
      );
    });

    test('weeks adds exact 7-day multiples', () {
      final start = DateTime(2024, 1, 1);
      expect(
        addCalendarDuration(
          start,
          unit: MembershipDurationUnit.weeks,
          value: 2,
        ),
        DateTime(2024, 1, 15),
      );
    });

    test('months lands on the same calendar day next month', () {
      final start = DateTime(2026, 8, 1);
      expect(
        addCalendarDuration(
          start,
          unit: MembershipDurationUnit.months,
          value: 1,
        ),
        DateTime(2026, 9, 1),
      );
    });

    test('months clamps to the last day when target month is shorter', () {
      final start = DateTime(2024, 1, 31);
      expect(
        addCalendarDuration(
          start,
          unit: MembershipDurationUnit.months,
          value: 1,
        ),
        DateTime(2024, 2, 29), // 2024 is a leap year
      );
    });

    test('months rolls over the year boundary', () {
      final start = DateTime(2026, 11, 15);
      expect(
        addCalendarDuration(
          start,
          unit: MembershipDurationUnit.months,
          value: 3,
        ),
        DateTime(2027, 2, 15),
      );
    });

    test('years adds calendar years, clamping Feb 29 on non-leap years', () {
      final start = DateTime(2024, 2, 29);
      expect(
        addCalendarDuration(
          start,
          unit: MembershipDurationUnit.years,
          value: 1,
        ),
        DateTime(2025, 2, 28),
      );
    });
  });

  group('computeMembershipEndDate', () {
    test('adds calendar duration to start', () {
      final start = DateTime(2026, 8, 1);
      expect(
        computeMembershipEndDate(
          startDate: start,
          durationValue: 1,
          durationUnit: MembershipDurationUnit.months,
        ),
        DateTime(2026, 9, 1),
      );
    });

    test('adds bonusDays as a flat offset on top of the calendar duration', () {
      final start = DateTime(2026, 8, 1);
      expect(
        computeMembershipEndDate(
          startDate: start,
          durationValue: 1,
          durationUnit: MembershipDurationUnit.months,
          bonusDays: 3,
        ),
        DateTime(2026, 9, 4),
      );
    });
  });
}
