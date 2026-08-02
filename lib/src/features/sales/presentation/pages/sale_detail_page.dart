import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/routes/members.routes.dart';
import '../../../../core/routing/routes/sales_history.routes.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../../core/permissions/current_user_permissions.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../dashboard/presentation/controllers/dashboard_refresh.dart';
import '../../../pos/data/repositories/sales_repository.dart';
import '../../../pos/domain/payment.dart';
import '../../../pos/domain/payment_type.dart';
import '../../../pos/domain/sale.dart';
import '../../../pos/domain/sale_payment_status.dart';
import '../../../pos/presentation/payments_controller.dart';
import '../../../users/presentation/controllers/user_provider.dart';
import '../controllers/paginated_sales_controller.dart';
import '../controllers/sale_items_provider.dart';
import '../controllers/sale_provider.dart';
import '../widgets/record_payment_dialog.dart';
import '../widgets/sale_status_chip.dart';

/// Sale detail page showing sale information and items.
class SaleDetailPage extends ConsumerWidget {
  const SaleDetailPage({
    super.key,
    required this.saleId,
  });

  final String saleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saleAsync = ref.watch(saleProvider(saleId));
    final isTablet = Breakpoints.isTabletOrLarger(context);

    return saleAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          leading: isTablet
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => const SalesHistoryRoute().go(context),
                ),
        ),
        body: ErrorState.fromError(
          error,
          onRetry: () => ref.invalidate(saleProvider(saleId)),
        ),
      ),
      data: (sale) {
        if (sale == null) {
          return Scaffold(
            appBar: AppBar(
              leading: isTablet
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => const SalesHistoryRoute().go(context),
                    ),
            ),
            body: const Center(
              child: Text('Sale not found'),
            ),
          );
        }

        return _SaleDetailContent(
          sale: sale,
          isTablet: isTablet,
        );
      },
    );
  }
}

class _SaleDetailContent extends HookConsumerWidget {
  const _SaleDetailContent({
    required this.sale,
    required this.isTablet,
  });

