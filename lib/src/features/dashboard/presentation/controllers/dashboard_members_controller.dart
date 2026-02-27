import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';

part 'dashboard_members_controller.g.dart';

/// Membership status filter for the dashboard grid.
enum MemberStatusFilter {
  all('All'),
  expired('Expired'),
  expiringSoon('Expiring Soon');

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
    this.membershipEndDate,
    this.membershipStatus,
  });

  final String id;
  final String name;
  final String? photo;
  final String? mobileNumber;
  final DateTime? membershipEndDate;
  final String? membershipStatus;

  /// Days until membership expires, or null if no membership.
  int? get daysUntilExpiry {
    if (membershipEndDate == null) return null;
    final now = DateTime.now();
    if (now.isAfter(membershipEndDate!)) return 0;
    return membershipEndDate!.difference(now).inDays;
  }

  /// Whether this member's membership has expired.
  bool get isExpired {
    if (membershipEndDate == null) return false;
    return DateTime.now().isAfter(membershipEndDate!);
  }

  /// Whether this member has an active (non-expired) membership.
  bool get hasActiveMembership =>
      membershipEndDate != null && !isExpired;

  /// Factory from a PocketBase RecordModel from the view collection.
  factory DashboardMember.fromViewRecord(
    RecordModel record, {
    required String baseUrl,
  }) {
    final id = record.id;
    final name = record.getStringValue('name');
    final photoFile = record.getStringValue('photo');
    final mobileNumber = record.getStringValue('mobileNumber');
    final endDateStr = record.get<String>('membershipEndDate');
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
      membershipEndDate: parseToLocal(endDateStr),
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

const _pageSize = 12;

/// Fetches a single page of members with their membership status
/// from the [membersWithMembershipStatus] view collection.
///
/// Uses server-side pagination and filtering. A single API call
/// replaces the previous 3-call approach (members + active memberships
/// + all memberships).
@riverpod
Future<DashboardMembersPage> dashboardMembersPage(
  Ref ref, {
  int page = 1,
  String? searchQuery,
  MemberStatusFilter statusFilter = MemberStatusFilter.all,
}) async {
  final branchId = ref.watch(currentBranchIdProvider);
  final pb = ref.read(pocketbaseProvider);

  final filter = PBFilter();

  // Search filter
  if (searchQuery != null && searchQuery.isNotEmpty) {
    filter.searchFields(searchQuery, ['name', 'mobileNumber']);
  }

  // Branch filter
  if (branchId != null) {
    filter.relation('membershipBranch', branchId);
  }

  // Status filter (server-side via the view's membershipEndDate)
  final now = DateTime.now();
  switch (statusFilter) {
    case MemberStatusFilter.all:
      break;
    case MemberStatusFilter.expired:
      // Members whose latest membership endDate is in the past
      filter.lessThan('membershipEndDate', now);
      break;
    case MemberStatusFilter.expiringSoon:
      // Members whose latest membership endDate is between now and +7 days
      filter.greaterOrEqual('membershipEndDate', now);
      final sevenDaysFromNow = now.add(const Duration(days: 7));
      filter.lessOrEqual('membershipEndDate', sevenDaysFromNow);
      break;
  }

  final result = await pb
      .collection(PocketBaseCollections.membersWithMembershipStatus)
      .getList(
        page: page,
        perPage: _pageSize,
        filter: filter.build(),
        sort: 'name',
      );

  final items = result.items
      .map((r) => DashboardMember.fromViewRecord(r, baseUrl: pb.baseURL))
      .toList();

  return DashboardMembersPage(
    items: items,
    totalItems: result.totalItems,
    page: result.page,
    totalPages: result.totalPages,
  );
}
