import 'dart:async';

import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/utils/perf_logger.dart';
import '../../../memberships/data/repositories/membership_repository.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';

part 'dashboard_members_controller.g.dart';

/// Membership status filter for the dashboard grid.
enum MemberStatusFilter {
  all('All'),
  active('Active'),
  expiringSoon('Expiring Soon'),
  expired('Expired');

  const MemberStatusFilter(this.label);
  final String label;
}

/// A member from the membersWithMembershipStatus view collection.
class DashboardMember {
  const DashboardMember({
    required this.id,
    required this.name,
    this.photo,
    this.mobileNumber,
    this.expirationDate,
    this.membershipStatus,
  });

  final String id;
  final String name;
  final String? photo;
  final String? mobileNumber;
  final DateTime? expirationDate;
  final String? membershipStatus;

  /// End date shown on cards when the view row is an active membership.
  ///
  /// Non-active statuses (cancelled/voided/etc.) can still carry an
  /// [expirationDate] from the view join fallback — those must not drive
  /// the days-left pill or end-date label.
  DateTime? get displayExpirationDate =>
      membershipStatus == 'active' ? expirationDate : null;

  /// Days until membership expires, or null if no active membership.
  ///
  /// Returns `0` on the expiration day (still valid through that day).
  int? get daysUntilExpiry {
    final end = displayExpirationDate;
    if (end == null) return null;
    return calendarDaysUntil(end);
  }

  /// Complete calendar months until membership expires, or null if none.
  int? get monthsUntilExpiry {
    final end = displayExpirationDate;
    if (end == null) return null;
    return calendarMonthsUntil(end);
  }

  /// Whether this member's membership has expired.
  ///
  /// Expiration is inclusive of the end date — members expiring today
  /// are not considered expired until the following day.
  bool get isExpired {
    final end = displayExpirationDate;
    if (end == null) return false;
    return isBeforeToday(end);
  }

  /// Whether this member has an active (non-expired) membership.
  bool get hasActiveMembership => displayExpirationDate != null && !isExpired;

  /// Factory from a PocketBase RecordModel from the view collection.
  factory DashboardMember.fromViewRecord(
    RecordModel record, {
    required String baseUrl,
  }) {
    final id = record.id;
    final name = record.getStringValue('name');
    final photoFile = record.getStringValue('photo');
    final mobileNumber = record.getStringValue('mobileNumber');
    final endDateStr = record.get<String>('expirationDate');
    final status = record.getStringValue('membershipStatus');

    // Build photo URL using the original 'members' collection
    // since the view inherits file references from the members table.
    String? photoUrl;
    if (photoFile.isNotEmpty) {
      photoUrl =
          '$baseUrl/api/files/${PocketBaseCollections.members}/$id/$photoFile';
    }

    return DashboardMember(
      id: id,
      name: name,
      photo: photoUrl,
      mobileNumber: mobileNumber.isNotEmpty ? mobileNumber : null,
      expirationDate: parseToLocal(endDateStr),
      membershipStatus: status.isNotEmpty ? status : null,
    );
  }
}

/// Result of a paginated dashboard members query.
class DashboardMembersPage {
  const DashboardMembersPage({
    required this.items,
    required this.totalItems,
    required this.page,
    required this.totalPages,
  });

  final List<DashboardMember> items;
  final int totalItems;
  final int page;
  final int totalPages;

  bool get hasMore => page < totalPages;
}

const _pageSize = 20;

String _dashboardMembersSort(MemberStatusFilter statusFilter) {
  switch (statusFilter) {
    case MemberStatusFilter.all:
      // Upcoming first (soonest expiration, like Expiring Soon), then expired
      // when scrolling — no date-range limit.
      return 'membershipSortTier,membershipSortOrder,name';
    case MemberStatusFilter.active:
    case MemberStatusFilter.expiringSoon:
      return 'expirationDate,name';
    case MemberStatusFilter.expired:
      return '-expirationDate,name';
  }
}

