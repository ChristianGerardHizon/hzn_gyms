import 'package:hzn_gyms/src/features/users/presentation/controllers/user_search_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserSearchFields', () {
    test('reset restores default fields after toggling one off', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(userSearchFieldsProvider.notifier);
      notifier.toggleField('username');

      expect(container.read(userSearchFieldsProvider), {'name'});

      notifier.reset();

      expect(
        container.read(userSearchFieldsProvider),
        defaultUserSearchFields,
      );
    });
  });
}
