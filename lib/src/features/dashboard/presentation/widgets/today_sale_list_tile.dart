import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../pos/domain/sale.dart';
import '../../../sales/presentation/widgets/sale_list_tile.dart';

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
    final timeFormat = showDate
        ? DateFormat('MMM d · hh:mm a')
        : DateFormat('hh:mm a');

    return SaleListTile(
      sale: sale,
      onTap: onTap,
      dateFormat: timeFormat,
      branchLabel: branchLabel,
      branchTooltip: branchTooltip,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    );
  }
}
