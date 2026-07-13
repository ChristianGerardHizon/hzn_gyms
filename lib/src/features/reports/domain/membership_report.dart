import 'package:dart_mappable/dart_mappable.dart';

import 'period_bucket.dart';

part 'membership_report.mapper.dart';

/// Aggregated membership and member data for a time period.
///
/// Lifecycle-focused: active base, renewals, churn. Plan value is labeled
/// separately from Sales "cash collected" — do not sum the two.
@MappableClass()
class MembershipReport with MembershipReportMappable {
  const MembershipReport({
    required this.totalNewMembers,
    required this.activeMemberships,
    required this.expiredCancelledMemberships,
    required this.membershipRevenue,
    required this.addOnRevenue,
    required this.registrationsTrend,
    required this.membershipPlanDistribution,
    required this.revenueByPlan,
    this.newSubscriptions = 0,
    this.renewals = 0,
    this.expiringSoonCount = 0,
    this.lapsedCount = 0,
  });

  /// Number of members registered during the period.
  final int totalNewMembers;

  /// Number of currently active memberships.
  final int activeMemberships;

  /// Number of memberships created in period with expired/cancelled status.
  final int expiredCancelledMemberships;

  /// Plan value sold (sale line subtotals or catalog fallback).
  final num membershipRevenue;

  /// Add-on value sold in the period.
  final num addOnRevenue;

  /// New member registrations trend (bucketed by period granularity).
  final List<PeriodBucket> registrationsTrend;

  /// Membership plan name -> subscription count in period.
  final Map<String, num> membershipPlanDistribution;

  /// Membership plan name -> total plan value in period.
  final Map<String, num> revenueByPlan;

  final int newSubscriptions;
  final int renewals;
  final int expiringSoonCount;
  final int lapsedCount;

  static const empty = MembershipReport(
    totalNewMembers: 0,
    activeMemberships: 0,
    expiredCancelledMemberships: 0,
    membershipRevenue: 0,
    addOnRevenue: 0,
    registrationsTrend: [],
    membershipPlanDistribution: {},
    revenueByPlan: {},
  );
}
