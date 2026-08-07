import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/branch_code_pill.dart';
import '../../../pos/domain/sale.dart';
import '../../../sales/presentation/widgets/sale_status_chip.dart';

/// Compact list tile for a sale transaction (dashboard / today's list).
class TodaySaleListTile extends StatelessWidget {
  const TodaySaleListTile({
    super.key,
    required this.sale,
    required this.onTap,
    this.showDate = false,
    this.branchLabel,
    this.branchTooltip,
  });

  final Sale sale;
  final VoidCallback onTap;

  /// When true, shows calendar date with time (for multi-day ranges).
  final bool showDate;

  /// Optional branch code pill (shown when viewing all branches).
  final String? branchLabel;

  /// Tooltip for [branchLabel] (typically the full branch name).
  final String? branchTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₱');
    final timeFormat = showDate
        ? DateFormat('MMM d · hh:mm a')
        : DateFormat('hh:mm a');

    final timeLabel =
        sale.created != null ? timeFormat.format(sale.created!) : null;
    final hasDescriptor =
        sale.descriptor != null && sale.descriptor!.trim().isNotEmpty;
    final subtitleParts = <String>[
      if (hasDescriptor) sale.shortReceiptNumber,
      if (timeLabel != null) timeLabel,
      sale.customerDisplay,
      sale.isPaid ? 'Paid' : 'Unpaid',
    ];

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.receipt,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      title: Text(
        sale.listTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(subtitleParts.join(' • ')),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (branchLabel != null && branchLabel!.isNotEmpty) ...[
            BranchCodePill(
              label: branchLabel!,
              tooltip: branchTooltip,
              dense: true,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            currencyFormat.format(sale.totalAmount),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          SaleStatusChip(status: sale.status),
        ],
      ),
    );
  }
}
