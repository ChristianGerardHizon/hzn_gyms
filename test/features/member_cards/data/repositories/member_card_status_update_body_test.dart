import 'package:ebe_gym/src/core/utils/date_utils.dart';
import 'package:ebe_gym/src/features/member_cards/data/repositories/member_card_repository.dart';
import 'package:ebe_gym/src/features/member_cards/domain/member_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('memberCardStatusUpdateBody', () {
    final now = DateTime.utc(2026, 8, 6, 9, 30);

    test('clears deactivatedAt when reactivating to active', () {
      final body = memberCardStatusUpdateBody(
        MemberCardStatus.active,
        now: now,
      );

      expect(body, {
        'status': 'active',
        'deactivatedAt': null,
      });
    });

    test('sets deactivatedAt when deactivating', () {
      final body = memberCardStatusUpdateBody(
        MemberCardStatus.deactivated,
        now: now,
      );

      expect(body, {
        'status': 'deactivated',
        'deactivatedAt': now.toUtcIso8601(),
      });
    });

    test('sets deactivatedAt when reporting lost', () {
      final body = memberCardStatusUpdateBody(
        MemberCardStatus.lost,
        now: now,
      );

      expect(body, {
        'status': 'lost',
        'deactivatedAt': now.toUtcIso8601(),
      });
    });
  });
}
