/// Utility extensions and functions for DateTime handling with PocketBase.
///
/// PocketBase stores all dates in UTC. This module provides consistent
/// conversion between local time (used in the UI) and UTC (stored in DB).

/// Extension methods for DateTime to handle UTC/local conversions.
extension PocketBaseDateExtensions on DateTime {
  /// Converts to UTC and returns ISO8601 string for PocketBase storage.
  ///
  /// Use this when sending dates to the server in create/update operations.
  /// Example: `member.dateOfBirth.toUtcIso8601()`
  String toUtcIso8601() => toUtc().toIso8601String();

  /// Converts to UTC and returns string in PocketBase filter format: 'Y-m-d H:i:s.uZ'
  ///
  /// PocketBase server requires this specific format for date filters.
  /// Example output: '2024-01-23 00:00:00.000Z'
  String toPocketBaseUtc() {
    final utc = toUtc();
    return '${utc.year.toString().padLeft(4, '0')}-'
        '${utc.month.toString().padLeft(2, '0')}-'
        '${utc.day.toString().padLeft(2, '0')} '
        '${utc.hour.toString().padLeft(2, '0')}:'
        '${utc.minute.toString().padLeft(2, '0')}:'
        '${utc.second.toString().padLeft(2, '0')}.'
        '${utc.millisecond.toString().padLeft(3, '0')}Z';
  }
}

/// Extension methods for nullable DateTime.
extension PocketBaseDateExtensionsNullable on DateTime? {
  /// Converts to UTC ISO8601 string, or returns null if DateTime is null.
  ///
  /// Safe to use with optional date fields.
  /// Example: `product.expiration.toUtcIso8601OrNull()`
  String? toUtcIso8601OrNull() => this?.toUtc().toIso8601String();

  /// Converts to PocketBase UTC format, or returns null if DateTime is null.
  ///
  /// Safe to use with optional date fields in filter queries.
  /// Example: `checkIn.checkInTime.toPocketBaseUtcOrNull()`
  String? toPocketBaseUtcOrNull() => this?.toPocketBaseUtc();
}

/// Parses a date string from PocketBase and converts to local time.
///
/// PocketBase returns dates in UTC format. This function parses the string
/// and converts it to the device's local timezone for display.
///
/// Returns null if the input is null or parsing fails.
///
/// Example:
/// ```dart
/// final localDate = parseToLocal(json['dateOfBirth'] as String?);
/// ```
DateTime? parseToLocal(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return null;
  return DateTime.tryParse(dateStr)?.toLocal();
}

/// Parses a date string and converts to local, with a fallback default value.
///
/// Use when a non-null DateTime is required.
///
/// Example:
/// ```dart
/// final date = parseToLocalOrDefault(json['checkInTime'], DateTime.now());
/// ```
DateTime parseToLocalOrDefault(String? dateStr, DateTime defaultValue) {
  return parseToLocal(dateStr) ?? defaultValue;
}

/// Normalizes a [DateTime] to midnight local time (calendar date only).
DateTime toLocalDateOnly(DateTime dateTime) =>
    DateTime(dateTime.year, dateTime.month, dateTime.day);

/// Whole calendar days from today (local) to [date].
///
/// Returns `0` on the expiration day, positive before it, negative after.
int calendarDaysUntil(DateTime date) {
  final today = toLocalDateOnly(DateTime.now());
  final target = toLocalDateOnly(date);
  return target.difference(today).inDays;
}

/// Whole calendar months from today (local) to [date].
///
/// Counts complete months remaining (day-of-month aware): e.g. Jan 15 → Feb 14
/// is `0`, Jan 15 → Feb 15 is `1`. Negative when [date] is before today.
int calendarMonthsUntil(DateTime date, {DateTime? now}) {
  final today = toLocalDateOnly(now ?? DateTime.now());
  final target = toLocalDateOnly(date);
  var months =
      (target.year - today.year) * 12 + (target.month - today.month);
  if (target.day < today.day) months -= 1;
  return months;
}

/// Whether [date]'s local calendar day is strictly before today.
bool isBeforeToday(DateTime date) => calendarDaysUntil(date) < 0;

/// Start date for a new membership period, stacking after an active one.
///
/// Membership end dates are inclusive. If [latestActiveEndDate] is still
/// active (not before today), the new period starts the next calendar day.
/// Otherwise returns [now] (defaults to [DateTime.now]).
DateTime computeMembershipStartDate({
  DateTime? latestActiveEndDate,
  DateTime? now,
}) {
  final current = now ?? DateTime.now();
  if (latestActiveEndDate == null || isBeforeToday(latestActiveEndDate)) {
    return current;
  }
  return toLocalDateOnly(latestActiveEndDate).add(const Duration(days: 1));
}

/// Unit for a membership plan's duration (day/week/month/year).
enum MembershipDurationUnit {
  days,
  weeks,
  months,
  years;

  /// Parses a PocketBase select value; defaults to [days] for unknown input.
  static MembershipDurationUnit fromName(String? name) {
    return MembershipDurationUnit.values.firstWhere(
      (unit) => unit.name == name,
      orElse: () => MembershipDurationUnit.days,
    );
  }

  /// Singular/plural label for [value], e.g. `"1 month"` / `"3 months"`.
  String label(int value) {
    final unitName = switch (this) {
      MembershipDurationUnit.days => 'day',
      MembershipDurationUnit.weeks => 'week',
      MembershipDurationUnit.months => 'month',
      MembershipDurationUnit.years => 'year',
    };
    return value == 1 ? '1 $unitName' : '$value ${unitName}s';
  }
}

/// Adds [value] calendar [unit]s to [date].
///
/// Days and weeks are exact day-count additions. Months and years use
/// calendar arithmetic instead of a fixed day count — e.g. starting Aug 1
/// and adding 1 month lands on Sep 1 regardless of how many days are in
/// August. When the target month is shorter than the start day, the day is
/// clamped to the last day of that month (e.g. Jan 31 + 1 month = Feb 28).
DateTime addCalendarDuration(
  DateTime date, {
  required MembershipDurationUnit unit,
  required int value,
}) {
  switch (unit) {
    case MembershipDurationUnit.days:
      return date.add(Duration(days: value));
    case MembershipDurationUnit.weeks:
      return date.add(Duration(days: value * 7));
    case MembershipDurationUnit.months:
      return _addMonths(date, value);
    case MembershipDurationUnit.years:
      return _addMonths(date, value * 12);
  }
}

DateTime _addMonths(DateTime date, int months) {
  final totalMonths = date.year * 12 + (date.month - 1) + months;
  final year = totalMonths ~/ 12;
  final month = totalMonths % 12 + 1;
  final daysInTargetMonth = DateTime(year, month + 1, 0).day;
  final day = date.day > daysInTargetMonth ? daysInTargetMonth : date.day;
  return DateTime(
    year,
    month,
    day,
    date.hour,
    date.minute,
    date.second,
    date.millisecond,
    date.microsecond,
  );
}

/// End date for a membership period starting at [startDate].
///
/// [durationValue]/[durationUnit] use calendar-correct arithmetic (see
/// [addCalendarDuration]). [bonusDays] (e.g. from add-on promos) is added on
/// top as a flat day offset.
DateTime computeMembershipEndDate({
  required DateTime startDate,
  required int durationValue,
  required MembershipDurationUnit durationUnit,
  int bonusDays = 0,
}) {
  final base = addCalendarDuration(
    startDate,
    unit: durationUnit,
    value: durationValue,
  );
  return bonusDays == 0 ? base : base.add(Duration(days: bonusDays));
}
