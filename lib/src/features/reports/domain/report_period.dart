import 'package:dart_mappable/dart_mappable.dart';
import 'package:intl/intl.dart';

import 'report_aggregations.dart';

part 'report_period.mapper.dart';

/// Chart X-axis grain for trend series (independent of [ReportPeriod] name).
enum TrendGranularity { day, week, month, year }

/// Time period grain for reports (chart bucketing + picker UI).
@MappableEnum()
enum ReportPeriod {
  day,
  weekly,
  monthly,
  yearly,
  allTime;

  /// Display name for the period.
  String get displayName {
    switch (this) {
      case ReportPeriod.day:
        return 'Day';
      case ReportPeriod.weekly:
        return 'Week';
      case ReportPeriod.monthly:
        return 'Month';
      case ReportPeriod.yearly:
        return 'Year';
      case ReportPeriod.allTime:
        return 'All Time';
    }
  }

  /// How trend charts should bucket data for this period.
  TrendGranularity get trendGranularity {
    switch (this) {
      case ReportPeriod.day:
      case ReportPeriod.weekly:
        return TrendGranularity.day;
      case ReportPeriod.monthly:
        return TrendGranularity.week;
      case ReportPeriod.yearly:
        return TrendGranularity.month;
      case ReportPeriod.allTime:
        return TrendGranularity.year;
    }
  }
}

/// Selected report period grain plus an explicit start/end range.
@MappableClass()
class ReportPeriodSelection with ReportPeriodSelectionMappable {
  const ReportPeriodSelection({
    required this.period,
    required this.rangeStart,
    required this.rangeEnd,
  });

  final ReportPeriod period;

  /// Inclusive range start (snapped to grain).
  final DateTime rangeStart;

  /// Inclusive range end (snapped to grain).
  final DateTime rangeEnd;

  TrendGranularity get trendGranularity => period.trendGranularity;

  String get displayName => period.displayName;

  /// Query start (00:00 local of rangeStart day/month/etc.).
  DateTime get startDate => rangeStart;

  /// Query end (capped at now for open periods).
  DateTime get endDate {
    final now = DateTime.now();
    return rangeEnd.isAfter(now) ? now : rangeEnd;
  }

  /// Chart zero-fill end (full snapped end, not capped mid-bucket).
  DateTime get chartEndDate => rangeEnd;

  /// Human-readable range for the toolbar / exports.
  String get displayRangeLabel {
    switch (period) {
      case ReportPeriod.day:
        if (startOfDay(rangeStart) == startOfDay(rangeEnd)) {
          return DateFormat('EEE, MMM d, y').format(rangeStart);
        }
        return '${DateFormat('MMM d').format(rangeStart)} – '
            '${DateFormat('MMM d, y').format(rangeEnd)}';
      case ReportPeriod.weekly:
        return '${DateFormat('MMM d').format(startOfWeekMonday(rangeStart))} – '
            '${DateFormat('MMM d, y').format(endOfWeekSunday(rangeEnd))}';
      case ReportPeriod.monthly:
        if (rangeStart.year == rangeEnd.year &&
            rangeStart.month == rangeEnd.month) {
          return DateFormat('MMMM y').format(rangeStart);
        }
        return '${DateFormat('MMM y').format(rangeStart)} – '
            '${DateFormat('MMM y').format(rangeEnd)}';
      case ReportPeriod.yearly:
        if (rangeStart.year == rangeEnd.year) {
          return rangeStart.year.toString();
        }
        return '${rangeStart.year} – ${rangeEnd.year}';
      case ReportPeriod.allTime:
        return '${rangeStart.year} – ${rangeEnd.year}';
    }
  }

  /// Defaults to the current grain window (today / this week / this month / …).
  factory ReportPeriodSelection.current(ReportPeriod period) {
    final now = DateTime.now();
    switch (period) {
      case ReportPeriod.day:
        final day = startOfDay(now);
        return ReportPeriodSelection(
          period: period,
          rangeStart: day,
          rangeEnd: DateTime(day.year, day.month, day.day, 23, 59, 59, 999),
        );
      case ReportPeriod.weekly:
        return ReportPeriodSelection(
          period: period,
          rangeStart: startOfWeekMonday(now),
          rangeEnd: endOfWeekSunday(now),
        );
      case ReportPeriod.monthly:
        return ReportPeriodSelection(
          period: period,
          rangeStart: startOfMonth(now),
          rangeEnd: endOfMonth(now),
        );
      case ReportPeriod.yearly:
        return ReportPeriodSelection(
          period: period,
          rangeStart: startOfYear(now),
          rangeEnd: endOfYear(now),
        );
      case ReportPeriod.allTime:
        return ReportPeriodSelection(
          period: period,
          rangeStart: DateTime(2019),
          rangeEnd: endOfYear(now),
        );
    }
  }

  /// Change grain and reset to the current window for that grain.
  ReportPeriodSelection withPeriod(ReportPeriod next) =>
      ReportPeriodSelection.current(next);

  /// Set range start, snapped to [period] grain. Ensures start ≤ end.
  ///
  /// Day period always keeps a single calendar day (start and end of that day).
  ReportPeriodSelection withRangeStart(DateTime value) {
    if (period == ReportPeriod.day) {
      return withDay(value);
    }
    final snapped = snapRangeStart(period, value);
    var end = rangeEnd;
    if (end.isBefore(snapped)) {
      end = snapRangeEnd(period, snapped);
    }
    return ReportPeriodSelection(
      period: period,
      rangeStart: snapped,
      rangeEnd: end,
    );
  }

  /// Set range end, snapped to [period] grain. Ensures start ≤ end.
  ///
  /// Day period always keeps a single calendar day (start and end of that day).
  ReportPeriodSelection withRangeEnd(DateTime value) {
    if (period == ReportPeriod.day) {
      return withDay(value);
    }
    final snapped = snapRangeEnd(period, value);
    var start = rangeStart;
    if (snapped.isBefore(start)) {
      start = snapRangeStart(period, snapped);
    }
    return ReportPeriodSelection(
      period: period,
      rangeStart: start,
      rangeEnd: snapped,
    );
  }

  /// Pick a single calendar day (Day period only). Sets start and end to that day.
  ReportPeriodSelection withDay(DateTime value) {
    final start = startOfDay(value);
    return ReportPeriodSelection(
      period: ReportPeriod.day,
      rangeStart: start,
      rangeEnd: DateTime(start.year, start.month, start.day, 23, 59, 59, 999),
    );
  }
}

/// Snap a user-picked date to the start of the grain for [period].
DateTime snapRangeStart(ReportPeriod period, DateTime value) {
  switch (period) {
    case ReportPeriod.day:
      return startOfDay(value);
    case ReportPeriod.weekly:
      return startOfWeekMonday(value);
    case ReportPeriod.monthly:
      return startOfMonth(value);
    case ReportPeriod.yearly:
    case ReportPeriod.allTime:
      return startOfYear(value);
  }
}

/// Snap a user-picked date to the end of the grain for [period].
DateTime snapRangeEnd(ReportPeriod period, DateTime value) {
  switch (period) {
    case ReportPeriod.day:
      final d = startOfDay(value);
      return DateTime(d.year, d.month, d.day, 23, 59, 59, 999);
    case ReportPeriod.weekly:
      return endOfWeekSunday(value);
    case ReportPeriod.monthly:
      return endOfMonth(value);
    case ReportPeriod.yearly:
    case ReportPeriod.allTime:
      return endOfYear(value);
  }
}
