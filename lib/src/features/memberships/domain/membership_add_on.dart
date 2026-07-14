import 'package:dart_mappable/dart_mappable.dart';

part 'membership_add_on.mapper.dart';

/// An add-on option that belongs to a membership plan.
///
/// Represents optional extras a member can purchase alongside a membership
/// (e.g. "Treadmill Access", "Coach/Instructor", "Promo +3 months").
///
/// When [durationDays] is greater than zero, selecting the add-on extends the
/// membership end date by that many days (e.g. promo length).
@MappableClass()
class MembershipAddOn with MembershipAddOnMappable {
  const MembershipAddOn({
    required this.id,
    required this.membershipId,
    required this.name,
    required this.price,
    this.description,
    this.durationDays = 0,
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

  /// Extra days added to the membership period when this add-on is selected.
  ///
  /// Use `0` for access/feature add-ons that do not change the end date.
  final int durationDays;

  /// Whether this add-on is currently offered.
  final bool isActive;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// Whether this add-on extends the membership period.
  bool get extendsDuration => durationDays > 0;

  /// Display string for bonus duration (empty when [durationDays] is 0).
  String get durationDisplay {
    if (durationDays <= 0) return '';
    if (durationDays == 1) return '+1 day';
    if (durationDays == 7) return '+1 week';
    if (durationDays == 30) return '+1 month';
    if (durationDays == 90) return '+3 months';
    if (durationDays == 180) return '+6 months';
    if (durationDays == 365) return '+1 year';
    return '+$durationDays days';
  }

  /// Sum of [durationDays] across [addOns].
  static int totalBonusDays(Iterable<MembershipAddOn> addOns) =>
      addOns.fold(0, (sum, a) => sum + a.durationDays);
}
