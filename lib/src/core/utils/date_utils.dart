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

/// Whether [date]'s local calendar day is strictly before today.
bool isBeforeToday(DateTime date) => calendarDaysUntil(date) < 0;
