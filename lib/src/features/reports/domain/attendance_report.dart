import 'package:dart_mappable/dart_mappable.dart';

import 'period_bucket.dart';

part 'attendance_report.mapper.dart';

/// Aggregated check-in / attendance data for a time period.
@MappableClass()
class AttendanceReport with AttendanceReportMappable {
  const AttendanceReport({
    required this.totalCheckIns,
    required this.uniqueMembers,
    required this.checkInsTrend,
    required this.checkInsByMethod,
    required this.checkInsByHour,
    this.withoutActiveMembershipCount = 0,
  });

  final int totalCheckIns;
  final int uniqueMembers;

  /// Check-ins trend (day / week / month / year buckets).
  final List<PeriodBucket> checkInsTrend;

  final Map<String, num> checkInsByMethod;

  /// Peak hours — populated for Day period only; empty otherwise.
  final Map<String, num> checkInsByHour;

  final int withoutActiveMembershipCount;

  static const empty = AttendanceReport(
    totalCheckIns: 0,
    uniqueMembers: 0,
    checkInsTrend: [],
    checkInsByMethod: {},
    checkInsByHour: {},
  );
}
