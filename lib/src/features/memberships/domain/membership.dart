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
    this.validBranches = const [],
    this.description,
    this.isActive = true,
    this.isFavorite = false,
    this.memberNotRequired = false,
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

  /// Branch this plan belongs to (catalog/home branch).
  final String branchId;

  /// Branches where this plan grants check-in access.
  ///
  /// Empty list means valid at **all** branches.
  final List<String> validBranches;

  /// Whether this plan is currently offered.
  final bool isActive;

  /// Whether this plan is pinned as a favorite in selection lists.
  final bool isFavorite;

  /// When true, this is a day-pass / walk-in plan sold with a customer name
  /// only (no linked member or [MemberMembership] record).
  final bool memberNotRequired;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// Whether this plan grants access at [branchId].
  ///
  /// Empty [validBranches] means all branches.
  bool isValidAtBranch(String branchId) =>
      validBranches.isEmpty || validBranches.contains(branchId);

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

  /// Short badge label for walk-in / day-pass plans; null for standard plans.
  String? get walkInBadgeLabel => memberNotRequired ? 'Walk-in' : null;

  /// Plan type label for detail views.
  String get planTypeDisplay => memberNotRequired
      ? 'Walk-in (membership not required)'
      : 'Standard (membership required)';

  /// Sort comparator for membership plan lists.
  ///
  /// Order: active plans first, then favorites, then name (case-insensitive).
  static int compareForList(Membership a, Membership b) {
    if (a.isActive != b.isActive) {
      return a.isActive ? -1 : 1;
    }
    if (a.isFavorite != b.isFavorite) {
      return a.isFavorite ? -1 : 1;
    }
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }
}
