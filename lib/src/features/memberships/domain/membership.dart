import 'package:dart_mappable/dart_mappable.dart';

part 'membership.mapper.dart';

/// Membership plan template.
///
/// Represents a membership plan that can be purchased by members
/// (e.g. "Monthly", "Annual", "Student").
@MappableClass()
class Membership with MembershipMappable {
  const Membership({
    required this.id,
    required this.name,
    required this.durationDays,
    required this.price,
    required this.branchId,
    this.description,
    this.isActive = true,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Plan name (e.g. "Monthly", "Annual").
  final String name;

  /// Plan description (optional).
  final String? description;

  /// Duration of the membership in days.
  final int durationDays;

  /// Price in PHP.
  final num price;

  /// Branch this plan belongs to.
  final String branchId;

  /// Whether this plan is currently offered.
  final bool isActive;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// Display string for duration.
  String get durationDisplay {
    if (durationDays == 1) return '1 day';
    if (durationDays == 7) return '1 week';
    if (durationDays == 30) return '1 month';
    if (durationDays == 90) return '3 months';
    if (durationDays == 180) return '6 months';
    if (durationDays == 365) return '1 year';
    return '$durationDays days';
  }
}
