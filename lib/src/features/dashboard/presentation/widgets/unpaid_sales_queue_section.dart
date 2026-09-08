import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../memberships/data/repositories/member_membership_repository.dart';
import '../../../pos/data/repositories/sales_repository.dart';
import '../../../pos/domain/sale.dart';
import '../../../products/data/repositories/product_adjustment_repository.dart';
import '../../../products/data/repositories/product_lot_repository.dart';
import '../../../products/data/repositories/product_repository.dart';
import '../../../sales/data/sale_side_effects.dart';
import '../../../sales/domain/open_unpaid_sale.dart';
import '../../../sales/presentation/controllers/sale_provider.dart';
import '../../../sales/presentation/controllers/sale_refresh.dart';
import '../../../sales/presentation/widgets/record_payment_dialog.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../controllers/dashboard_refresh.dart';
import '../controllers/todays_sales_controller.dart';
import 'sale_quick_view_dialog.dart';

/// Session-local sale IDs dismissed from the Unpaid today banner via Ignore.
///
/// Does not change the sale on the server; duplicate unpaid checks still apply.
class IgnoredUnpaidSaleIds extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void ignore(String saleId) {
    if (saleId.isEmpty || state.contains(saleId)) return;
    state = {...state, saleId};
  }
}

final ignoredUnpaidSaleIdsProvider =
    NotifierProvider<IgnoredUnpaidSaleIds, Set<String>>(
  IgnoredUnpaidSaleIds.new,
);

/// Branch-scoped list of today's unpaid sales with pay / void / ignore actions.
class UnpaidSalesQueueSection extends ConsumerWidget {
  const UnpaidSalesQueueSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branchId = ref.watch(effectiveBranchIdForWriteProvider);
    final unpaidAsync = ref.watch(todayUnpaidSalesProvider);
    final ignoredIds = ref.watch(ignoredUnpaidSaleIdsProvider);

    if (branchId == null) return const SizedBox.shrink();

    return unpaidAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (allSales) {
        final sales = excludeIgnoredUnpaidSales(allSales, ignoredIds);
        if (sales.isEmpty) return const SizedBox.shrink();
        final theme = Theme.of(context);
        final currency =
            NumberFormat.currency(symbol: '\u20B1', decimalDigits: 2);

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Card(
            color: theme.colorScheme.errorContainer.withValues(alpha: 0.35),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.pending_actions,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Unpaid today (${sales.length})',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Refresh',
                        onPressed: () =>
                            ref.invalidate(todayUnpaidSalesProvider),
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Record payment or void before creating another sale for the same customer.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  ...sales.take(8).map(
                        (sale) => _UnpaidSaleTile(
                          sale: sale,
                          currency: currency,
                        ),
                      ),
                  if (sales.length > 8)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '+${sales.length - 8} more in Sales',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _UnpaidSaleTile extends ConsumerWidget {
  const _UnpaidSaleTile({
    required this.sale,
    required this.currency,
  });

  final Sale sale;
  final NumberFormat currency;

  Future<void> _openSaleDialog(BuildContext context, WidgetRef ref) async {
    await showSaleQuickViewDialog(
      context,
      saleId: sale.id,
      fallbackSale: sale,
    );
    if (!context.mounted) return;
    refreshSalesData(ref);
    ref.invalidate(todayUnpaidSalesProvider);
    ref.invalidate(saleProvider(sale.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      onTap: () => _openSaleDialog(context, ref),
      title: Text(sale.listTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${sale.shortReceiptNumber} · ${sale.status} · ${currency.format(sale.totalAmount)}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () async {
              await showRecordPaymentDialog(
                context,
                sale: sale,
                balanceDue: sale.totalAmount,
              );
              refreshSalesData(ref);
              ref.invalidate(todayUnpaidSalesProvider);
              ref.invalidate(saleProvider(sale.id));
            },
            child: const Text('Pay'),
          ),
          TextButton(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Void sale?'),
                  content: Text(
                    'Void ${sale.shortReceiptNumber}? Linked memberships will be voided and product stock restored.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style:
                          FilledButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Void'),
                    ),
                  ],
                ),
              );
              if (confirmed != true || !context.mounted) return;

              final result = await voidSaleWithSideEffects(
                salesRepo: ref.read(salesRepositoryProvider),
                memberMembershipRepo:
                    ref.read(memberMembershipRepositoryProvider),
                lotRepo: ref.read(productLotRepositoryProvider),
                productRepo: ref.read(productRepositoryProvider),
                adjustmentRepo: ref.read(productAdjustmentRepositoryProvider),
                saleId: sale.id,
                voidedById: ref.read(currentAuthProvider)?.user.id,
              );
              if (!context.mounted) return;
              result.fold(
                (f) => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(f.messageString)),
                ),
                (_) {
                  refreshAfterSaleVoided(ref, sale.id);
                  ref.invalidate(todayUnpaidSalesProvider);
                },
              );
            },
            child: const Text('Void'),
          ),
          Tooltip(
            message: 'Hide from this list (sale stays unpaid)',
            child: TextButton(
              onPressed: () {
                ref
                    .read(ignoredUnpaidSaleIdsProvider.notifier)
                    .ignore(sale.id);
              },
              child: const Text('Ignore'),
            ),
          ),
        ],
      ),
    );
  }
}
