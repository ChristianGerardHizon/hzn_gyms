import 'product_status.dart';

/// Builds a PocketBase filter that mirrors [Product.stockStatus].
///
/// Returns `null` when [status] is null (All) or [ProductStatus.inStock]
/// (not offered as a list filter pill).
String? buildProductStockStatusFilter(ProductStatus? status) {
  return switch (status) {
    null || ProductStatus.inStock => null,
    ProductStatus.outOfStock =>
      'trackStock = true && ('
          '(trackByLot = true && (quantity = null || quantity <= 0)) || '
          '(trackByLot = false && quantity != null && quantity <= 0)'
          ')',
    ProductStatus.lowStock =>
      'trackStock = true && '
          'stockThreshold != null && '
          'quantity != null && '
          'quantity > 0 && '
          'quantity <= stockThreshold',
    ProductStatus.noThreshold =>
      'trackStock = false || (trackByLot = false && quantity = null)',
  };
}

/// Combines optional PocketBase filter fragments with `&&`.
String? combineProductListFilters(Iterable<String?> parts) {
  final nonEmpty = parts
      .whereType<String>()
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toList();
  if (nonEmpty.isEmpty) return null;
  return nonEmpty.join(' && ');
}
