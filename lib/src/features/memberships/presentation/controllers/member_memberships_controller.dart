import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/member_membership_repository.dart';
import '../../domain/member_membership.dart';

part 'member_memberships_controller.g.dart';

/// Controller for managing a member's memberships (subscriptions).
///
/// Fetches all memberships for a specific member by ID.
@riverpod
class MemberMembershipsController extends _$MemberMembershipsController {
  MemberMembershipRepository get _repository =>
      ref.read(memberMembershipRepositoryProvider);

  @override
  Future<List<MemberMembership>> build(String memberId) async {
    final result = await _repository.fetchByMember(memberId);

    return result.fold(
      (failure) => throw failure,
      (memberships) => memberships,
    );
  }

  /// Refreshes the member's memberships.
  Future<void> refresh() async {
    _repository.invalidateCache();
    state = const AsyncLoading();

    final result = await _repository.fetchByMember(memberId);

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (memberships) => AsyncData(memberships),
    );
  }

  /// Cancels a member's membership.
  Future<bool> cancelMembership(String memberMembershipId) async {
    final result = await _repository.cancel(memberMembershipId);
    return result.fold(
      (failure) => false,
      (_) {
        refresh();
        return true;
      },
    );
  }
}
