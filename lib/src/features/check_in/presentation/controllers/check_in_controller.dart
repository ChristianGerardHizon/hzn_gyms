import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../member_cards/data/repositories/member_card_repository.dart';
import '../../../members/data/repositories/member_repository.dart';
import '../../../memberships/data/repositories/member_membership_repository.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../data/repositories/check_in_repository.dart';
import '../../domain/check_in.dart';

part 'check_in_controller.g.dart';

/// Controller for performing check-ins and managing today's check-in list.
@Riverpod(keepAlive: true)
class CheckInController extends _$CheckInController {
  CheckInRepository get _repository => ref.read(checkInRepositoryProvider);

  @override
  Future<List<CheckIn>> build() async {
    final branchId = ref.watch(currentBranchIdProvider);
    if (branchId == null) return [];

    final result = await _repository.fetchTodaysCheckIns(branchId);

    return result.fold(
      (failure) => throw failure,
      (checkIns) => checkIns,
    );
  }

  /// Refreshes today's check-in list.
  Future<void> refresh() async {
    _repository.invalidateCache();
    state = const AsyncLoading();

    final branchId = ref.read(currentBranchIdProvider);
    if (branchId == null) {
      state = const AsyncData([]);
      return;
    }

    final result = await _repository.fetchTodaysCheckIns(branchId);

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (checkIns) => AsyncData(checkIns),
    );
  }

  /// Records a manual check-in for a member.
  Future<CheckIn?> manualCheckIn({
    required String memberId,
    String? memberMembershipId,
    String? checkedInBy,
    String? notes,
  }) async {
    final branchId = ref.read(currentBranchIdProvider);
    if (branchId == null) return null;

    final result = await _repository.checkIn(
      memberId: memberId,
      branchId: branchId,
      method: CheckInMethod.manual,
      checkedInBy: checkedInBy,
      memberMembershipId: memberMembershipId,
      notes: notes,
    );

    return result.fold(
      (failure) => null,
      (checkIn) {
        refresh();
        return checkIn;
      },
    );
  }

  /// Records a check-in using a card value (RFID/barcode).
  ///
  /// Looks up the card in `memberCards` collection first, then falls back
  /// to searching the legacy `rfidCardId` field on members for backward
  /// compatibility.
  ///
  /// Returns a record containing the [CheckIn] and member name on success,
  /// or `null` with an error message on failure.
  Future<({CheckIn checkIn, String memberName})?> cardCheckIn({
    required String cardValue,
  }) async {
    final branchId = ref.read(currentBranchIdProvider);
    if (branchId == null) return null;

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
      final searchResult =
          await memberRepo.search(cardValue, fields: ['rfidCardId']);
      final members = searchResult.fold((_) => <dynamic>[], (m) => m);
      if (members.isNotEmpty) {
        final member = members.first;
        memberId = member.id;
        memberName = member.name;
      }
    }

    if (memberId == null) return null;

    // 3. Check for active membership
    final mmRepo = ref.read(memberMembershipRepositoryProvider);
    final mmResult = await mmRepo.fetchActive(memberId);
    final activeMemberships = mmResult.fold((_) => <dynamic>[], (m) => m);

    if (activeMemberships.isEmpty) return null;

    final activeMembership = activeMemberships.first;

    // 4. Create check-in
    final result = await _repository.checkIn(
      memberId: memberId,
      branchId: branchId,
      method: CheckInMethod.rfid,
      memberMembershipId: activeMembership.id,
    );

    return result.fold(
      (failure) => null,
      (checkIn) {
        refresh();
        return (checkIn: checkIn, memberName: memberName ?? 'Member');
      },
    );
  }
}
