import 'package:ebe_gym/src/features/members/presentation/widgets/member_form_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shouldCreateNewMemberSale', () {
    test('defaults to creating a sale when membership is selected', () {
      expect(
        shouldCreateNewMemberSale(
          hasSelectedMembership: true,
          excludeFromSales: false,
        ),
        isTrue,
      );
    });

    test('skips sale when excludeFromSales is checked', () {
      expect(
        shouldCreateNewMemberSale(
          hasSelectedMembership: true,
          excludeFromSales: true,
        ),
        isFalse,
      );
    });

    test('skips sale when no membership is selected', () {
      expect(
        shouldCreateNewMemberSale(
          hasSelectedMembership: false,
          excludeFromSales: false,
        ),
        isFalse,
      );
      expect(
        shouldCreateNewMemberSale(
          hasSelectedMembership: false,
          excludeFromSales: true,
        ),
        isFalse,
      );
    });
  });
}
