import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';

part 'todays_checkins_controller.g.dart';

/// Count of check-ins today for the current branch.
@riverpod
Future<int> todaysCheckInsCount(Ref ref) async {
  final branchId = ref.watch(currentBranchIdProvider);
  final pb = ref.read(pocketbaseProvider);
  final now = DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);

  final filter = PBFilter().after('checkInTime', startOfToday);
  if (branchId != null) {
    filter.relation('branch', branchId);
  }

  final result = await pb
      .collection(PocketBaseCollections.checkIns)
      .getList(
        page: 1,
        perPage: 1,
        filter: filter.buildOrEmpty(),
      );

  return result.totalItems;
}
