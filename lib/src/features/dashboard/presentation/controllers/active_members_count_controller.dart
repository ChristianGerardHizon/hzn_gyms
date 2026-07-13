import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../memberships/data/dto/member_membership_dto.dart';
import '../../../memberships/domain/member_membership.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';

part 'active_members_count_controller.g.dart';

PBFilter _activeMembershipsFilter(String? branchId) {
  final now = DateTime.now();
  final filter = PBFilter()
      .equals('status', 'active')
      .lessOrEqual('startDate', now)
      .greaterOrEqual('endDate', now);
  if (branchId != null) {
    filter.relation('branch', branchId);
  }
  return filter;
}

/// Count of members with currently active memberships.
///
/// Queries memberMemberships where status = 'active'
/// and current date is between startDate and endDate.
@riverpod
Future<int> activeMembersCount(Ref ref) async {
  final branchId = ref.watch(currentBranchIdProvider);
  final pb = ref.read(pocketbaseProvider);

  final result = await pb
      .collection(PocketBaseCollections.memberMemberships)
      .getList(
        page: 1,
        perPage: 1,
        filter: _activeMembershipsFilter(branchId).buildOrEmpty(),
      );

  return result.totalItems;
}

/// Active memberships for the current branch (KPI breakdown list).
///
/// Same filter as [activeMembersCount]; one row per membership.
@riverpod
Future<List<MemberMembership>> activeMembersList(Ref ref) async {
  final branchId = ref.watch(currentBranchIdProvider);
  final pb = ref.read(pocketbaseProvider);

  final records = await pb
      .collection(PocketBaseCollections.memberMemberships)
      .getFullList(
        filter: _activeMembershipsFilter(branchId).buildOrEmpty(),
        sort: 'endDate',
        expand: 'member,membership',
      );

  return records
      .map((RecordModel r) => MemberMembershipDto.fromRecord(r).toEntity())
      .toList();
}
