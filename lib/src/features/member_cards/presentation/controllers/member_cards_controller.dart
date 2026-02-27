import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/member_card_repository.dart';
import '../../domain/member_card.dart';

part 'member_cards_controller.g.dart';

/// Controller for managing a member's physical ID cards.
///
/// Fetches all cards for a specific member by ID.
@riverpod
class MemberCardsController extends _$MemberCardsController {
  MemberCardRepository get _repository =>
      ref.read(memberCardRepositoryProvider);

  @override
  Future<List<MemberCard>> build(String memberId) async {
    final result = await _repository.fetchByMember(memberId);

    return result.fold(
      (failure) => throw failure,
      (cards) => cards,
    );
  }

  /// Refreshes the member's cards.
  Future<void> refresh() async {
    _repository.invalidateCache();
    state = const AsyncLoading();

    final result = await _repository.fetchByMember(memberId);

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (cards) => AsyncData(cards),
    );
  }

  /// Adds a new card for this member.
  Future<bool> addCard({
    required String cardValue,
    String? label,
    String? notes,
  }) async {
    final result = await _repository.create(
      memberId: memberId,
      cardValue: cardValue,
      label: label,
      notes: notes,
    );
    return result.fold(
      (failure) => false,
      (_) {
        refresh();
        return true;
      },
    );
  }

  /// Deactivates a card.
  Future<bool> deactivateCard(String cardId) async {
    final result =
        await _repository.updateStatus(cardId, MemberCardStatus.deactivated);
    return result.fold(
      (failure) => false,
      (_) {
        refresh();
        return true;
      },
    );
  }

  /// Reports a card as lost.
  Future<bool> reportLost(String cardId) async {
    final result =
        await _repository.updateStatus(cardId, MemberCardStatus.lost);
    return result.fold(
      (failure) => false,
      (_) {
        refresh();
        return true;
      },
    );
  }

  /// Deletes a card.
  Future<bool> deleteCard(String cardId) async {
    final result = await _repository.delete(cardId);
    return result.fold(
      (failure) => false,
      (_) {
        refresh();
        return true;
      },
    );
  }
}
