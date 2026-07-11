import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../pos/data/repositories/sales_repository.dart';
import '../../../pos/domain/sale.dart';

part 'member_sales_provider.g.dart';

/// Provider for fetching a specific member's sales history.
@riverpod
Future<List<Sale>> memberSales(Ref ref, String memberId) async {
  final repository = ref.read(salesRepositoryProvider);
  final result = await repository.getSalesByCustomer(memberId);

  return result.fold(
    (failure) => [],
    (sales) => sales,
  );
}
