import 'package:hzn_gyms/src/features/members/presentation/widgets/member_form_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shouldCreateNewMemberSale', () {
    test('defaults to creating a sale when membership is selected', () {
      expect(
        shouldCreateNewMemberSale(
          hasSelectedMembership: true,
          excludeFromSales: false,
          canExcludeFromSales: true,
        ),
        isTrue,
      );
    });

    test('skips sale when excludeFromSales is checked with permission', () {
      expect(
        shouldCreateNewMemberSale(
          hasSelectedMembership: true,
          excludeFromSales: true,
          canExcludeFromSales: true,
        ),
        isFalse,
      );
    });

    test('creates sale when checked but permission is missing', () {
      expect(
        shouldCreateNewMemberSale(
          hasSelectedMembership: true,
          excludeFromSales: true,
          canExcludeFromSales: false,
        ),
        isTrue,
      );
    });

    test('skips sale when no membership is selected', () {
      expect(
        shouldCreateNewMemberSale(
          hasSelectedMembership: false,
          excludeFromSales: false,
          canExcludeFromSales: true,
        ),
        isFalse,
      );
      expect(
        shouldCreateNewMemberSale(
          hasSelectedMembership: false,
          excludeFromSales: true,
          canExcludeFromSales: true,
        ),
        isFalse,
      );
    });
  });

  group('member form required fields', () {
    test('name validator rejects empty values', () {
      final validator = memberNameValidator();
      expect(validator(null), isNotNull);
      expect(validator(''), isNotNull);
      expect(validator('Jane Doe'), isNull);
    });

    test('mobile number validator rejects empty values', () {
      final validator = memberMobileNumberValidator();
      expect(validator(null), isNotNull);
      expect(validator(''), isNotNull);
      expect(validator('09171234567'), isNull);
    });
  });
}
