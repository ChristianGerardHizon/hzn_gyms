import 'package:kylie_gym/src/features/sales/domain/sale_status_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('saleStatusesForFilterOption', () {
    test('expands paid and awaiting payment groups', () {
      expect(saleStatusesForFilterOption('paid'), ['paid', 'completed']);
      expect(
        saleStatusesForFilterOption('awaitingPayment'),
        ['awaitingPayment', 'pending'],
      );
      expect(saleStatusesForFilterOption('voided'), ['voided']);
    });
  });

  group('buildSaleStatusFilter', () {
    test('returns null when all default statuses are selected', () {
      expect(
        buildSaleStatusFilter(Set<String>.from(defaultSaleStatusFilters)),
        isNull,
      );
    });

    test('returns null for empty selection', () {
      expect(buildSaleStatusFilter({}), isNull);
    });

    test('builds OR filter for a narrowed selection', () {
      expect(
        buildSaleStatusFilter({'paid'}),
        '(status = "paid" || status = "completed")',
      );
      expect(
        buildSaleStatusFilter({'voided'}),
        'status = "voided"',
      );
      expect(
        buildSaleStatusFilter({'paid', 'voided'}),
        '(status = "paid" || status = "completed" || status = "voided")',
      );
    });
  });

  group('combineSaleListFilters', () {
    test('joins non-empty parts with &&', () {
      expect(
        combineSaleListFilters(['branch = "a"', null, ' status = "paid" ']),
        'branch = "a" && status = "paid"',
      );
      expect(combineSaleListFilters([null, '', '  ']), isNull);
    });
  });
}
