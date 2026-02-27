import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../members/domain/member.dart';
import '../../../members/presentation/controllers/members_controller.dart';
import '../../../memberships/data/dto/member_membership_dto.dart';
import '../../../memberships/domain/member_membership.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';

part 'dashboard_members_controller.g.dart';

/// A member combined with their latest membership (if any).
class DashboardMember {
  const DashboardMember({
    required this.member,
    this.activeMembership,
    this.latestMembership,
  });

  final Member member;

  /// The current active (non-expired) membership, if any.
  final MemberMembership? activeMembership;

  /// The most recent membership regardless of expiry status.
  final MemberMembership? latestMembership;

  /// Days until membership expires, or null if no active membership.
  int? get daysUntilExpiry => activeMembership?.daysRemaining;

  /// Whether this member's membership has expired.
  bool get isExpired =>
      activeMembership == null && latestMembership != null;
}

/// All members with their latest active membership attached.
///
/// Sorted with near-expiration members first, then active, then no membership.
@riverpod
Future<List<DashboardMember>> dashboardMembers(Ref ref) async {
  final branchId = ref.watch(currentBranchIdProvider);
  final pb = ref.read(pocketbaseProvider);

  // 1. Get all members from the existing keepAlive provider
  final membersAsync = ref.watch(membersControllerProvider);
  final members = membersAsync.value ?? [];

  // 2. Fetch all active memberMemberships (not yet expired)
  final activeFilter = PBFilter()
      .equals('status', 'active')
      .greaterOrEqual('endDate', DateTime.now());
  if (branchId != null) {
    activeFilter.relation('branch', branchId);
  }

  // 3. Fetch all memberships (including expired) to detect expired members
  final allFilter = PBFilter();
  if (branchId != null) {
    allFilter.relation('branch', branchId);
  }

  final activeResult = await pb
      .collection(PocketBaseCollections.memberMemberships)
      .getFullList(
        filter: activeFilter.buildOrEmpty(),
        sort: '-endDate',
        expand: 'member,membership',
      );

  final allResult = await pb
      .collection(PocketBaseCollections.memberMemberships)
      .getFullList(
        filter: allFilter.buildOrEmpty(),
        sort: '-endDate',
        expand: 'member,membership',
      );

  final activeMemberships = activeResult
      .map((RecordModel r) => MemberMembershipDto.fromRecord(r).toEntity())
      .toList();

  final allMemberships = allResult
      .map((RecordModel r) => MemberMembershipDto.fromRecord(r).toEntity())
      .toList();

  // 4. Group by memberId, pick latest endDate per member
  final activeByMember = <String, MemberMembership>{};
  for (final mm in activeMemberships) {
    final existing = activeByMember[mm.memberId];
    if (existing == null || mm.endDate.isAfter(existing.endDate)) {
      activeByMember[mm.memberId] = mm;
    }
  }

  final latestByMember = <String, MemberMembership>{};
  for (final mm in allMemberships) {
    final existing = latestByMember[mm.memberId];
    if (existing == null || mm.endDate.isAfter(existing.endDate)) {
      latestByMember[mm.memberId] = mm;
    }
  }

  // 5. Combine: attach memberships to each member
  final dashboardMembers = members.map((member) {
    return DashboardMember(
      member: member,
      activeMembership: activeByMember[member.id],
      latestMembership: latestByMember[member.id],
    );
  }).toList();

  // 6. Sort: expired first, then expiring soon, then active, then no membership last
  dashboardMembers.sort((a, b) {
    // Expired members first
    if (a.isExpired && !b.isExpired) return -1;
    if (!a.isExpired && b.isExpired) return 1;
    if (a.isExpired && b.isExpired) {
      // Both expired: sort by most recently expired first
      return b.latestMembership!.endDate
          .compareTo(a.latestMembership!.endDate);
    }

    final aDays = a.daysUntilExpiry;
    final bDays = b.daysUntilExpiry;

    // Members with no membership go last
    if (aDays == null && bDays == null) return 0;
    if (aDays == null) return 1;
    if (bDays == null) return -1;

    // Sort by days remaining ascending (most urgent first)
    return aDays.compareTo(bDays);
  });

  return dashboardMembers;
}
