import 'package:dart_mappable/dart_mappable.dart';

part 'membership_report.mapper.dart';

/// Aggregated membership and member data for a time period.
@MappableClass()
class MembershipReport with MembershipReportMappable {
  const MembershipReport({
    required this.totalNewMembers,
    required this.activeMemberships,
    required this.expiredCancelledMemberships,
    required this.membershipRevenue,
    required this.addOnRevenue,
    required this.registrationsByDay,
    required this.membershipPlanDistribution,
    required this.revenueByPlan,
  });

  /// Number of members registered during the period.
  final int totalNewMembers;

  /// Number of currently active memberships (status active, date range covers now).
  final int activeMemberships;

  /// Number of memberships created in period with expired/cancelled status.
  final int expiredCancelledMemberships;

  /// Total revenue from membership plan prices in the period.
  final num membershipRevenue;

  /// Total revenue from add-on purchases in the period.
  final num addOnRevenue;

  /// New member registrations grouped by day (for line chart).
  final List<DailyRegistration> registrationsByDay;

  /// Membership plan name -> subscription count in period (for pie chart).
  final Map<String, num> membershipPlanDistribution;

  /// Membership plan name -> total revenue in period (for bar chart).
  final Map<String, num> revenueByPlan;

  /// Empty report for initial/error states.
  static const empty = MembershipReport(
    totalNewMembers: 0,
    activeMemberships: 0,
    expiredCancelledMemberships: 0,
    membershipRevenue: 0,
    addOnRevenue: 0,
    registrationsByDay: [],
    membershipPlanDistribution: {},
    revenueByPlan: {},
  );
}

/// Member registrations for a single day.
@MappableClass()
class DailyRegistration with DailyRegistrationMappable {
  const DailyRegistration({
    required this.date,
    required this.count,
  });

  final DateTime date;
  final int count;
}
