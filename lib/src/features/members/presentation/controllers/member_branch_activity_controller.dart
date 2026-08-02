import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../memberships/data/repositories/member_membership_repository.dart';
import '../../../memberships/domain/member_branch_activity.dart';
import '../../../settings/presentation/controllers/branches_controller.dart';
import 'paginated_members_controller.dart';

part 'member_branch_activity_controller.g.dart';

/// Branch activity summary for members visible in the current list page.
class MemberBranchActivityState {
  const MemberBranchActivityState({
    required this.activityByMemberId,
    required this.branchNameById,
  });

  final Map<String, MemberBranchActivity> activityByMemberId;
  final Map<String, String> branchNameById;

  static const empty = MemberBranchActivityState(
    activityByMemberId: {},
    branchNameById: {},
  );
}

/// Stable Riverpod family key for a set of member IDs.
String memberBranchActivityIdsKey(Iterable<String> memberIds) {
  final sorted = memberIds.toList()..sort();
  return sorted.join(',');
}

Future<MemberBranchActivityState> _loadMemberBranchActivity(
  Ref ref,
  List<String> memberIds,
) async {
  if (memberIds.isEmpty) {
    return MemberBranchActivityState.empty;
  }

  final branches = await ref.watch(branchesControllerProvider.future);
  final allBranchIds = branches.map((b) => b.id).toList();
  final branchNameById = {for (final b in branches) b.id: b.name};

  final result = await ref
      .read(memberMembershipRepositoryProvider)
      .fetchActiveByMemberIds(memberIds);

  return result.fold(
    (_) => MemberBranchActivityState(
      activityByMemberId: {
        for (final id in memberIds) id: const MemberBranchActivity(branchIds: {}),
      },
      branchNameById: branchNameById,
    ),
    (byMember) => MemberBranchActivityState(
      activityByMemberId: {
        for (final id in memberIds)
          id: resolveMemberActiveBranchIds(
            memberships: byMember[id] ?? const [],
            allBranchIds: allBranchIds,
          ),
      },
      branchNameById: branchNameById,
    ),
  );
}

/// Loads active branch access for the given member IDs.
@riverpod
Future<MemberBranchActivityState> memberBranchActivityForIds(
  Ref ref,
  String memberIdsKey,
) {
  final memberIds = memberIdsKey.isEmpty
      ? <String>[]
      : memberIdsKey.split(',');
  return _loadMemberBranchActivity(ref, memberIds);
}

/// Loads active branch access for all members on the current paginated page.
@riverpod
Future<MemberBranchActivityState> memberBranchActivityMap(Ref ref) async {
  final page = ref.watch(paginatedMembersControllerProvider).value;
  final memberIds = page?.items.map((m) => m.id).toList() ?? [];
  return _loadMemberBranchActivity(ref, memberIds);
}
