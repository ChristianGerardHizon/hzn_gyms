import 'package:ebe_gym/src/features/memberships/domain/membership.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('Membership.compareForList', () {
    test('puts inactive plans after active plans', () {
      final plans = [
        buildMembership(id: 'inactive', name: 'A Plan', isActive: false),
        buildMembership(id: 'active', name: 'Z Plan', isActive: true),
      ]..sort(Membership.compareForList);

      expect(plans.map((p) => p.id), ['active', 'inactive']);
    });

    test('keeps favorites above non-favorites within the same active group', () {
      final plans = [
        buildMembership(id: 'active-plain', name: 'A', isActive: true),
        buildMembership(
          id: 'active-fav',
          name: 'Z',
          isActive: true,
          isFavorite: true,
        ),
        buildMembership(
          id: 'inactive-fav',
          name: 'A',
          isActive: false,
          isFavorite: true,
        ),
        buildMembership(id: 'inactive-plain', name: 'Z', isActive: false),
      ]..sort(Membership.compareForList);

      expect(plans.map((p) => p.id), [
        'active-fav',
        'active-plain',
        'inactive-fav',
        'inactive-plain',
      ]);
    });

    test('sorts by name when active and favorite status match', () {
      final plans = [
        buildMembership(id: 'b', name: 'Beta'),
        buildMembership(id: 'a', name: 'alpha'),
      ]..sort(Membership.compareForList);

      expect(plans.map((p) => p.id), ['a', 'b']);
    });
  });

  group('Membership plan type display', () {
    test('walkInBadgeLabel is Walk-in when memberNotRequired', () {
      expect(
        buildMembership(memberNotRequired: true).walkInBadgeLabel,
        'Walk-in',
      );
      expect(buildMembership().walkInBadgeLabel, isNull);
    });

    test('planTypeDisplay distinguishes walk-in from standard', () {
      expect(
        buildMembership(memberNotRequired: true).planTypeDisplay,
        'Walk-in (membership not required)',
      );
      expect(
        buildMembership().planTypeDisplay,
        'Standard (membership required)',
      );
    });
  });
}
