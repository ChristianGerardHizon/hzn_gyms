import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/sync/sync_status.dart';
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
      (failure) async {
        final pending = await _loadPending(memberId);
        if (pending.isNotEmpty) return pending;
        throw failure;
      },
      (memberships) async {
        final pending = await _loadPending(memberId);
        return [...pending, ...memberships];
      },
    );
  }

  Future<List<MemberMembership>> _loadPending(String memberId) async {
    final db = ref.read(appDatabaseProvider);
    final rows = await db.pendingMemberMembershipsDao.getByMember(memberId);
    return rows
        .where((r) => r.syncStatus != SyncStatus.synced.name)
        .map(
          (r) => MemberMembership(
            id: r.id,
            memberId: r.memberId,
            membershipId: r.membershipId,
            startDate: r.startDate,
            endDate: r.endDate,
            status: MemberMembershipStatus.active,
            branchId: '',
            membershipName: r.planName,
            saleId: r.saleId,
          ),
        )
        .toList();
  }

  /// Refreshes the member's memberships.
  Future<void> refresh() async {
    _repository.invalidateCache();
    state = const AsyncLoading();

    final result = await _repository.fetchByMember(memberId);
    if (!ref.mounted) return;

    state = await result.fold(
      (failure) async {
        final pending = await _loadPending(memberId);
        if (pending.isNotEmpty) return AsyncData(pending);
        return AsyncError(failure, StackTrace.current);
      },
      (memberships) async {
        final pending = await _loadPending(memberId);
        return AsyncData([...pending, ...memberships]);
      },
    );
  }

  /// Updates start/end dates for a member's membership.
  ///
  /// Returns `null` on success, or a failure message string.
  Future<String?> updateMembershipDates(
    String memberMembershipId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final result = await _repository.update(
      memberMembershipId,
      startDate: startDate,
      endDate: endDate,
    );
    final error = result.fold((failure) => failure.messageString, (_) => null);
    if (error != null) return error;
    if (!ref.mounted) return null;
    await refresh();
    return null;
  }

  /// Cancels a member's membership (soft cancel).
  ///
  /// Returns `null` on success, or a failure message string.
  Future<String?> cancelMembership(String memberMembershipId) async {
    final result = await _repository.cancel(memberMembershipId);
    final error = result.fold((failure) => failure.messageString, (_) => null);
    if (error != null) return error;
    if (!ref.mounted) return null;
    await refresh();
    return null;
  }
}
