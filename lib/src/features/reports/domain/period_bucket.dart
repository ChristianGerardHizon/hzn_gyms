import 'package:dart_mappable/dart_mappable.dart';

part 'period_bucket.mapper.dart';

/// A single point on a report trend chart (day / week / month / year).
@MappableClass()
class PeriodBucket with PeriodBucketMappable {
  const PeriodBucket({
    required this.periodStart,
    required this.value,
    required this.label,
  });

  /// Start of the bucket (day, Mon week-start, month-start, or year-start).
  final DateTime periodStart;

  /// Aggregated metric for this bucket.
  final num value;

  /// Precomputed axis label (e.g. `Mon`, `Jul 7`, `Jan`, `2024`).
  final String label;
}
