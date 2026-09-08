import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../members/data/dto/member_dto.dart';
import '../../../members/domain/member.dart';
import '../../../memberships/data/dto/member_membership_dto.dart';
import '../../../memberships/domain/member_membership.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';

part 'new_members_controller.g.dart';

PBFilter _todaysNewMembersFilter() {
  final now = DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);
  return PBFilter().after('created', startOfToday);
}

/// Count of new members registered today at the current branch.
///
/// Derived from [todaysNewMembersList] so the card and breakdown dialog
/// never disagree.
@riverpod
Future<int> todaysNewMembersCount(Ref ref) async {
  final entries = await ref.watch(todaysNewMembersListProvider.future);
  return entries.length;
}

/// A member registered today, paired with the membership plan they enrolled
/// in (their earliest membership record), if any.
class NewMemberEntry {
  const NewMemberEntry({required this.member, this.membership});

  final Member member;
  final MemberMembership? membership;

  /// Branch this member is attributed to.
  ///
  /// Prefers the branch of their enrolled membership — always populated —
  /// over the member's own `branch` field, which is optional and can be
  /// unset for members registered without immediately buying a plan.
  String? get effectiveBranchId => membership?.branchId ?? member.branch;
}

/// Members registered today (KPI breakdown list), each paired with the
/// membership plan they signed up for, filtered to the current branch.
///
/// Members are attributed to a branch via [NewMemberEntry.effectiveBranchId].
/// Unfiltered when viewing all branches. Sorted newest first.
@riverpod
Future<List<NewMemberEntry>> todaysNewMembersList(Ref ref) async {
  final branchId = ref.watch(currentBranchIdProvider);
  final pb = ref.read(pocketbaseProvider);

  final records = await pb
      .collection(PocketBaseCollections.members)
      .getFullList(
        filter: _todaysNewMembersFilter().buildOrEmpty(),
        sort: '-created',
      );

  final members = records
      .map(
        (RecordModel r) =>
            MemberDto.fromRecord(r).toEntity(baseUrl: pb.baseURL),
      )
      .toList();

  if (members.isEmpty) return const [];

  final membershipByMember = await _fetchEnrolledMemberships(
    pb,
    members.map((m) => m.id),
  );

  final entries = [
    for (final member in members)
      NewMemberEntry(
        member: member,
        membership: membershipByMember[member.id],
      ),
  ];

  if (branchId == null) return entries;
  return entries.where((e) => e.effectiveBranchId == branchId).toList();
}

/// Max member IDs per OR-filter chunk, kept under PocketBase's max filter
/// length (mirrors [MemberMembershipRepository]'s chunk size).
const _memberIdChunkSize = 50;

/// Fetches each member's earliest membership record — the plan they enrolled
/// in at registration — keyed by member ID.
Future<Map<String, MemberMembership>> _fetchEnrolledMemberships(
  PocketBase pb,
  Iterable<String> memberIds,
) async {
  final uniqueIds = memberIds.toSet().toList();
  if (uniqueIds.isEmpty) return const {};

  final result = <String, MemberMembership>{};
  for (var i = 0; i < uniqueIds.length; i += _memberIdChunkSize) {
    final chunk = uniqueIds.skip(i).take(_memberIdChunkSize);
    final filter = PBFilter().relationAny('member', chunk);
    if (filter.isEmpty) continue;

    final records = await pb
        .collection(PocketBaseCollections.memberMemberships)
        .getFullList(
          filter: filter.buildOrEmpty(),
          sort: 'created',
          expand: 'membership',
        );

    for (final record in records) {
      final membership = MemberMembershipDto.fromRecord(record).toEntity();
      // Keep the first (earliest, since sorted ascending) membership per member.
      result.putIfAbsent(membership.memberId, () => membership);
    }
  }
  return result;
}
