import 'package:dart_mappable/dart_mappable.dart';

part 'branch.mapper.dart';

/// Branch domain model.
///
/// Represents a physical branch/location of the business.
@MappableClass()
class Branch with BranchMappable {
  const Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.contactNumber,
    this.operatingHours,
    this.cutOffTime,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Branch name (short internal identifier, e.g., "Main Branch").
  final String name;

  /// Branch address.
  final String address;

  /// Branch contact number.
  final String contactNumber;

  /// Operating hours (e.g., "Mon-Sat 8:00 AM - 5:00 PM").
  final String? operatingHours;

  /// Cut-off time for daily operations (e.g., "10:00 PM").
  final String? cutOffTime;

  /// Soft delete flag.
  final bool isDeleted;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;
}
