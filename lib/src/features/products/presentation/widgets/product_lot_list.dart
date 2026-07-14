import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/state/error_state.dart';
import '../../domain/product_lot.dart';
import '../controllers/product_lots_controller.dart';
import 'dialogs/create_lot_dialog.dart';
import 'dialogs/edit_lot_dialog.dart';
import 'dialogs/stock_adjustment_dialog.dart';

/// Widget for displaying a list of product lots.
class ProductLotList extends ConsumerWidget {
  const ProductLotList({
    super.key,
    required this.productId,
  });

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lotsAsync = ref.watch(productLotsControllerProvider(productId));

    return lotsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ErrorState.fromError(
        error,
        compact: true,
        onRetry: () => ref
            .read(productLotsControllerProvider(productId).notifier)
            .refresh(),
      ),
      data: (lots) {
        if (lots.isEmpty) {
          return _EmptyLotState(productId: productId);
        }

        return _LotListContent(
          productId: productId,
          lots: lots,
        );
      },
    );
  }
}

class _EmptyLotState extends StatelessWidget {
  const _EmptyLotState({required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No Lots',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add lots to track inventory by batch/lot number.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => showCreateLotDialog(context, productId),
              icon: const Icon(Icons.add),
              label: const Text('Add Lot'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LotListContent extends ConsumerWidget {
  const _LotListContent({
    required this.productId,
    required this.lots,
  });

  final String productId;
  final List<ProductLot> lots;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calculate totals
    final totalQuantity = lots.fold<num>(0, (sum, lot) => sum + lot.quantity);
    final expiredCount = lots.where((l) => l.isExpired).length;
    final expiringSoonCount = lots.where((l) => l.isNearExpiration).length;

    return Column(
      children: [
        // Summary header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.inventory,
                  label: 'Total Qty',
                  value: totalQuantity.toStringAsFixed(0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.layers,
                  label: 'Lots',
                  value: lots.length.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.schedule,
                  label: 'Expiring',
                  value: expiringSoonCount.toString(),
                  isWarningOrange: expiringSoonCount > 0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.warning_amber,
                  label: 'Expired',
                  value: expiredCount.toString(),
                  isWarning: expiredCount > 0,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Lot list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: lots.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final lot = lots[index];
              return _LotListTile(
                lot: lot,
                onAdjust: () => showLotStockAdjustmentDialog(context, lot),
                onEdit: () => showEditLotDialog(context, lot),
                onDelete: () => _confirmDelete(context, ref, lot),
              );
            },
          ),
        ),

        // Add button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => showCreateLotDialog(context, productId),
              icon: const Icon(Icons.add),
              label: const Text('Add Lot'),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ProductLot lot,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Lot'),
        content: Text('Are you sure you want to delete lot "${lot.lotNumber}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(productLotsControllerProvider(productId).notifier)
          .deleteLot(lot.id);
    }
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    this.isWarning = false,
    this.isWarningOrange = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isWarning;
  final bool isWarningOrange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isWarning
        ? theme.colorScheme.error
        : isWarningOrange
            ? Colors.orange
            : theme.colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LotListTile extends StatelessWidget {
  const _LotListTile({
    required this.lot,
    required this.onAdjust,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductLot lot;
  final VoidCallback onAdjust;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd();

    // Determine status colors
    Color avatarBackground;
    Color iconColor;
    IconData icon;

    if (lot.isExpired) {
      avatarBackground = theme.colorScheme.errorContainer;
      iconColor = theme.colorScheme.error;
      icon = Icons.warning;
    } else if (lot.isNearExpiration) {
      avatarBackground = Colors.orange.shade100;
      iconColor = Colors.orange.shade700;
      icon = Icons.schedule;
    } else if (lot.isOutOfStock) {
      avatarBackground = theme.colorScheme.surfaceContainerHighest;
      iconColor = theme.colorScheme.outline;
      icon = Icons.inventory_2;
    } else {
      avatarBackground = theme.colorScheme.primaryContainer;
      iconColor = theme.colorScheme.primary;
      icon = Icons.inventory;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: avatarBackground,
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        lot.lotNumber,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          decoration: lot.isExpired ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Qty: ${lot.quantityDisplay}'),
          if (lot.expiration != null)
            Text(
              lot.isExpired
                  ? 'Expired: ${dateFormat.format(lot.expiration!)}'
                  : lot.isNearExpiration
                      ? 'Expires in ${lot.daysUntilExpiration} days'
                      : 'Exp: ${dateFormat.format(lot.expiration!)}',
              style: TextStyle(
                color: lot.isExpired
                    ? theme.colorScheme.error
                    : lot.isNearExpiration
                        ? Colors.orange.shade700
                        : null,
                fontWeight: lot.isNearExpiration ? FontWeight.w500 : null,
              ),
            ),
          if (lot.notes != null && lot.notes!.isNotEmpty)
            Text(
              lot.notes!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      isThreeLine: lot.expiration != null ||
          (lot.notes != null && lot.notes!.isNotEmpty),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'adjust':
              onAdjust();
              break;
            case 'edit':
              onEdit();
              break;
            case 'delete':
              onDelete();
              break;
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'adjust',
            child: Row(
              children: [
                Icon(Icons.tune),
                SizedBox(width: 8),
                Text('Adjust Stock'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit),
                SizedBox(width: 8),
                Text('Edit'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
