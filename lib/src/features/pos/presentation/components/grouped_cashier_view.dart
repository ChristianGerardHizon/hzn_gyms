import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/currency_format.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../products/domain/product.dart';
import '../../../products/domain/product_status.dart';
import '../../domain/pos_group.dart';
import '../../domain/pos_group_item.dart';
import '../cart_controller.dart';
import '../providers/pos_product_stock_provider.dart';
import 'lot_selection_dialog.dart';
import 'variable_price_dialog.dart';

/// Displays POS groups as scrollable sections with sticky headers.
///
/// Each group becomes a section with a header and a grid of product cards.
/// Falls back gracefully if groups are empty.
class GroupedCashierView extends StatelessWidget {
  const GroupedCashierView({
    super.key,
    required this.groups,
  });

  final List<PosGroup> groups;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return const Center(child: Text('No groups configured'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width < 400
            ? 3
            : width < 600
                ? 4
                : width < 900
                    ? 5
                    : 6;

        // Adjust aspect ratio based on column count
        // More columns = wider cards, fewer columns = taller cards
        final childAspectRatio = crossAxisCount <= 3 ? 0.9 : 1.3;

        return CustomScrollView(
          slivers: [
            for (final group in groups) ...[
              // Sticky section header
              SliverToBoxAdapter(
                child: _GroupHeader(group: group),
              ),
              // Grid of items
              if (group.items.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 24),
                    child: Center(
                      child: Text(
                        'No items in this group',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(8),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: childAspectRatio,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = group.items[index];
                        return _GroupItemCard(item: item);
                      },
                      childCount: group.items.length,
                    ),
                  ),
                ),
            ],
            // Bottom padding for FAB
            const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
          ],
        );
      },
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.group});

  final PosGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Icon(
            Icons.dashboard_customize,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            group.name,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '(${group.items.length})',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

/// A card that renders a product from a group item.
///
/// Non-product items are skipped (renders as [SizedBox.shrink]).
class _GroupItemCard extends ConsumerWidget {
  const _GroupItemCard({required this.item});

  final PosGroupItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (item.isProduct && item.product != null) {
      return _ProductGroupCard(product: item.product!);
    }
    return const SizedBox.shrink();
  }
}

/// Product card within a group - reuses the same tap logic as ProductGrid.
class _ProductGroupCard extends ConsumerWidget {
  const _ProductGroupCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stockStatusAsync = ref.watch(posProductStockProvider(product));

    return stockStatusAsync.when(
      loading: () => _buildCard(context, ref, theme,
          stockStatus: null, isLoading: true),
      error: (_, __) => _buildCard(context, ref, theme,
          stockStatus: ProductStatus.noThreshold),
      data: (stockStatus) =>
          _buildCard(context, ref, theme, stockStatus: stockStatus),
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
            ? () => showErrorSnackBar(context,
                message: '${product.name} is out of stock',
                duration: const Duration(seconds: 2))
            : () => _handleProductTap(context, ref),
        child: Stack(
          children: [
            Opacity(
              opacity: isDisabled ? 0.5 : 1.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
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
            if (!isLoading && (isOutOfStock || isLowStock))
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: (isOutOfStock
                            ? theme.colorScheme.error
                            : Colors.orange)
                        .withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    isOutOfStock
                        ? Icons.cancel_outlined
                        : Icons.warning_amber_outlined,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
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
    final cartNotifier = ref.read(cartControllerProvider.notifier);

    if (product.trackByLot) {
      showLotSelectionDialog(
        context,
        product: product,
        onLotSelected: (lot, quantity) {
          if (product.isVariablePrice) {
            showVariablePriceDialog(
              context,
              productName: product.name,
            ).then((price) {
              if (price != null) {
                cartNotifier.addToCartWithLot(product, lot, quantity,
                    customPrice: price);
              }
            });
          } else {
            cartNotifier.addToCartWithLot(product, lot, quantity);
          }
        },
      );
    } else if (product.isVariablePrice) {
      showVariablePriceDialog(
        context,
        productName: product.name,
      ).then((price) {
        if (price != null) {
          cartNotifier.addToCart(product, customPrice: price);
        }
      });
    } else {
      cartNotifier.addToCart(product);
    }
  }
}
