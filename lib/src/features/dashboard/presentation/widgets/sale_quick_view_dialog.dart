import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/routes/sales_history.routes.dart';
import '../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../core/widgets/dialog_close_handler.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../../../pos/domain/payment.dart';
import '../../../pos/domain/payment_type.dart';
import '../../../pos/domain/sale.dart';
import '../../../pos/domain/sale_item.dart';
import '../../../pos/domain/sale_payment_status.dart';
import '../../../pos/presentation/payments_controller.dart';
import '../../../sales/presentation/controllers/sale_items_provider.dart';
import '../../../sales/presentation/controllers/sale_provider.dart';
import '../../../sales/presentation/widgets/record_payment_dialog.dart';
import '../../../sales/presentation/widgets/sale_status_chip.dart';
import '../controllers/todays_sales_controller.dart';

/// Shows a quick-view dialog with sale details, items, and payment actions.
///
/// Used from the dashboard recent transactions and today's sales dialogs for
/// fast lookup without navigating to the full sale detail page.
Future<void> showSaleQuickViewDialog(
  BuildContext context, {
  required String saleId,
  Sale? fallbackSale,
}) {
  return showConstrainedDialog<void>(
    context: context,
    maxWidth: DialogConstraints.compactMaxWidth,
    barrierDismissible: true,
    builder: (context) => SaleQuickViewDialog(
      saleId: saleId,
      fallbackSale: fallbackSale,
    ),
  );
}

/// Compact sale + payment preview dialog for the dashboard.
class SaleQuickViewDialog extends ConsumerWidget {
  const SaleQuickViewDialog({
    super.key,
    required this.saleId,
    this.fallbackSale,
  });

  final String saleId;
  final Sale? fallbackSale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy hh:mm a');
    final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
    final saleAsync = ref.watch(saleProvider(saleId));
    final itemsAsync = ref.watch(saleItemsProvider(saleId));
    final paymentsAsync = ref.watch(salePaymentsProvider(saleId));

    final sale = saleAsync.value ?? fallbackSale;

