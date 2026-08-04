import 'package:ebe_gym/src/core/utils/date_utils.dart';
import 'package:ebe_gym/src/features/memberships/presentation/widgets/membership_form_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('selectsAllBranches', () {
    test('returns false when there are no available branches', () {
      expect(selectsAllBranches(['a'], []), isFalse);
      expect(selectsAllBranches([], []), isFalse);
    });

    test('returns false when any branch is missing', () {
      expect(selectsAllBranches(['a'], ['a', 'b']), isFalse);
      expect(selectsAllBranches(['a', 'c'], ['a', 'b']), isFalse);
      expect(selectsAllBranches([], ['a']), isFalse);
    });

    test('returns true when every available branch is selected', () {
      expect(selectsAllBranches(['a', 'b'], ['a', 'b']), isTrue);
      expect(selectsAllBranches(['b', 'a'], ['a', 'b']), isTrue);
      expect(selectsAllBranches(['a'], ['a']), isTrue);
    });

    test('returns true when selection includes extras but covers all', () {
      expect(selectsAllBranches(['a', 'b', 'c'], ['a', 'b']), isTrue);
    });
  });

  group('MembershipPlanFormKind', () {
    test('isWalkInPlanKind distinguishes monthly vs walk-in', () {
      expect(isWalkInPlanKind(MembershipPlanFormKind.monthly), isFalse);
      expect(isWalkInPlanKind(MembershipPlanFormKind.walkIn), isTrue);
    });

    test('walk-in defaults are 1 day', () {
      expect(walkInDefaultDurationValue, 1);
      expect(walkInDefaultDurationUnit, MembershipDurationUnit.days);
    });
  });
}
