import 'package:ebe_gym/src/features/products/domain/product_status.dart';
import 'package:ebe_gym/src/features/products/domain/product_stock_status_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildProductStockStatusFilter', () {
    test('returns null for All and inStock', () {
      expect(buildProductStockStatusFilter(null), isNull);
      expect(buildProductStockStatusFilter(ProductStatus.inStock), isNull);
    });

    test('builds out of stock filter', () {
      expect(
        buildProductStockStatusFilter(ProductStatus.outOfStock),
        'trackStock = true && ('
        '(trackByLot = true && (quantity = null || quantity <= 0)) || '
        '(trackByLot = false && quantity != null && quantity <= 0)'
        ')',
      );
    });

    test('builds low stock filter', () {
      expect(
        buildProductStockStatusFilter(ProductStatus.lowStock),
        'trackStock = true && '
        'stockThreshold != null && '
        'quantity != null && '
        'quantity > 0 && '
        'quantity <= stockThreshold',
      );
    });

    test('builds not tracked filter', () {
      expect(
        buildProductStockStatusFilter(ProductStatus.noThreshold),
        'trackStock = false || (trackByLot = false && quantity = null)',
      );
    });
  });

  group('combineProductListFilters', () {
    test('joins non-empty parts with &&', () {
      expect(
        combineProductListFilters([
          'branch = "a"',
          null,
          ' trackStock = false ',
        ]),
        'branch = "a" && trackStock = false',
      );
      expect(combineProductListFilters([null, '', '  ']), isNull);
    });
  });
}
