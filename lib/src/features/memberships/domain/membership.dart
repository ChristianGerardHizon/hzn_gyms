import 'package:dart_mappable/dart_mappable.dart';

import '../../../core/utils/date_utils.dart';

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
    required this.durationValue,
    this.durationUnit = MembershipDurationUnit.days,
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

  /// Duration quantity, interpreted in [durationUnit] (e.g. `1` + `months`).
  final int durationValue;

  /// Unit [durationValue] is measured in (day/week/month/year).
  final MembershipDurationUnit durationUnit;

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

  /// Human-readable label for [validBranches] using [branchNamesById].
  ///
  /// Empty [validBranches] means all branches. Unknown IDs fall back to the
  /// raw ID string.
  String validBranchesDisplay(Map<String, String> branchNamesById) =>
      formatValidBranchesDisplay(validBranches, branchNamesById);

  /// Labels for branch chips: `All branches`, or one name/id per valid branch.
  List<String> validBranchLabels(Map<String, String> branchNamesById) =>
      formatValidBranchLabels(validBranches, branchNamesById);

  /// Display string for duration, e.g. `"1 month"` / `"3 weeks"`.
  String get durationDisplay => durationUnit.label(durationValue);

  /// Short badge label for walk-in / day-pass plans; null for standard plans.
  String? get walkInBadgeLabel => memberNotRequired ? 'Walk-in' : null;

  /// Plan type label for detail views.
  String get planTypeDisplay => memberNotRequired
      ? 'Walk-in (membership not required)'
      : 'Recurring (membership required)';

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

/// Formats plan [validBranchIds] for display.
///
/// Empty list → `"All branches"`. Otherwise joins names from
/// [branchNamesById], falling back to the raw ID when a name is missing.
String formatValidBranchesDisplay(
  List<String> validBranchIds,
  Map<String, String> branchNamesById,
) {
  if (validBranchIds.isEmpty) return 'All branches';
  return validBranchIds.map((id) => branchNamesById[id] ?? id).join(', ');
}

/// Chip labels for [validBranchIds].
///
/// Empty list → a single `"All branches"` label. Otherwise one label per id.
List<String> formatValidBranchLabels(
  List<String> validBranchIds,
  Map<String, String> branchNamesById,
) {
  if (validBranchIds.isEmpty) return const ['All branches'];
  return [
    for (final id in validBranchIds) branchNamesById[id] ?? id,
  ];
}
