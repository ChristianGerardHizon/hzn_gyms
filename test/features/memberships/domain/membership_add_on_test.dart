import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/features/memberships/domain/membership_add_on.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('MembershipAddOn', () {
    test('extendsDuration is false when durationDays is 0', () {
      expect(buildAddOn().extendsDuration, isFalse);
      expect(buildAddOn().durationDisplay, isEmpty);
    });

    test('durationDisplay formats common promo lengths', () {
      expect(buildAddOn(durationDays: 90).durationDisplay, '+3 months');
      expect(buildAddOn(durationDays: 30).durationDisplay, '+1 month');
      expect(buildAddOn(durationDays: 45).durationDisplay, '+45 days');
    });

    test('totalBonusDays sums selected add-ons', () {
      final addOns = {
        buildAddOn(id: 'a', durationDays: 90, price: 0),
        buildAddOn(id: 'b', name: 'Locker', durationDays: 0, price: 100),
        buildAddOn(id: 'c', name: 'Extra week', durationDays: 7, price: 50),
      };

      expect(MembershipAddOn.totalBonusDays(addOns), 97);
      expect(MembershipAddOn.totalBonusDays(const {}), 0);
    });
  });
}
