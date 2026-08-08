import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/branch_code_pill.dart';
import '../../../pos/domain/sale.dart';
import 'sale_status_chip.dart';

/// Shared sale row for sales history and dashboard lists.
///
/// Layout: receipt avatar | short description / reference+date | amount+status.
class SaleListTile extends StatelessWidget {
  const SaleListTile({
    super.key,
    required this.sale,
    required this.onTap,
    this.isSelected = false,
    this.dateFormat,
    this.branchPill,
    this.branchLabel,
    this.branchTooltip,
    this.contentPadding,
  });

  final Sale sale;
  final VoidCallback onTap;
  final bool isSelected;

  /// Subtitle date format. Defaults to `MMM dd, yyyy`.
  final DateFormat? dateFormat;

  /// Pre-built branch pill (preferred when resolving from a branch list).
  final Widget? branchPill;

  /// Branch code when [branchPill] is not provided.
  final String? branchLabel;

  /// Tooltip for [branchLabel].
  final String? branchTooltip;

  final EdgeInsetsGeometry? contentPadding;

  /// Builds the compact subtitle: receipt/customer + date (no Paid/Unpaid).
  static String buildSubtitle(Sale sale, DateFormat dateFormat) {
    final hasDescriptor =
        sale.descriptor != null && sale.descriptor!.trim().isNotEmpty;
    final dateLabel = sale.created != null
        ? dateFormat.format(sale.created!)
        : 'Unknown';
    final parts = <String>[
      if (hasDescriptor) sale.shortReceiptNumber,
      if (!hasDescriptor) sale.customerDisplay,
      dateLabel,
    ];
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₱');
    final effectiveDateFormat = dateFormat ?? DateFormat('MMM dd, yyyy');
    final title = sale.listTitle;
    final subtitle = buildSubtitle(sale, effectiveDateFormat);

    final resolvedBranch = branchPill ??
        (branchLabel != null && branchLabel!.isNotEmpty
            ? BranchCodePill(
                label: branchLabel!,
                tooltip: branchTooltip,
                dense: true,
              )
            : null);

    return Material(
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: contentPadding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.receipt_long,
                  size: 20,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Tooltip(
                      message: title,
                      waitDuration: const Duration(milliseconds: 350),
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        if (resolvedBranch != null) ...[
                          const SizedBox(width: 6),
                          resolvedBranch,
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(sale.totalAmount),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  SaleStatusChip(
                    status: sale.status,
                    dense: true,
                    showLabel: true,
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
