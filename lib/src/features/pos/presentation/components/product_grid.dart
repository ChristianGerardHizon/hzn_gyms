import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../products/data/repositories/product_repository.dart';
import '../../../products/domain/product.dart';
import '../../../products/domain/product_status.dart';
import '../cart_controller.dart';
import '../providers/pos_product_stock_provider.dart';
import 'lot_selection_dialog.dart';
import 'variable_price_dialog.dart';

class ProductGrid extends ConsumerWidget {
  const ProductGrid({
    super.key,
    this.searchQuery = '',
  });

  final String searchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return FutureBuilder(
      future: _fetchProducts(ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return ErrorState.fromError(snapshot.error!, compact: true);
        }

        final result = snapshot.data;
        if (result == null) {
          return const Center(child: Text('No products loaded'));
        }

        return result.fold(
          (failure) => ErrorState.fromError(failure, compact: true),
          (products) {
            if (products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      searchQuery.isEmpty
                          ? 'No products found'
                          : 'No products match "$searchQuery"',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                // Responsive columns based on available width
                // Mobile: 2 columns, Tablet: 4-5 columns, Large: 6+ columns
                final width = constraints.maxWidth;
                final crossAxisCount = width < 600
                    ? 2
                    : width < 900
                        ? 4
                        : width < 1200
                            ? 5
                            : 6;

                // Adjust aspect ratio based on column count
                // More columns = wider cards, fewer columns = taller cards
                final childAspectRatio = crossAxisCount <= 3 ? 0.9 : 1.3;

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _ProductCard(product: product);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Future<Either<Failure, List<Product>>> _fetchProducts(WidgetRef ref) async {
    final repository = ref.read(productRepositoryProvider);

    final Either<Failure, List<Product>> result;
    if (searchQuery.trim().isEmpty) {
      result = await repository.fetchAll();
    } else {
      result = await repository.search(
        searchQuery.trim(),
        fields: ['name', 'description'],
      );
    }

    // Filter to only show products that are for sale
    return result.map(
      (products) => products.where((p) => p.forSale).toList(),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stockStatusAsync = ref.watch(posProductStockProvider(product));

    return stockStatusAsync.when(
      loading: () => _buildCard(
        context,
        ref,
        theme,
        stockStatus: null,
        isLoading: true,
      ),
      error: (_, __) => _buildCard(
        context,
        ref,
        theme,
        stockStatus: ProductStatus.noThreshold,
      ),
      data: (stockStatus) => _buildCard(
        context,
        ref,
        theme,
        stockStatus: stockStatus,
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme, {
    required ProductStatus? stockStatus,
    bool isLoading = false,
  }) {
    final isOutOfStock = stockStatus == ProductStatus.outOfStock;
    final isLowStock = stockStatus == ProductStatus.lowStock;
    final isDisabled = isOutOfStock && product.requireStock;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isDisabled
            ? () => _showOutOfStockMessage(context)
            : () => _handleProductTap(context, ref),
        child: Stack(
          children: [
            // Main content - compact layout with name and price only
            Opacity(
              opacity: isDisabled ? 0.5 : 1.0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.isVariablePrice
                          ? 'Variable'
                          : product.price.toCurrency(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: product.isVariablePrice
                            ? theme.colorScheme.tertiary
                            : theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Stock status badge - compact
            if (!isLoading && (isOutOfStock || isLowStock))
              Positioned(
                top: 4,
                right: 4,
                child: _StockBadge(
                  isOutOfStock: isOutOfStock,
                  isLowStock: isLowStock,
                ),
              ),

            // Loading indicator - compact
            if (isLoading)
              Positioned(
                top: 4,
                right: 4,
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleProductTap(BuildContext context, WidgetRef ref) {
    // Capture notifier before async operation to avoid using ref after widget unmount
    final cartNotifier = ref.read(cartControllerProvider.notifier);

    if (product.trackByLot) {
      // Show lot selection sheet for lot-tracked products
      showLotSelectionDialog(
        context,
        product: product,
        onLotSelected: (lot, quantity) async {
          if (product.isVariablePrice) {
            // Variable-price + lot-tracked: prompt for price after lot selection
            final price = await showVariablePriceDialog(
              context,
              productName: product.name,
            );
            if (price != null) {
              final error = await cartNotifier.addToCartWithLot(
                product,
                lot,
                quantity,
                customPrice: price,
              );
              if (error != null && context.mounted) {
                showErrorSnackBar(context, message: error);
              }
            }
          } else {
            final error = await cartNotifier.addToCartWithLot(
              product,
              lot,
              quantity,
            );
            if (error != null && context.mounted) {
              showErrorSnackBar(context, message: error);
            }
          }
        },
      );
    } else if (product.isVariablePrice) {
      // Variable-price product: prompt for price before adding to cart
      showVariablePriceDialog(
        context,
        productName: product.name,
      ).then((price) async {
        if (price != null) {
          final error =
              await cartNotifier.addToCart(product, customPrice: price);
          if (error != null && context.mounted) {
            showErrorSnackBar(context, message: error);
          }
        }
      });
    } else {
      // Regular add to cart for non-lot products
      cartNotifier.addToCart(product).then((error) {
        if (error != null && context.mounted) {
          showErrorSnackBar(context, message: error);
        }
      });
    }
  }

  void _showOutOfStockMessage(BuildContext context) {
    showErrorSnackBar(
      context,
      message: '${product.name} is out of stock',
      duration: const Duration(seconds: 2),
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({
    required this.isOutOfStock,
    required this.isLowStock,
  });

  final bool isOutOfStock;
  final bool isLowStock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color color;
    final IconData icon;

    if (isOutOfStock) {
      color = theme.colorScheme.error;
      icon = Icons.cancel_outlined;
    } else if (isLowStock) {
      color = Colors.orange;
      icon = Icons.warning_amber_outlined;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 12,
      ),
    );
  }
}
