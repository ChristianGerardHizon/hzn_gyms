import 'package:ebe_gym/src/core/foundation/failure.dart';
import 'package:ebe_gym/src/features/member_cards/data/repositories/member_card_repository.dart';
import 'package:ebe_gym/src/features/member_cards/domain/member_card.dart';
import 'package:ebe_gym/src/features/member_cards/presentation/controllers/member_cards_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockMemberCardRepository repo;
  late ProviderContainer container;

  const memberId = 'member-1';
  const cardId = 'card-1';

  setUpAll(() {
    registerFallbackValue(MemberCardStatus.active);
  });

  setUp(() {
    repo = MockMemberCardRepository();
    when(() => repo.invalidateCache()).thenReturn(null);
    when(() => repo.fetchByMember(memberId)).thenAnswer(
      (_) async => right(<MemberCard>[]),
    );

    container = ProviderContainer(
      overrides: [
        memberCardRepositoryProvider.overrideWithValue(repo),
      ],
    );
    container.listen(memberCardsControllerProvider(memberId), (_, __) {});
  });

  tearDown(() {
    container.dispose();
  });

  Future<MemberCardsController> readyController() async {
    await container.read(memberCardsControllerProvider(memberId).future);
    return container.read(memberCardsControllerProvider(memberId).notifier);
  }

  group('reactivateCard', () {
    test('returns true and refreshes on success', () async {
      final activeCard = buildMemberCard(
        id: cardId,
        memberId: memberId,
        status: MemberCardStatus.active,
      );
      when(() => repo.updateStatus(cardId, MemberCardStatus.active))
          .thenAnswer((_) async => right(activeCard));
      when(() => repo.fetchByMember(memberId)).thenAnswer(
        (_) async => right([activeCard]),
      );

      final controller = await readyController();
      final success = await controller.reactivateCard(cardId);

      expect(success, isTrue);
      verify(() => repo.updateStatus(cardId, MemberCardStatus.active))
          .called(1);
      await container.read(memberCardsControllerProvider(memberId).future);
      final list = container.read(memberCardsControllerProvider(memberId));
      expect(list.value, [activeCard]);
    });

    test('returns false on failure', () async {
      when(() => repo.updateStatus(cardId, MemberCardStatus.active))
          .thenAnswer(
        (_) async => left(const GenericFailure('update failed')),
      );

      final controller = await readyController();
      final success = await controller.reactivateCard(cardId);

      expect(success, isFalse);
      verify(() => repo.updateStatus(cardId, MemberCardStatus.active))
          .called(1);
    });
  });
}
