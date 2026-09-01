import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/product_status.dart';

part 'product_stock_status_filter_controller.g.dart';

/// Selected stock status for filtering the Products list.
///
/// `null` means All (no stock-status filter).
@Riverpod(keepAlive: true)
class ProductStockStatusFilter extends _$ProductStockStatusFilter {
  @override
  ProductStatus? build() => null;

  /// Sets the stock-status filter, or clears it when [status] is null.
  void setStatus(ProductStatus? status) {
    if (state == status) return;
    state = status;
  }

  /// Clears the filter (All statuses).
  void clear() => setStatus(null);
}
