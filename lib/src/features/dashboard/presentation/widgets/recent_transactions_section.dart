import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/branch_code_pill.dart';
import '../../../pos/domain/sale.dart';
import '../../../sales/presentation/widgets/sale_status_chip.dart';
import '../../../settings/domain/branch.dart';
import '../../../settings/presentation/controllers/branches_controller.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../controllers/todays_sales_controller.dart';
import 'kpi_breakdown_dialogs.dart';
import 'sale_quick_view_dialog.dart';

/// Collapsible dashboard section showing today's recent sales.
class RecentTransactionsSection extends HookConsumerWidget {
  const RecentTransactionsSection({super.key});

  static const _maxPreview = 10;
  static const _cardWidth = 200.0;
  static const _listHeight = 160.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isExpanded = useState(true);
    final salesAsync = ref.watch(todaySalesProvider);
    final viewingAll = ref.watch(viewingAllBranchesProvider);
    final branches = ref.watch(branchesControllerProvider).value ?? const [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Recent Transactions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              salesAsync.when(
                data: (sales) {
                  if (sales.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      '${sales.length}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => showTodaysTransactionsDialog(context),
                child: const Text('View All'),
              ),
              IconButton(
                tooltip: isExpanded.value ? 'Collapse' : 'Expand',
                onPressed: () => isExpanded.value = !isExpanded.value,
                icon: Icon(
                  isExpanded.value ? Icons.expand_less : Icons.expand_more,
                ),
              ),
            ],
          ),
          if (isExpanded.value) ...[
            const SizedBox(height: 4),
            salesAsync.when(
              data: (sales) {
                if (sales.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No transactions today',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                final preview = sales.take(_maxPreview).toList();
                return SizedBox(
                  height: _listHeight,
                  width: double.infinity,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: preview.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final sale = preview[index];
                      return SizedBox(
                        width: _cardWidth,
                        child: _RecentTransactionCard(
                          sale: sale,
                          showBranchPill: viewingAll,
                          branches: branches,
                          onTap: () => showSaleQuickViewDialog(
                            context,
                            saleId: sale.id,
                            fallbackSale: sale,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const SizedBox(
                height: _listHeight,
                width: double.infinity,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Text(
                      'Could not load transactions',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => ref.invalidate(todaySalesProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecentTransactionCard extends StatelessWidget {
  const _RecentTransactionCard({
    required this.sale,
    required this.onTap,
    required this.showBranchPill,
    required this.branches,
  });

  final Sale sale;
  final VoidCallback onTap;
  final bool showBranchPill;
  final List<Branch> branches;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₱');
    final timeFormat = DateFormat('hh:mm a');
    final timeLabel =
        sale.created != null ? timeFormat.format(sale.created!) : '—';
    final branchPill = showBranchPill
        ? BranchCodePill.fromBranches(
            branchId: sale.branchId,
            branches: branches,
            dense: true,
          )
        : null;

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      sale.listTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  SaleStatusChip(status: sale.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                sale.shortReceiptNumber,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                currencyFormat.format(sale.totalAmount),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  if (branchPill != null) ...[
                    branchPill,
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      timeLabel,
                      textAlign: TextAlign.end,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
