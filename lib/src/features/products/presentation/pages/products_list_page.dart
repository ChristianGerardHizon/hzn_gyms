import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../controllers/paginated_products_controller.dart';
import '../widgets/product_list_panel.dart';

/// Products list page for mobile view.
class ProductsListPage extends ConsumerWidget {
  const ProductsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(paginatedProductsControllerProvider);

    return productsAsync.when(
      skipLoadingOnReload: true,
      data: (state) => ProductListPanel(
        products: state.items,
        totalCount: state.totalItems,
        hasMore: state.hasMore,
        isLoadingMore: state.isLoadingMore,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text('Error loading products: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.invalidate(paginatedProductsControllerProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