    return DialogCloseHandler(
      child: ConstrainedDialogContent(
        maxWidth: DialogConstraints.compactMaxWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Sale',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (sale != null) SaleStatusChip(status: sale.status),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (sale == null && saleAsync.isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    else if (sale == null)
                      ErrorState.fromError(
                        saleAsync.error ?? 'Sale not found',
                        compact: true,
                      )
                    else
                      _SaleHeader(
                        sale: sale,
                        dateFormat: dateFormat,
                        currencyFormat: currencyFormat,
                        isLoading: saleAsync.isLoading,
                      ),
                    if (sale != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Items',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      itemsAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        error: (error, _) =>
                            ErrorState.fromError(error, compact: true),
                        data: (items) => _ItemsSummary(
                          items: items,
                          currencyFormat: currencyFormat,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Payment',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      paymentsAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        error: (error, _) =>
                            ErrorState.fromError(error, compact: true),
                        data: (payments) => _PaymentSummary(
                          sale: sale,
                          payments: payments,
                          currencyFormat: currencyFormat,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _ActionButtons(
                saleId: saleId,
                sale: sale,
                paymentsAsync: paymentsAsync,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaleHeader extends StatelessWidget {
  const _SaleHeader({
    required this.sale,
    required this.dateFormat,
    required this.currencyFormat,
    this.isLoading = false,
  });

  final Sale sale;
  final DateFormat dateFormat;
  final NumberFormat currencyFormat;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.receipt_long,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sale.listTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (sale.descriptor != null &&
                      sale.descriptor!.trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      sale.receiptNumber,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    sale.created != null
                        ? dateFormat.format(sale.created!)
                        : 'Unknown date',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (isLoading) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Loading details…',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 12),
        _InfoRow(
          label: 'Total',
          value: currencyFormat.format(sale.totalAmount),
        ),
        _InfoRow(
          label: 'Payment',
          value: sale.isPaid ? 'Paid' : 'No payment yet',
          valueColor: sale.isPaid ? Colors.green : Colors.orange,
        ),
        _InfoRow(label: 'Customer', value: sale.customerDisplay),
        if (sale.notes != null && sale.notes!.isNotEmpty)
          _InfoRow(label: 'Notes', value: sale.notes!),
      ],
    );
  }
}

class _ItemsSummary extends StatelessWidget {
  const _ItemsSummary({
    required this.items,
    required this.currencyFormat,
  });

  final List<SaleItem> items;
  final NumberFormat currencyFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'No items on this sale',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final preview = items.take(4).toList();
    final remaining = items.length - preview.length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (final item in preview)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${currencyFormat.format(item.unitPrice)} × ${item.quantity}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    currencyFormat.format(item.subtotal),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          if (remaining > 0) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '+$remaining more item${remaining == 1 ? '' : 's'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PaymentSummary extends StatelessWidget {
  const _PaymentSummary({
    required this.sale,
    required this.payments,
    required this.currencyFormat,
  });

  final Sale sale;
  final List<Payment> payments;
  final NumberFormat currencyFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    num totalPaid = 0;
    for (final payment in payments) {
      if (payment.type == PaymentType.refund) {
        totalPaid -= payment.amount;
      } else {
        totalPaid += payment.amount;
      }
    }
    final balanceDue = sale.totalAmount - totalPaid;
    final hasNoPayment = payments.isEmpty || totalPaid <= 0;

    final statusColor = hasNoPayment
        ? Colors.orange
        : balanceDue > 0
            ? Colors.amber.shade800
            : Colors.green;
    final statusLabel = hasNoPayment
        ? 'No payment yet'
        : balanceDue > 0
            ? 'Partial payment'
            : 'Paid in full';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: statusColor.withValues(alpha: 0.15),
                child: Icon(
                  hasNoPayment ? Icons.money_off : Icons.payments,
                  size: 18,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  statusLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  hasNoPayment
                      ? 'Unpaid'
                      : balanceDue > 0
                          ? 'Balance due'
                          : 'Paid',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Total',
            value: currencyFormat.format(sale.totalAmount),
          ),
          _InfoRow(
            label: 'Paid',
            value: currencyFormat.format(totalPaid),
            valueColor: Colors.green,
          ),
          _InfoRow(
            label: 'Balance',
            value: currencyFormat.format(balanceDue),
            valueColor: balanceDue > 0 ? Colors.red : null,
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.saleId,
    required this.sale,
    required this.paymentsAsync,
  });

  final String saleId;
  final Sale? sale;
  final AsyncValue<List<Payment>> paymentsAsync;

  @override
  Widget build(BuildContext context) {
    final canRecordPayment = paymentsAsync.maybeWhen(
      data: (payments) {
        if (sale == null) return false;
        final status = sale!.status.toLowerCase();
        if (isClosedSaleStatus(status)) return false;

        num totalPaid = 0;
        for (final payment in payments) {
          if (payment.type == PaymentType.refund) {
            totalPaid -= payment.amount;
          } else {
            totalPaid += payment.amount;
          }
        }
        return sale!.totalAmount - totalPaid > 0;
      },
      orElse: () => sale != null && !sale!.isPaid,
    );

    final balanceDue = paymentsAsync.maybeWhen(
      data: (payments) {
        if (sale == null) return sale?.totalAmount ?? 0;
        num totalPaid = 0;
        for (final payment in payments) {
          if (payment.type == PaymentType.refund) {
            totalPaid -= payment.amount;
          } else {
            totalPaid += payment.amount;
          }
        }
        return sale!.totalAmount - totalPaid;
      },
      orElse: () => sale?.totalAmount ?? 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canRecordPayment)
          FilledButton.icon(
            onPressed: sale == null
                ? null
                : () async {
                    final currentSale = sale!;
                    // Capture before await — recording payment invalidates
                    // saleProvider and can unmount this widget mid-callback.
                    final container = ProviderScope.containerOf(context);
                    final result = await showRecordPaymentDialog(
                      context,
                      sale: currentSale,
                      balanceDue: balanceDue,
                    );
                    if (result == true) {
                      container.invalidate(saleProvider(saleId));
                      container.invalidate(salePaymentsProvider(saleId));
                      container.invalidate(todaySalesProvider);
                    }
                  },
            icon: const Icon(Icons.payment),
            label: const Text('Record payment'),
          ),
        if (canRecordPayment) const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            final router = GoRouter.of(context);
            final location = SaleDetailRoute(id: saleId).location;
            Navigator.of(context).pop();
            router.push(location);
          },
          icon: const Icon(Icons.open_in_new),
          label: const Text('Show full details'),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
