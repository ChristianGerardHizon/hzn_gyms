import 'package:dart_mappable/dart_mappable.dart';

part 'member_membership_add_on.mapper.dart';

/// A record of an add-on selected by a member when purchasing a membership.
///
/// Stores a snapshot of the add-on name and price at the time of purchase.
@MappableClass()
class MemberMembershipAddOn with MemberMembershipAddOnMappable {
  const MemberMembershipAddOn({
    required this.id,
    required this.memberMembershipId,
    required this.membershipAddOnId,
    required this.addOnName,
    required this.price,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Parent member membership (subscription) ID.
  final String memberMembershipId;

  /// Original membership add-on template ID.
  final String membershipAddOnId;

  /// Snapshot of the add-on name at time of purchase.
  final String addOnName;

  /// Snapshot of the add-on price at time of purchase (PHP).
  final num price;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;
}
