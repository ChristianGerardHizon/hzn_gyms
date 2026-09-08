import 'package:flutter/material.dart';

/// Color-coded chip showing sale status.
class SaleStatusChip extends StatelessWidget {
  const SaleStatusChip({
    super.key,
    required this.status,
    this.dense = false,
    this.showLabel = false,
  });

  final String status;

  /// Smaller padding/icon for list trailing rows.
  final bool dense;

  /// When true, shows icon + status text (e.g. list trailing under amount).
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _getStatusStyle(status);
    final label = _formatStatus(status);
    final iconSize = dense ? 14.0 : 18.0;

    if (showLabel) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: iconSize),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      );
    }

    final padding = dense ? 4.0 : 8.0;

    return Tooltip(
      message: label,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: dense ? 16.0 : 18.0),
      ),
    );
  }

  (Color, IconData) _getStatusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return (Colors.orange, Icons.schedule);
      case 'awaitingpayment':
        return (Colors.amber, Icons.payment);
      case 'paid':
        return (Colors.green, Icons.check_circle);
      case 'completed':
        return (Colors.green, Icons.check_circle);
      case 'voided':
        return (Colors.red, Icons.cancel);
      case 'refunded':
        return (Colors.orange, Icons.replay);
      default:
        return (Colors.grey, Icons.help);
    }
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'awaitingpayment':
        return 'Awaiting Payment';
      case 'paid':
        return 'Paid';
      case 'completed':
        return 'Completed';
      case 'voided':
        return 'Voided';
      case 'refunded':
        return 'Refunded';
      default:
        return status;
    }
  }
}
