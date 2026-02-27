import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';

part 'active_members_count_controller.g.dart';

/// Count of members with currently active memberships.
///
/// Queries memberMemberships where status = 'active'
/// and current date is between startDate and endDate.
@riverpod
Future<int> activeMembersCount(Ref ref) async {
  final branchId = ref.watch(currentBranchIdProvider);
  final pb = ref.read(pocketbaseProvider);
  final now = DateTime.now();

  final filter = PBFilter()
      .equals('status', 'active')
      .lessOrEqual('startDate', now)
      .greaterOrEqual('endDate', now);
  if (branchId != null) {
    filter.relation('branch', branchId);
  }

  final result = await pb
      .collection(PocketBaseCollections.memberMemberships)
      .getList(
        page: 1,
        perPage: 1,
        filter: filter.buildOrEmpty(),
      );

  return result.totalItems;
}
