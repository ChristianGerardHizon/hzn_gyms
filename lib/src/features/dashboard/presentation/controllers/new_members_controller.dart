import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../members/data/dto/member_dto.dart';
import '../../../members/domain/member.dart';

part 'new_members_controller.g.dart';

PBFilter _todaysNewMembersFilter() {
  final now = DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);
  return PBFilter().after('created', startOfToday);
}

/// Count of new members registered today.
///
/// Queries the members collection with a date filter on `created`.
/// Members are global (no branch filter).
@riverpod
Future<int> todaysNewMembersCount(Ref ref) async {
  final pb = ref.read(pocketbaseProvider);

  final result = await pb
      .collection(PocketBaseCollections.members)
      .getList(
        page: 1,
        perPage: 1,
        filter: _todaysNewMembersFilter().buildOrEmpty(),
      );

  return result.totalItems;
}

/// Members registered today (KPI breakdown list).
///
/// Same filter as [todaysNewMembersCount]; sorted newest first.
@riverpod
Future<List<Member>> todaysNewMembersList(Ref ref) async {
  final pb = ref.read(pocketbaseProvider);

  final records = await pb
      .collection(PocketBaseCollections.members)
      .getFullList(
        filter: _todaysNewMembersFilter().buildOrEmpty(),
        sort: '-created',
      );

  return records
      .map(
        (RecordModel r) =>
            MemberDto.fromRecord(r).toEntity(baseUrl: pb.baseURL),
      )
      .toList();
}
