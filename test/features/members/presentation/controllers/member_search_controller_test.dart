import 'package:ebe_gym/src/features/members/presentation/controllers/member_search_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MemberSearchFields', () {
    test('reset restores default fields after toggling extras', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(memberSearchFieldsProvider.notifier);
      notifier.toggleField('email');
      notifier.toggleField('mobileNumber');

      expect(container.read(memberSearchFieldsProvider), contains('email'));

      notifier.reset();

      expect(
        container.read(memberSearchFieldsProvider),
        defaultMemberSearchFields,
      );
    });
  });
}