  final Sale sale;
  final bool isTablet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final saleItemsAsync = ref.watch(saleItemsProvider(sale.id));
    final paymentsAsync = ref.watch(salePaymentsProvider(sale.id));
    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');
    final currencyFormat = NumberFormat.currency(symbol: '₱');
    final headline = sale.detailTitle;
    final showReceiptSubtitle = headline != sale.receiptNumber;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !isTablet,
        leading: isTablet
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => const SalesHistoryRoute().go(context),
              ),
        title: Text(
          headline,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              showWarningSnackBar(context,
                  message: 'Print functionality coming soon');
            },
            tooltip: 'Print Receipt',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(saleProvider(sale.id));
          ref.invalidate(saleItemsProvider(sale.id));
          ref.invalidate(salePaymentsProvider(sale.id));
          await Future.wait([
            ref.read(saleProvider(sale.id).future),
            ref.read(saleItemsProvider(sale.id).future),
            ref.read(salePaymentsProvider(sale.id).future),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  headline,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (showReceiptSubtitle) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    sale.receiptNumber,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color:
                                          theme.colorScheme.onSurfaceVariant,
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
                              ],
                            ),
                          ),
                          SaleStatusChip(status: sale.status),
                        ],
                      ),
                      const Divider(height: 24),
                      _CustomerInfoRow(
                        customerName: sale.customerDisplay,
                        customerId: sale.customerId,
                      ),
                      if (sale.notes != null && sale.notes!.isNotEmpty)
                        _InfoRow(
                          icon: Icons.note,
                          label: 'Notes',
                          value: sale.notes!,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sale Status Actions (Void)
              _buildSaleStatusActions(context, ref),
              const SizedBox(height: 16),

              // Items Section
              Text(
                'Items',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                child: saleItemsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => ErrorState.fromError(
                    error,
                    compact: true,
                  ),
                  data: (items) => items.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No items'),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return ListTile(
                              title: Text(item.productName),
                              subtitle: Text(
                                '${currencyFormat.format(item.unitPrice)} × ${item.quantity}',
                              ),
                              trailing: Text(
                                currencyFormat.format(item.subtotal),
                                style: theme.textTheme.titleSmall,
                              ),
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Total Card
              Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: theme.textTheme.titleLarge,
                      ),
                      Text(
                        currencyFormat.format(sale.totalAmount),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Payment Status & History Card
              _buildPaymentCard(context, ref, paymentsAsync, currencyFormat),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaleStatusActions(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isUpdating = useState(false);
    final statusLower = sale.status.toLowerCase();
    final isVoided = statusLower == 'voided';
    final isRefunded = statusLower == 'refunded';
    final canVoidSale =
        ref.watch(currentUserPermissionsProvider).value?.canVoidSales ?? false;

    // Show closed-sale info instead of actions (voided + legacy refunded).
    if (isVoided) {
      return _buildVoidedInfoCard(context, ref, theme);
    }
    if (isRefunded) {
      return _buildRefundedInfoCard(theme);
    }

    Future<void> voidSale() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Void Sale?'),
          content: const Text(
            'Are you sure you want to void this sale? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Void'),
            ),
          ],
        ),
      );

      if (confirmed != true || !context.mounted) return;

      isUpdating.value = true;
      final repo = ref.read(salesRepositoryProvider);

      final result = await repo.updateSale(sale.id, {
        'status': 'voided',
        'voidedBy': ref.read(currentAuthProvider)?.user.id,
      });
      isUpdating.value = false;

      if (!context.mounted) return;

      result.fold(
        (failure) {
          showErrorSnackBar(context, message: failure.messageString);
        },
        (_) {
          showSuccessSnackBar(context, message: 'Sale voided');
          ref.invalidate(saleProvider(sale.id));
          ref.read(paginatedSalesControllerProvider.notifier).refresh();
          refreshTodaysSales(ref);
        },
      );
    }

    // Determine chip color and label
    final (chipColor, chipLabel) = switch (statusLower) {
      'pending' => (Colors.grey, 'Pending'),
      'awaitingpayment' => (Colors.amber, 'Awaiting Payment'),
      'paid' => (Colors.green, 'Paid'),
      'completed' => (Colors.green, 'Completed'),
      _ => (Colors.grey, sale.status),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.receipt_long,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Sale Status',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Current status chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: chipColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                chipLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: chipColor == Colors.amber
                      ? Colors.amber.shade700
                      : chipColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (canVoidSale) ...[
              const SizedBox(width: 8),
              // Popup menu for actions
              PopupMenuButton<String>(
                icon: isUpdating.value
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.more_vert),
                enabled: !isUpdating.value,
                onSelected: (_) => voidSale(),
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'voided',
                    child: ListTile(
                      leading: Icon(Icons.cancel, color: Colors.red),
                      title: Text('Void Sale'),
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRefundedInfoCard(ThemeData theme) {
    return Card(
      color: Colors.orange.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.replay, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Refunded',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'This sale was refunded (legacy status). Payment actions are disabled.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoidedInfoCard(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) {
    final voidedByAsync = sale.voidedById != null
        ? ref.watch(userProvider(sale.voidedById!))
        : null;

    final voidedByName = voidedByAsync?.value?.name;

    return Card(
      color: Colors.red.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.cancel, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Voided',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  if (voidedByName != null)
                    Text(
                      'By $voidedByName',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red.shade300,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Payment>> paymentsAsync,
    NumberFormat currencyFormat,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.payments,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Payment',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Payment status chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: sale.isPaid
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        sale.isPaid ? Icons.check_circle : Icons.pending,
                        size: 16,
                        color: sale.isPaid ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        sale.isPaid ? 'Paid' : 'Unpaid',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: sale.isPaid ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Payment summary
            paymentsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, _) => ErrorState.fromError(
                error,
                compact: true,
              ),
              data: (payments) {
                // Calculate totals
                num totalPaid = 0;
                for (final payment in payments) {
                  if (payment.type == PaymentType.refund) {
                    totalPaid -= payment.amount;
                  } else {
                    totalPaid += payment.amount;
                  }
                }
                final balanceDue = sale.totalAmount - totalPaid;
                final statusLower = sale.status.toLowerCase();
                final canVoidPayment = (ref
                            .watch(currentUserPermissionsProvider)
                            .value
                            ?.canVoidSales ??
                        false) &&
                    !isClosedSaleStatus(statusLower);
                final canRecordPayment =
                    !isClosedSaleStatus(statusLower) &&
                    balanceDue > 0;

                return Column(
                  children: [
                    // Summary row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Amount',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              currencyFormat.format(sale.totalAmount),
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Paid',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              currencyFormat.format(totalPaid),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Balance Due',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              currencyFormat.format(balanceDue),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: balanceDue > 0
                                    ? Colors.red
                                    : theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Payment history
                    if (payments.isNotEmpty) ...[
                      const Divider(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Payment History',
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: payments.length,
                        itemBuilder: (context, index) {
                          final payment = payments[index];
                          final isRefund = payment.type == PaymentType.refund;
                          final isGcashBank =
                              payment.type == PaymentType.deposit;
                          final hasProof = payment.paymentProofUrl != null &&
                              payment.paymentProofUrl!.isNotEmpty;

                          return Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: isRefund
                                      ? Colors.red.withValues(alpha: 0.1)
                                      : Colors.green.withValues(alpha: 0.1),
                                  child: Icon(
                                    isRefund ? Icons.remove : Icons.add,
                                    size: 18,
                                    color: isRefund ? Colors.red : Colors.green,
                                  ),
                                ),
                                title: Text(
                                  '${payment.type.displayName} - ${payment.paymentMethod.displayName}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      payment.created != null
                                          ? DateFormat('MMM dd, yyyy hh:mm a')
                                              .format(payment.created!)
                                          : '',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    // Show reference for GCash/Bank payments
                                    if (isGcashBank &&
                                        payment.paymentRef != null &&
                                        payment.paymentRef!.isNotEmpty)
                                      Text(
                                        'Ref: ${payment.paymentRef}',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${isRefund ? '-' : '+'}${currencyFormat.format(payment.amount)}',
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        color: isRefund
                                            ? Colors.red
                                            : Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (canVoidPayment)
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert),
                                        tooltip: 'Payment actions',
                                        onSelected: (value) {
                                          if (value == 'void') {
                                            _voidPayment(
                                              context,
                                              ref,
                                              payment,
                                              currencyFormat,
                                            );
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          PopupMenuItem<String>(
                                            value: 'void',
                                            child: ListTile(
                                              leading: Icon(
                                                Icons.cancel,
                                                color: theme.colorScheme.error,
                                              ),
                                              title: const Text('Void Payment'),
                                              contentPadding: EdgeInsets.zero,
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              // Show proof of payment button if available
                              if (hasProof)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 56, bottom: 8),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton.icon(
                                      onPressed: () {
                                        _showPaymentProofDialog(
                                          context,
                                          payment.paymentProofUrl!,
                                        );
                                      },
                                      icon: const Icon(Icons.receipt_long,
                                          size: 16),
                                      label: const Text('View Proof'),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],

                    // Record payment button
                    if (canRecordPayment) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonalIcon(
                          onPressed: () async {
                            final result = await showRecordPaymentDialog(
                              context,
                              sale: sale,
                              balanceDue: balanceDue,
                            );
                            if (result == true) {
                              ref.invalidate(saleProvider(sale.id));
                              ref.invalidate(salePaymentsProvider(sale.id));
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Record Payment'),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _voidPayment(
    BuildContext context,
    WidgetRef ref,
    Payment payment,
    NumberFormat currencyFormat,
  ) async {
    final isRefund = payment.type == PaymentType.refund;
    final amountLabel = currencyFormat.format(payment.amount);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isRefund ? 'Void Refund?' : 'Void Payment?'),
        content: Text(
          isRefund
              ? 'Remove this $amountLabel refund? The sale balance will be recalculated.'
              : 'Remove this $amountLabel payment? The sale balance will be recalculated.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Void'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final success = await ref
        .read(paymentsControllerProvider.notifier)
        .deletePayment(payment.id, sale.id);

    if (!context.mounted) return;

    if (success) {
      ref.invalidate(saleProvider(sale.id));
      ref.invalidate(salePaymentsProvider(sale.id));
      showSuccessSnackBar(
        context,
        message: isRefund ? 'Refund voided' : 'Payment voided',
      );
    } else {
      showErrorSnackBar(
        context,
        message: isRefund
            ? 'Failed to void refund'
            : 'Failed to void payment',
      );
    }
  }

  void _showPaymentProofDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Proof of Payment'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Flexible(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.broken_image, size: 48),
                        SizedBox(height: 8),
                        Text('Failed to load image'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Clickable customer info row that navigates to customer detail.
class _CustomerInfoRow extends StatelessWidget {
  const _CustomerInfoRow({
    required this.customerName,
    this.customerId,
  });

  final String customerName;
  final String? customerId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasCustomerId = customerId != null && customerId!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.person,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            'Customer: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: hasCustomerId
                ? InkWell(
                    onTap: () =>
                        MemberDetailRoute(id: customerId!).go(context),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              customerName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                decoration: TextDecoration.underline,
                                decorationColor: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.open_in_new,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  )
                : Text(
                    customerName,
                    style: theme.textTheme.bodyMedium,
                  ),
          ),
        ],
      ),
    );
  }
}
