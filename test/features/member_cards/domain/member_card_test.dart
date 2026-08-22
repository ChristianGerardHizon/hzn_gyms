import 'package:kylie_gym/src/features/member_cards/domain/member_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MemberCardStatus.displayName', () {
    test('uses Disable wording for deactivated status', () {
      expect(MemberCardStatus.active.displayName, 'Active');
      expect(MemberCardStatus.lost.displayName, 'Lost');
      expect(MemberCardStatus.deactivated.displayName, 'Disabled');
    });
  });
}
