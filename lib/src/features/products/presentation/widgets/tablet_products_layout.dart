import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/state/error_state.dart';
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
      error: (error, stack) => ErrorState.fromError(
        error,
        onRetry: () => productsController.refresh(),
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
