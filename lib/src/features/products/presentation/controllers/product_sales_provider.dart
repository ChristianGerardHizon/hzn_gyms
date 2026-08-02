import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../pos/data/repositories/sales_repository.dart';
import '../../../pos/domain/product_sale_line.dart';

part 'product_sales_provider.g.dart';

/// Provider for fetching a product's recent sales history.
@riverpod
Future<List<ProductSaleLine>> productSales(Ref ref, String productId) async {
  final repository = ref.read(salesRepositoryProvider);
  final result = await repository.getSaleItemsByProduct(productId);

  return result.fold(
    (failure) => [],
    (lines) => lines,
  );
}
