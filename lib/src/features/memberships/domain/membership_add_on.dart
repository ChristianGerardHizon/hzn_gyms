import 'package:dart_mappable/dart_mappable.dart';

part 'membership_add_on.mapper.dart';

/// An add-on option that belongs to a membership plan.
///
/// Represents optional extras a member can purchase alongside a membership
/// (e.g. "Treadmill Access", "Coach/Instructor", "Locker", "Pool Access").
@MappableClass()
class MembershipAddOn with MembershipAddOnMappable {
  const MembershipAddOn({
    required this.id,
    required this.membershipId,
    required this.name,
    required this.price,
    this.description,
    this.isActive = true,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Parent membership plan ID.
  final String membershipId;

  /// Add-on name (e.g. "Pool Access").
  final String name;

  /// Add-on description (optional).
  final String? description;

  /// Price of the add-on in PHP.
  final num price;

  /// Whether this add-on is currently offered.
  final bool isActive;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;
}
