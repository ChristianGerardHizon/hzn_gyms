import 'package:ebe_gym/src/features/products/presentation/controllers/product_search_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductSearchFields', () {
    test('reset restores default fields after toggling extras', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(productSearchFieldsProvider.notifier);
      notifier.toggleField('description');
      notifier.toggleField('category');

      expect(container.read(productSearchFieldsProvider).length, 3);

      notifier.reset();

      expect(
        container.read(productSearchFieldsProvider),
        defaultProductSearchFields,
      );
    });
  });
}
