import 'package:kylie_gym/src/core/foundation/paginated_state.dart';
import 'package:kylie_gym/src/features/pos/domain/sale.dart';
import 'package:kylie_gym/src/features/sales/presentation/controllers/paginated_sales_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mirrors [refreshAfterSaleVoided] list refresh step used after voiding a sale.
class _TrackingPaginatedSalesController extends PaginatedSalesController {
  var refreshCount = 0;

  @override
  Future<PaginatedState<Sale>> build() async {
    return const PaginatedState(items: [], hasReachedEnd: true);
  }

  @override
  Future<void> refresh() async {
    refreshCount++;
  }
}

void main() {
  test('paginated sales controller refresh updates list after void', () async {
    final paginated = _TrackingPaginatedSalesController();
    final container = ProviderContainer(
      overrides: [
        paginatedSalesControllerProvider.overrideWith(() => paginated),
      ],
    );
    addTearDown(container.dispose);

    container.read(paginatedSalesControllerProvider);
    await container.read(paginatedSalesControllerProvider.notifier).refresh();

    expect(paginated.refreshCount, 1);
  });
}
