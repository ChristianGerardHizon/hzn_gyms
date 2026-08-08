import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/currency_format.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../../core/widgets/select_branch_for_action_dialog.dart';
import '../../../products/domain/product.dart';
import '../../../products/domain/product_status.dart';
import '../cart_controller.dart';
import '../providers/pos_product_stock_provider.dart';
import 'lot_selection_dialog.dart';
import 'out_of_stock_continue_dialog.dart';
import 'variable_price_dialog.dart';

const _cashierNeedsBranchMessage =
    'Checkout cannot be done while viewing all branches. '
    'Select a branch first.';

/// Shared POS product tile used by the flat grid and grouped cashier sections.
class CashierProductCard extends ConsumerWidget {
  const CashierProductCard({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stockStatusAsync = ref.watch(posProductStockProvider(product));

    return stockStatusAsync.when(
      loading: () => _CashierProductCardBody(
        product: product,
        theme: theme,
        stockStatus: null,
        isLoading: true,
        onTap: () {},
      ),
      error: (_, __) => _CashierProductCardBody(
        product: product,
        theme: theme,
        stockStatus: ProductStatus.noThreshold,
        onTap: () => _onProductTap(context, ref, ProductStatus.noThreshold),
      ),
      data: (stockStatus) => _CashierProductCardBody(
        product: product,
        theme: theme,
        stockStatus: stockStatus,
        onTap: () => _onProductTap(context, ref, stockStatus),
      ),
    );
  }

  Future<void> _onProductTap(
    BuildContext context,
    WidgetRef ref,
    ProductStatus? stockStatus,
  ) async {
    final allowed = await confirmOutOfStockSaleIfNeeded(
      context: context,
      ref: ref,
      product: product,
      stockStatus: stockStatus,
    );
    if (!allowed || !context.mounted) return;
    await addProductToCart(context, ref, product);
  }
}

/// Adds [product] to the cart, prompting for lot / variable price as needed.
///
/// When viewing all branches, prompts to pick a concrete branch first.
Future<void> addProductToCart(
  BuildContext context,
  WidgetRef ref,
  Product product,
) async {
  final hasBranch = await ensureWritableBranch(
    context,
    ref,
    message: _cashierNeedsBranchMessage,
  );
  if (!hasBranch || !context.mounted) return;

  final cartNotifier = ref.read(cartControllerProvider.notifier);

  if (product.trackByLot) {
    showLotSelectionDialog(
      context,
      product: product,
      onLotSelected: (lot, quantity) async {
        if (product.isVariablePrice) {
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
          final error =
              await cartNotifier.addToCartWithLot(product, lot, quantity);
          if (error != null && context.mounted) {
            showErrorSnackBar(context, message: error);
          }
        }
      },
    );
  } else if (product.isVariablePrice) {
    final price = await showVariablePriceDialog(
      context,
      productName: product.name,
    );
    if (price != null) {
      final error = await cartNotifier.addToCart(product, customPrice: price);
      if (error != null && context.mounted) {
        showErrorSnackBar(context, message: error);
      }
    }
  } else {
    final error = await cartNotifier.addToCart(product);
    if (error != null && context.mounted) {
      showErrorSnackBar(context, message: error);
    }
  }
}

class _CashierProductCardBody extends StatelessWidget {
  const _CashierProductCardBody({
    required this.product,
    required this.theme,
    required this.stockStatus,
    required this.onTap,
    this.isLoading = false,
  });

  final Product product;
  final ThemeData theme;
  final ProductStatus? stockStatus;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = stockStatus == ProductStatus.outOfStock;
    final isLowStock = stockStatus == ProductStatus.lowStock;
    final dimForStock = isOutOfStock && product.requireStock;
    final showStockChip = !isLoading && (isOutOfStock || isLowStock);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Opacity(
            opacity: dimForStock ? 0.55 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      product.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (showStockChip) ...[
                  const SizedBox(height: 6),
                  _StockChip(
                    isOutOfStock: isOutOfStock,
                    isLowStock: isLowStock,
                  ),
                ] else if (isLoading) ...[
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  product.isVariablePrice
                      ? 'Variable'
                      : product.price.toCurrency(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: product.isVariablePrice
                        ? theme.colorScheme.tertiary
                        : theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StockChip extends StatelessWidget {
  const _StockChip({
    required this.isOutOfStock,
    required this.isLowStock,
  });

  final bool isOutOfStock;
  final bool isLowStock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor =
        isOutOfStock ? theme.colorScheme.error : const Color(0xFFE65100);
    final label = isOutOfStock ? 'Out' : 'Low';
    final icon =
        isOutOfStock ? Icons.cancel_outlined : Icons.warning_amber_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: chipColor.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
