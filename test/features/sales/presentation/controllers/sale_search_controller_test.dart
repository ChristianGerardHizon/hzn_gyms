import 'package:hzn_gyms/src/features/sales/domain/sale_status_filter.dart';
import 'package:hzn_gyms/src/features/sales/presentation/controllers/sale_search_controller.dart';
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

  group('SaleStatusFilters', () {
    test('reset restores default statuses after toggling', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(saleStatusFiltersProvider.notifier);
      notifier.toggleStatus('voided');

      expect(
        container.read(saleStatusFiltersProvider),
        {'paid', 'awaitingPayment'},
      );

      notifier.reset();

      expect(
        container.read(saleStatusFiltersProvider),
        defaultSaleStatusFilters,
      );
    });

    test('toggleStatus prevents removing the last selected status', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(saleStatusFiltersProvider.notifier);
      notifier.toggleStatus('paid');
      notifier.toggleStatus('voided');
      notifier.toggleStatus('awaitingPayment');

      expect(container.read(saleStatusFiltersProvider), {'awaitingPayment'});
    });
  });
}
