import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/branch_code_pill.dart';
import '../../../dashboard/presentation/widgets/kpi_breakdown_dialog.dart';
import '../../../dashboard/presentation/widgets/sale_quick_view_dialog.dart';
import '../../../dashboard/presentation/widgets/today_sale_list_tile.dart';
import '../../../pos/domain/sale.dart';
import '../../../settings/presentation/controllers/branches_controller.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/report_aggregations.dart';
import '../../domain/report_period.dart';
import '../controllers/report_period_controller.dart';
import '../controllers/sales_report_controller.dart';

/// Opens a Sales report KPI drill-down listing transactions for [itemType].
///
/// [itemType] is `membership` / `walkIn` / `product`.
Future<void> showSalesItemTypeTransactionsDialog(
  BuildContext context, {
  required String itemType,
  String? revenueLabel,
}) {
  return showKpiBreakdownDialog(
    context: context,
    title: _dialogTitle(itemType),
    bodyBuilder: (context, ref) => _SalesItemTypeTransactionsBody(
      itemType: itemType,
      revenueLabel: revenueLabel,
    ),
  );
}

String _dialogTitle(String itemType) {
  switch (itemType) {
    case 'membership':
      return 'Memberships';
    case 'walkIn':
      return 'Walk-ins';
    case 'product':
      return 'Products';
    default:
      return itemTypeLabel(itemType);
  }
}

class _SalesItemTypeTransactionsBody extends ConsumerWidget {
  const _SalesItemTypeTransactionsBody({
    required this.itemType,
    this.revenueLabel,
  });

  final String itemType;
  final String? revenueLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(salesByItemTypeProvider(itemType));
    final period = ref.watch(reportPeriodControllerProvider);
    final viewingAll = ref.watch(viewingAllBranchesProvider);
    final branches = ref.watch(branchesControllerProvider).value ?? const [];
    final labels = branchLabelMaps(branches);
    final theme = Theme.of(context);
    final showDate = period.period != ReportPeriod.day;
    final emphasizeCustomerName = itemType == 'membership';
    final capped = shouldCapSalesByItemType(period.period);

    final subtitleParts = <String>[
      period.displayRangeLabel,
      if (revenueLabel != null) revenueLabel!,
    ];

    return KpiBreakdownListBody<Sale>(
      asyncValue: salesAsync,
      emptyMessage: 'No ${_dialogTitle(itemType).toLowerCase()} in this period',
      emptyIcon: Icons.receipt_long_outlined,
      onRetry: () => ref.invalidate(salesByItemTypeProvider(itemType)),
      summaryHeaderBuilder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitleParts.join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (capped) ...[
              const SizedBox(height: 4),
              Text(
                'Showing up to $kSalesByItemTypeYearCap newest sales',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ],
        ),
      ),
      listHeader: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: Text(
          'Transactions',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      itemBuilder: (context, sale) {
        final code = viewingAll ? labels.codeById[sale.branchId] : null;
        final name = viewingAll ? labels.nameById[sale.branchId] : null;
        return TodaySaleListTile(
          sale: sale,
          showDate: showDate,
          branchLabel: code ?? (viewingAll ? sale.branchId : null),
          branchTooltip: name,
          emphasizeCustomerName: emphasizeCustomerName,
          onTap: () => showSaleQuickViewDialog(
            context,
            saleId: sale.id,
            fallbackSale: sale,
          ),
        );
      },
    );
  }
}
