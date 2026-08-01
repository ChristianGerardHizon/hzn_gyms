import 'dart:async';

import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../member_cards/data/repositories/member_card_repository.dart';
import '../../../members/data/repositories/member_repository.dart';
import '../../../members/domain/member.dart';
import '../../../memberships/data/repositories/member_membership_repository.dart';
import '../../../memberships/domain/member_membership.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../data/repositories/check_in_repository.dart';
import '../../domain/card_check_in_result.dart';
import '../../domain/check_in.dart';
import '../../domain/check_in_realtime.dart';

part 'check_in_controller.g.dart';

/// Controller for performing check-ins and managing today's check-in list.
///
/// After first open, stays alive for the session and keeps a PocketBase
/// realtime subscription so other devices' check-ins appear automatically.
@Riverpod(keepAlive: true)
class CheckInController extends _$CheckInController {
  static const _realtimeDebounce = Duration(milliseconds: 250);

  CheckInRepository get _repository => ref.read(checkInRepositoryProvider);

  @override
  Future<List<CheckIn>> build() async {
    // null branchId = "All branches" (no filter)
    final branchId = ref.watch(currentBranchIdProvider);

    var disposed = false;
    Timer? debounce;
    UnsubscribeFunc? unsubscribe;

    ref.onDispose(() {
      disposed = true;
      debounce?.cancel();
      final unsub = unsubscribe;
      if (unsub != null) {
        unawaited(unsub());
      }
    });

    unawaited(
      _repository
          .subscribeCheckIns(
            branchId: branchId,
            onEvent: (event) {
              if (disposed) return;
              if (!isTodaysCheckInSubscriptionEvent(event)) return;

              debounce?.cancel();
              debounce = Timer(_realtimeDebounce, () {
                if (!disposed) {
                  unawaited(_softRefresh());
                }
              });
            },
          )
          .then((unsub) {
            if (disposed) {
              unawaited(unsub());
            } else {
              unsubscribe = unsub;
            }
          }),
    );

    final result = await _repository.fetchTodaysCheckIns(branchId);

    return result.fold((failure) => throw failure, (checkIns) => checkIns);
  }

  /// Refreshes today's check-in list (shows loading state).
  Future<void> refresh() async {
    _repository.invalidateCache();
    state = const AsyncLoading();

    final branchId = ref.read(currentBranchIdProvider);
    final result = await _repository.fetchTodaysCheckIns(branchId);

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (checkIns) => AsyncData(checkIns),
    );
  }

  /// Soft refresh for realtime events — keeps prior data visible on failure.
  Future<void> _softRefresh() async {
    _repository.invalidateCache();
    final branchId = ref.read(currentBranchIdProvider);
    final result = await _repository.fetchTodaysCheckIns(branchId);

    result.fold(
      (_) {},
      (checkIns) => state = AsyncData(checkIns),
    );
  }

  /// Records a manual check-in for a member.
  Future<CheckIn?> manualCheckIn({
    required String memberId,
    String? memberMembershipId,
    String? checkedInBy,
    String? notes,
  }) async {
    if (ref.read(viewingAllBranchesProvider)) return null;

    final branchId = ref.read(effectiveBranchIdForWriteProvider);
    if (branchId == null) return null;

    final result = await _repository.checkIn(
      memberId: memberId,
      branchId: branchId,
      method: CheckInMethod.manual,
      checkedInBy: checkedInBy,
      memberMembershipId: memberMembershipId,
      notes: notes,
    );

    return result.fold((failure) => null, (checkIn) {
      refresh();
      return checkIn;
    });
  }

  /// Records a check-in using a card value (RFID/barcode).
  ///
  /// Looks up the card in `memberCards` collection first, then falls back
  /// to searching the legacy `rfidCardId` field on members for backward
  /// compatibility.
  Future<CardCheckInResult> cardCheckIn({required String cardValue}) async {
    if (ref.read(viewingAllBranchesProvider)) {
      return const CardCheckInNoBranch();
    }

    final branchId = ref.read(effectiveBranchIdForWriteProvider);
    if (branchId == null) return const CardCheckInNoBranch();

    // 1. Look up card in memberCards collection
    final cardRepo = ref.read(memberCardRepositoryProvider);
    final cardResult = await cardRepo.findByCardValue(cardValue);

    String? memberId;
    String? memberName;

    final card = cardResult.fold((_) => null, (card) => card);

    if (card != null) {
      memberId = card.memberId;
      memberName = card.memberName;
    } else {
      // 2. Fallback: search by legacy rfidCardId on member
      final memberRepo = ref.read(memberRepositoryProvider);
      final searchResult = await memberRepo.search(
        cardValue,
        fields: ['rfidCardId'],
      );
      final members = searchResult.fold((_) => <Member>[], (m) => m);
      if (members.isNotEmpty) {
        final member = members.first;
        memberId = member.id;
        memberName = member.name;
      }
    }

    if (memberId == null) return const CardCheckInCardNotFound();

    final resolvedName = memberName ?? 'Member';

    // 3. Check for active membership valid at this branch
    final mmRepo = ref.read(memberMembershipRepositoryProvider);
    final mmResult = await mmRepo.fetchActive(memberId);
    final activeMemberships = mmResult.fold(
      (_) => <MemberMembership>[],
      (m) => m,
    );

    if (activeMemberships.isEmpty) {
      return CardCheckInNoActiveMembership(memberName: resolvedName);
    }

    final validHere = activeMemberships
        .where((m) => m.isValidAtBranch(branchId))
        .toList();
    if (validHere.isEmpty) {
      return CardCheckInMembershipNotValidAtBranch(memberName: resolvedName);
    }

    final activeMembership = validHere.first;

    // 4. Create check-in
    final result = await _repository.checkIn(
      memberId: memberId,
      branchId: branchId,
      method: CheckInMethod.rfid,
      memberMembershipId: activeMembership.id,
    );

    return result.fold((failure) => const CardCheckInFailed(), (checkIn) {
      refresh();
      return CardCheckInSuccess(
        checkIn: checkIn,
        memberName: resolvedName,
        membershipName: activeMembership.membershipName,
        membershipEndDate: activeMembership.endDate,
        membershipDaysRemaining: activeMembership.daysRemaining,
      );
    });
  }
}
