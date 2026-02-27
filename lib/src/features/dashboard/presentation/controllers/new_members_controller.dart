import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';

part 'new_members_controller.g.dart';

/// Count of new members registered today.
///
/// Queries the members collection with a date filter on `created`.
/// Members are global (no branch filter).
@riverpod
Future<int> todaysNewMembersCount(Ref ref) async {
  final pb = ref.read(pocketbaseProvider);
  final now = DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);

  final filter = PBFilter().after('created', startOfToday);

  final result = await pb
      .collection(PocketBaseCollections.members)
      .getList(
        page: 1,
        perPage: 1,
        filter: filter.buildOrEmpty(),
      );

  return result.totalItems;
}
