import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/routing/routes/sales_history.routes.dart';
import '../../../../../core/utils/currency_format.dart';
import '../../../../../core/utils/date_utils.dart';
import '../../../../../core/widgets/state/error_state.dart';
import '../../../../pos/domain/product_sale_line.dart';
import '../../../domain/product.dart';
import '../../../domain/product_sales_by_date.dart';
import '../../controllers/product_sales_provider.dart';

/// Sales tab for product detail page.
///
/// Shows recent purchase history for the product, grouped by date.
class ProductSalesTab extends ConsumerWidget {
  const ProductSalesTab({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(productSalesProvider(product.id));

    return salesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ErrorState.fromError(
        error,
        compact: true,
        onRetry: () => ref.invalidate(productSalesProvider(product.id)),
      ),
      data: (lines) {
        if (lines.isEmpty) {
          return const _EmptySalesState();
        }

        return _SalesListContent(
          productId: product.id,
          lines: lines,
        );
      },
    );
  }
}

class _EmptySalesState extends StatelessWidget {
  const _EmptySalesState();

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
              Icons.receipt_long_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No Sales Yet',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Recent purchases of this product will appear here.',
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

class _SalesListContent extends ConsumerWidget {
  const _SalesListContent({
    required this.productId,
    required this.lines,
  });

  final String productId;
  final List<ProductSaleLine> lines;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalQty = lines.fold<num>(
      0,
      (sum, line) =>
          line.countsTowardSalesTotals ? sum + line.quantity : sum,
    );
    final totalRevenue = lines.fold<num>(
      0,
      (sum, line) =>
          line.countsTowardSalesTotals ? sum + line.subtotal : sum,
    );
    final groups = groupProductSalesByDate(lines);
    final items = <_SalesListItem>[
      for (final group in groups) ...[
        _SalesListItem.header(group),
        for (final line in group.lines) _SalesListItem.line(line),
      ],
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.receipt_long,
                  label: 'Recent',
                  value: lines.length.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Qty Sold',
                  value: totalQty.toStringAsFixed(
                    totalQty == totalQty.roundToDouble() ? 0 : 1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.payments_outlined,
                  label: 'Revenue',
                  value: totalRevenue.toCurrency(),
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(productSalesProvider(productId));
              await ref.read(productSalesProvider(productId).future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                if (item.isHeader) {
                  return _DayHeader(group: item.group!);
                }
                return Column(
                  children: [
                    _SaleLineListTile(line: item.line!),
                    if (index + 1 < items.length && !items[index + 1].isHeader)
                      const Divider(height: 1),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _SalesListItem {
  const _SalesListItem._({this.group, this.line});

  factory _SalesListItem.header(ProductSalesDayGroup group) =>
      _SalesListItem._(group: group);

  factory _SalesListItem.line(ProductSaleLine line) =>
      _SalesListItem._(line: line);

  final ProductSalesDayGroup? group;
  final ProductSaleLine? line;

  bool get isHeader => group != null;
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.group});

  final ProductSalesDayGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final qty = group.totalQty;
    final qtyLabel = qty.toStringAsFixed(
      qty == qty.roundToDouble() ? 0 : 1,
    );

    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _dayLabel(group.date),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '$qtyLabel sold · ${group.totalRevenue.toCurrency()}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _dayLabel(DateTime? date) {
    if (date == null) return 'Unknown date';

    final today = toLocalDateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));
    final day = toLocalDateOnly(date);

    if (day == today) return 'Today';
    if (day == yesterday) return 'Yesterday';
    return DateFormat('MMM dd, yyyy').format(day);
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
              style: theme.textTheme.titleMedium?.copyWith(
                color: displayColor,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

class _SaleLineListTile extends StatelessWidget {
  const _SaleLineListTile({required this.line});

  final ProductSaleLine line;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('hh:mm a');
    final receiptLabel = line.receiptNumber.isNotEmpty
        ? '#${line.receiptNumber}'
        : 'Sale';
    final qtyLabel = line.quantity == line.quantity.roundToDouble()
        ? line.quantity.toStringAsFixed(0)
        : line.quantity.toString();

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(
          Icons.receipt,
          color: theme.colorScheme.onPrimaryContainer,
          size: 20,
        ),
      ),
      title: Text(receiptLabel),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            [
              if (line.created != null) timeFormat.format(line.created!),
              if (line.customerName != null && line.customerName!.isNotEmpty)
                line.customerName!,
              '$qtyLabel × ${line.unitPrice.toCurrency()}',
              if (line.hasLot) 'Lot ${line.lotNumber}',
            ].join(' · '),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                line.subtotal.toCurrency(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    line.isPaid ? Icons.check_circle : Icons.pending,
                    size: 12,
                    color: line.isPaid ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    line.isPaid ? 'Paid' : 'Unpaid',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: line.isPaid ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
      onTap: line.saleId.isEmpty
          ? null
          : () => SaleDetailRoute(id: line.saleId).go(context),
    );
  }
}
