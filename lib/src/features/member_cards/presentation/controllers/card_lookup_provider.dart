import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/member_card_repository.dart';
import '../../domain/member_card.dart';

part 'card_lookup_provider.g.dart';

/// Looks up an active member card by its card value.
///
/// Used by the check-in flow to resolve a scanned card to a member.
@riverpod
Future<MemberCard?> cardLookup(Ref ref, String cardValue) async {
  final repository = ref.read(memberCardRepositoryProvider);
  final result = await repository.findByCardValue(cardValue);
  return result.fold(
    (_) => null,
    (card) => card,
  );
}
