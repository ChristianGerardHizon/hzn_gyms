import 'package:ebe_gym/src/features/sales/presentation/controllers/sale_search_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SaleSearchFields', () {
    test('reset restores default fields after toggling extras', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(saleSearchFieldsProvider.notifier);
      notifier.toggleField('paymentRef');
      notifier.toggleField('notes');

      expect(container.read(saleSearchFieldsProvider), contains('paymentRef'));
      expect(container.read(saleSearchFieldsProvider), contains('notes'));

      notifier.reset();

      expect(
        container.read(saleSearchFieldsProvider),
        defaultSaleSearchFields,
      );
    });

    test('toggleField prevents removing the last selected field', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(saleSearchFieldsProvider.notifier);
      notifier.toggleField('descriptor');
      notifier.toggleField('customerName');
      notifier.toggleField('receiptNumber');

      expect(container.read(saleSearchFieldsProvider), {'receiptNumber'});
    });
  });
}
