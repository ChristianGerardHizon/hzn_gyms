import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/widgets/state/error_state.dart';
import '../../../domain/product.dart';
import '../../../domain/product_adjustment.dart';
import '../../../domain/product_adjustment_type.dart';
import '../../controllers/product_adjustments_controller.dart';

/// Adjustments tab for product detail page.
///
/// Shows the history of stock adjustments for the product.
class ProductAdjustmentsTab extends ConsumerWidget {
  const ProductAdjustmentsTab({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adjustmentsAsync =
        ref.watch(productAdjustmentsControllerProvider(product.id));

    return adjustmentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ErrorState.fromError(
        error,
        compact: true,
        onRetry: () => ref
            .read(productAdjustmentsControllerProvider(product.id).notifier)
            .refresh(),
      ),
      data: (adjustments) {
        if (adjustments.isEmpty) {
          return const _EmptyAdjustmentsState();
        }

        return _AdjustmentsListContent(
          productId: product.id,
          adjustments: adjustments,
        );
      },
    );
  }
}

class _EmptyAdjustmentsState extends StatelessWidget {
  const _EmptyAdjustmentsState();

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
              Icons.history_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No Adjustments',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Stock adjustment history will appear here when you adjust the product\'s inventory.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AdjustmentsListContent extends ConsumerWidget {
  const _AdjustmentsListContent({
    required this.productId,
    required this.adjustments,
  });

  final String productId;
  final List<ProductAdjustment> adjustments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calculate totals
    final totalIncrease = adjustments
        .where((a) => a.isIncrease)
        .fold<num>(0, (sum, a) => sum + a.delta);
    final totalDecrease = adjustments
        .where((a) => a.isDecrease)
        .fold<num>(0, (sum, a) => sum + a.delta.abs());

    return Column(
      children: [
        // Summary header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.history,
                  label: 'Total',
                  value: adjustments.length.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.add,
                  label: 'Added',
                  value: '+${totalIncrease.toStringAsFixed(0)}',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.remove,
                  label: 'Removed',
                  value: '-${totalDecrease.toStringAsFixed(0)}',
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Adjustments list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref
                .read(productAdjustmentsControllerProvider(productId).notifier)
                .refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: adjustments.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final adjustment = adjustments[index];
                return _AdjustmentListTile(adjustment: adjustment);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayColor = color ?? theme.colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: displayColor, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: displayColor,
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

class _AdjustmentListTile extends StatelessWidget {
  const _AdjustmentListTile({
    required this.adjustment,
  });

  final ProductAdjustment adjustment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd();
    final timeFormat = DateFormat.Hm();

    // Determine colors based on increase/decrease
    final bool isIncrease = adjustment.isIncrease;
    final Color avatarColor =
        isIncrease ? Colors.green.shade100 : Colors.red.shade100;
    final Color iconColor = isIncrease ? Colors.green : Colors.red;
    final IconData icon = isIncrease ? Icons.add_circle : Icons.remove_circle;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: avatarColor,
        child: Icon(icon, color: iconColor),
      ),
      title: Row(
        children: [
          // Delta chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isIncrease
                  ? Colors.green.withValues(alpha: 0.15)
                  : Colors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              adjustment.deltaDisplay,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Value change
          Text(
            '${adjustment.oldValueDisplay} → ${adjustment.newValueDisplay}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          // Type badge
          Row(
            children: [
              Icon(
                adjustment.type == ProductAdjustmentType.productStock
                    ? Icons.layers
                    : Icons.inventory_2,
                size: 14,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(width: 4),
              Text(
                adjustment.type.displayName,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '•',
                style: TextStyle(color: theme.colorScheme.outline),
              ),
              const SizedBox(width: 8),
              // Date/time
              if (adjustment.created != null)
                Text(
                  '${dateFormat.format(adjustment.created!)} at ${timeFormat.format(adjustment.created!)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
            ],
          ),
          // Reason
          if (adjustment.reason != null && adjustment.reason!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              adjustment.reason!,
              style: theme.textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
      isThreeLine: adjustment.reason != null && adjustment.reason!.isNotEmpty,
    );
  }
}