/// Fetches a single page of members with their membership status
/// from the [membersWithMembershipStatus] view collection.
///
/// Uses server-side pagination and filtering. A single API call
/// replaces the previous 3-call approach (members + active memberships
/// + all memberships).
///
/// Keeps itself alive briefly so silent prefetch via `.future` cannot dispose
/// the provider while the network request is still in flight (Riverpod would
/// otherwise throw "disposed during loading state").
@riverpod
Future<DashboardMembersPage> dashboardMembersPage(
  Ref ref, {
  int page = 1,
  String? searchQuery,
  MemberStatusFilter statusFilter = MemberStatusFilter.expiringSoon,
}) async {
  final link = ref.keepAlive();
  Timer? disposeTimer;
  ref.onCancel(() {
    disposeTimer?.cancel();
    disposeTimer = Timer(const Duration(seconds: 30), link.close);
  });
  ref.onResume(() {
    disposeTimer?.cancel();
  });
  ref.onDispose(() {
    disposeTimer?.cancel();
  });

  final perf = PerfTimer(
    'dashboardMembersPage p$page ${statusFilter.name}'
    '${searchQuery != null && searchQuery.isNotEmpty ? ' q="$searchQuery"' : ''}',
  );

  final branchId = ref.watch(currentBranchIdProvider);
  perf.checkpoint('branchId resolved (id=$branchId)');

  final pb = ref.read(pocketbaseProvider);
  perf.checkpoint('pocketbase ready');

  final filter = PBFilter();

  // Search filter
  if (searchQuery != null && searchQuery.isNotEmpty) {
    filter.searchFields(searchQuery, ['name', 'mobileNumber']);
  }

  // When a branch is selected, only members whose (best) membership plan is
  // valid at that branch (validBranches contains it, or empty = all).
  if (branchId != null) {
    final plansResult = await ref
        .read(membershipRepositoryProvider)
        .fetchAll(branchId: branchId);
    final planIds = plansResult.fold(
      (_) => <String>[],
      (plans) => plans.map((p) => p.id).toList(),
    );
    if (planIds.isEmpty) {
      perf.finish('no plans valid at branch');
      return const DashboardMembersPage(
        items: [],
        totalItems: 0,
        page: 1,
        totalPages: 0,
      );
    }
    final orClause = planIds
        .map((id) => 'membershipId = "$id"')
        .join(' || ');
    filter.raw('($orClause)');
  }

  // Status filter (server-side via the view's expirationDate)
  final now = DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);
  final endOfSevenDayWindow = DateTime(
    now.year,
    now.month,
    now.day + 7,
    23,
    59,
    59,
    999,
  );
  switch (statusFilter) {
    case MemberStatusFilter.all:
      break;
    case MemberStatusFilter.active:
      // Non-expired active memberships (expiration day is still valid)
      filter.equals('membershipStatus', 'active');
      filter.greaterOrEqual('expirationDate', startOfToday);
      break;
    case MemberStatusFilter.expiringSoon:
      // Active memberships from today through the next 7 calendar days
      filter.equals('membershipStatus', 'active');
      filter.greaterOrEqual('expirationDate', startOfToday);
      filter.lessOrEqual('expirationDate', endOfSevenDayWindow);
      break;
    case MemberStatusFilter.expired:
      // End date before today (expiration day is still valid)
      filter.lessThan('expirationDate', startOfToday);
      break;
  }

  final filterString = filter.build();
  perf.checkpoint('filter built ($filterString)');

  final result = await pb
      .collection(PocketBaseCollections.membersWithMembershipStatus)
      .getList(
        page: page,
        perPage: _pageSize,
        filter: filterString,
        sort: _dashboardMembersSort(statusFilter),
      );

  perf.checkpoint(
    'API getList returned ${result.items.length} items '
    '(total=${result.totalItems}, page=${result.page}/${result.totalPages})',
  );

  final items = result.items
      .map((r) => DashboardMember.fromViewRecord(r, baseUrl: pb.baseURL))
      .toList();

  perf.checkpoint('mapped ${items.length} DashboardMember entities');
  perf.finish();

  return DashboardMembersPage(
    items: items,
    totalItems: result.totalItems,
    page: result.page,
    totalPages: result.totalPages,
  );
}
