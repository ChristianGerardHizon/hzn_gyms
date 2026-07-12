import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/dialog_close_handler.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../../../products/domain/product.dart';
import '../../../products/domain/product_lot.dart';
import '../../../products/presentation/controllers/product_lots_controller.dart';

/// Dialog for selecting a lot when adding a lot-tracked product to cart.
///
/// Displays available lots in FIFO order (oldest expiration first) and allows
/// the user to select a lot and quantity before adding to cart.
class LotSelectionDialog extends HookConsumerWidget {
  const LotSelectionDialog({
    super.key,
    required this.product,
    required this.onLotSelected,
  });

  /// The product to select a lot for.
  final Product product;

  /// Callback when a lot is selected with quantity.
  final void Function(ProductLot lot, int quantity) onLotSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final lotsAsync = ref.watch(productLotsProvider(product.id));

    // UI state
    final selectedLot = useState<ProductLot?>(null);
    final quantity = useState<int>(1);

    return DialogCloseHandler(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Lot',
                          style: theme.textTheme.titleLarge,
                      ),
                      Text(
                        product.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                FilledButton.icon(
                  onPressed: selectedLot.value != null
                      ? () {
                          onLotSelected(selectedLot.value!, quantity.value);
                          context.pop();
                        }
                      : null,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Add'),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),

          // FEFO notice
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              'Sorted by expiration (oldest first - FEFO)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          // Lots list
          Expanded(
            child: lotsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ErrorState.fromError(error, compact: true),
              data: (lots) {
                // Filter and sort lots (FEFO - oldest expiration first)
                final availableLots = _getAvailableLotsFEFO(lots);

                if (availableLots.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No lots available',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'All lots are either out of stock or expired',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Pre-select first lot (FEFO - oldest expiration) if nothing selected
                if (selectedLot.value == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    selectedLot.value = availableLots.first;
                  });
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: availableLots.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final lot = availableLots[index];
                    final isSelected = selectedLot.value?.id == lot.id;

                    return _LotTile(
                      lot: lot,
                      index: index + 1,
                      isSelected: isSelected,
                      onTap: () => selectedLot.value = lot,
                    );
                  },
                );
              },
            ),
          ),

          // Quantity selector
          if (selectedLot.value != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Card(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quantity',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              'Available: ${selectedLot.value!.quantity.toStringAsFixed(0)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Quantity controls
                      IconButton.filled(
                        onPressed: quantity.value > 1
                            ? () => quantity.value--
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          quantity.value.toString(),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton.filled(
                        onPressed:
                            quantity.value < selectedLot.value!.quantity.toInt()
                                ? () => quantity.value++
                                : null,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }

  /// Returns available lots sorted by expiration date (FEFO - First Expired, First Out).
  /// Filters out expired lots and lots with no stock.
  List<ProductLot> _getAvailableLotsFEFO(List<ProductLot> lots) {
    final available = lots
        .where((lot) => !lot.isDeleted && lot.hasStock && !lot.isExpired)
        .toList();

    // Sort by expiration date ascending (oldest first = FIFO)
    available.sort((a, b) {
      // Lots without expiration go to the end
      if (a.expiration == null && b.expiration == null) return 0;
      if (a.expiration == null) return 1;
      if (b.expiration == null) return -1;
      return a.expiration!.compareTo(b.expiration!);
    });

    return available;
  }
}

class _LotTile extends StatelessWidget {
  const _LotTile({
    required this.lot,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  final ProductLot lot;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd();

    return Card(
      elevation: isSelected ? 2 : 0,
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Index number
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Lot info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Lot #${lot.lotNumber}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (index == 1) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'FEFO',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Qty: ${lot.quantity.toStringAsFixed(0)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (lot.expiration != null) ...[
                          Icon(
                            Icons.event_outlined,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Exp: ${dateFormat.format(lot.expiration!)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ] else
                          Text(
                            'No expiration',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status badge
              _StatusBadge(lot: lot),

              // Selection indicator
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.lot});

  final ProductLot lot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (lot.isNearExpiration) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_outlined,
              size: 14,
              color: Colors.orange.shade700,
            ),
            const SizedBox(width: 4),
            Text(
              'Near Expiry',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 14,
            color: Colors.green.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            'Fresh',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows the lot selection dialog for a product.
void showLotSelectionDialog(
  BuildContext context, {
  required Product product,
  required void Function(ProductLot lot, int quantity) onLotSelected,
}) {
  showDialog(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      child: LotSelectionDialog(
        product: product,
        onLotSelected: onLotSelected,
      ),
    ),
  );
}
