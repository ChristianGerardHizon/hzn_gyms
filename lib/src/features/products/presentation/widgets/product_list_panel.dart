import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/foundation/sort_config.dart';
import '../../../../core/hooks/use_debounced_callback.dart';
import '../../../../core/hooks/use_infinite_scroll.dart';
import '../../../../core/i18n/strings.g.dart';
import '../../../../core/routing/org_scoped_navigation.dart';
import '../../../../core/routing/routes/products.routes.dart';
import '../../../../core/utils/list_search_field.dart';
import '../../../../core/widgets/end_of_list_indicator.dart';
import '../../../../core/widgets/sort/sort_dialog.dart';
import '../../domain/product.dart';
import '../../domain/product_status.dart';
import '../controllers/paginated_products_controller.dart';
import '../controllers/product_search_controller.dart';
import '../controllers/product_sort_controller.dart';
import '../controllers/product_stock_status_filter_controller.dart';
import 'product_image.dart';
import 'product_stock_badge.dart';
import 'dialogs/create_product_dialog.dart';
import 'dialogs/product_search_fields_dialog.dart';

/// Product list panel with search header and infinite scroll.
///
/// Used in both mobile list page and tablet two-pane layout.
class ProductListPanel extends HookConsumerWidget {
  const ProductListPanel({
    super.key,
    required this.products,
    required this.totalCount,
    required this.hasMore,
    required this.isLoadingMore,
  });

  final List<Product> products;
  final int totalCount;
  final bool hasMore;
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = Translations.of(context);

    // Watch providers
    final searchFields = ref.watch(productSearchFieldsProvider);
    final activeFieldCount = searchFields.length;
    final paginatedController =
        ref.read(paginatedProductsControllerProvider.notifier);
    final sortConfig = ref.watch(productSortControllerProvider);
    final stockStatusFilter = ref.watch(productStockStatusFilterProvider);

    // Seed from keepAlive controller so tab remount restores input + clear.
    final initialQuery =
        initialSearchFieldText(paginatedController.currentSearchQuery);
    final searchController = useTextEditingController(text: initialQuery);
    final searchText = useState(initialQuery);

    // Get selected product ID from current route
    final routerState = GoRouterState.of(context);
    final selectedProductId = routerState.pathParameters['id'];

    void performSearch() {
      final query = searchController.text.trim();
      if (query.isEmpty) {
        if (paginatedController.isSearchActive) {
          paginatedController.clearSearch();
        }
        return;
      }

      final fields = ref.read(productSearchFieldsProvider).toList();
      paginatedController.search(query, fields: fields);
    }

    final debouncedSearch = useDebouncedCallback<String>((_) => performSearch());

    void onSearchTextChanged(String text) {
      searchText.value = text;
      debouncedSearch.cancel();
      if (text.trim().isEmpty) {
        if (paginatedController.isSearchActive) {
          paginatedController.clearSearch();
        }
        return;
      }
      debouncedSearch.call(text);
    }

    // Infinite scroll hook
    final scrollController = useInfiniteScroll(
      onLoadMore: () => paginatedController.loadMore(),
      hasMore: hasMore,
      isLoading: isLoadingMore,
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreateProductDialog(context),
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                Text(t.navigation.products, style: theme.textTheme.titleLarge),
                const Spacer(),
                Text(
                  '$totalCount total',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _SearchInput(
              controller: searchController,
              fieldCount: activeFieldCount,
              sortConfig: sortConfig,
              onSearch: performSearch,
              onTextChanged: onSearchTextChanged,
              showClear: shouldShowSearchClear(
                searchText: searchText.value,
                isSearchActive: paginatedController.isSearchActive,
              ),
              onSortPressed: () => _showSortDialog(context, ref),
            ),
          ),

          // Stock status filter
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: stockStatusFilter == null,
                    onSelected: (_) {
                      ref
                          .read(productStockStatusFilterProvider.notifier)
                          .clear();
                    },
                  ),
                  for (final status in const [
                    ProductStatus.outOfStock,
                    ProductStatus.lowStock,
                    ProductStatus.noThreshold,
                  ]) ...[
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(status.displayName),
                      selected: stockStatusFilter == status,
                      onSelected: (_) {
                        ref
                            .read(productStockStatusFilterProvider.notifier)
                            .setStatus(status);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Product list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => paginatedController.refresh(),
              child: ListView.builder(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                // +1 for the end indicator
                itemCount: products.length + 1,
                itemBuilder: (context, index) {
                  // Last item is the end indicator
                  if (index == products.length) {
                    return EndOfListIndicator(
                      isLoadingMore: isLoadingMore,
                      hasReachedEnd: !hasMore,
                    );
                  }

                  final product = products[index];
                  final isSelected = product.id == selectedProductId;

                  return ListTile(
                    leading: ProductImage(product: product),
                    title: Text(
                      product.name,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Text(product.priceDisplay),
                        if (product.categoryName != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '• ${product.categoryName}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ProductStockBadge(
                          status: product.stockStatus,
                          showLabel: false,
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right),
                        ],
                      ],
                    ),
                    selected: isSelected,
                    selectedTileColor: theme.colorScheme.primaryContainer,
                    onTap: () => ProductDetailRoute(id: product.id).goScoped(context),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showSortDialog(BuildContext context, WidgetRef ref) {
  final t = Translations.of(context);
  final currentSort = ref.read(productSortControllerProvider);

  // Build localized field labels
  final localizedFields = productSortableFields.map((field) {
    final label = switch (field.key) {
      'name' => t.fields.name,
      'price' => t.sort.price,
      'quantity' => t.sort.stock,
      'created' => t.sort.dateAdded,
      'updated' => t.sort.lastUpdated,
      'expiration' => t.sort.expiration,
      _ => field.label,
    };
    return (key: field.key, label: label);
  }).toList();

  showSortDialog(
    context: context,
    title: t.sort.sortBy,
    fields: localizedFields,
    currentSort: currentSort,
    defaultSort: productDefaultSort,
    onSortChanged: (config) {
      ref.read(productSortControllerProvider.notifier).setSort(config);
    },
  );
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    required this.fieldCount,
    required this.sortConfig,
    required this.onSearch,
    required this.onTextChanged,
    required this.showClear,
    required this.onSortPressed,
  });

  final TextEditingController controller;
  final int fieldCount;
  final SortConfig sortConfig;
  final VoidCallback onSearch;
  final ValueChanged<String> onTextChanged;
  final bool showClear;
  final VoidCallback onSortPressed;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onTextChanged,
            onSubmitted: (_) => onSearch(),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: '${t.common.search}...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: showClear
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                        onTextChanged('');
                      },
                      tooltip: t.common.cancel,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
              filled: true,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          icon: Icon(
            sortConfig.descending ? Icons.arrow_downward : Icons.arrow_upward,
          ),
          onPressed: onSortPressed,
          tooltip: t.common.sort,
        ),
        const SizedBox(width: 8),
        Badge(
          isLabelVisible: fieldCount > 1,
          label: Text('$fieldCount'),
          child: IconButton.filledTonal(
            icon: const Icon(Icons.tune),
            onPressed: () => showProductSearchFieldsDialog(context),
            tooltip: t.common.filter,
          ),
        ),
      ],
    );
  }
}
