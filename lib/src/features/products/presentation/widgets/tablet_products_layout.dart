import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../controllers/paginated_products_controller.dart';
import 'empty_product_state.dart';
import 'product_list_panel.dart';

/// Two-pane tablet layout for products.
///
/// Left pane: Product list with search
/// Right pane: Product detail from router or empty state
class TabletProductsLayout extends ConsumerWidget {
  const TabletProductsLayout({
    super.key,
    required this.detailContent,
  });

  /// The detail panel content from the router.
  final Widget detailContent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(paginatedProductsControllerProvider);
    final productsController =
        ref.read(paginatedProductsControllerProvider.notifier);

    // Get selected product ID from current route
    final routerState = GoRouterState.of(context);
    final selectedProductId = routerState.pathParameters['id'];

    return productsAsync.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text('Error: ${error.toString()}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => productsController.refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (paginatedState) => Row(
        children: [
          // List panel
          SizedBox(
            width: 320,
            child: ProductListPanel(
              products: paginatedState.items,
              totalCount: paginatedState.totalItems,
              hasMore: paginatedState.hasMore,
              isLoadingMore: paginatedState.isLoadingMore,
            ),
          ),
          const VerticalDivider(width: 1),
          // Detail panel from router
          Expanded(
            child: selectedProductId != null
                ? detailContent
                : const EmptyProductState(),
          ),
        ],
      ),
    );
  }
}
