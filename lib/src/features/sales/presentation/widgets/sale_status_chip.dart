import 'package:flutter/material.dart';

/// Color-coded chip showing sale status.
class SaleStatusChip extends StatelessWidget {
  const SaleStatusChip({
    super.key,
    required this.status,
    this.dense = false,
  });

  final String status;

  /// Smaller padding/icon for list trailing rows.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _getStatusStyle(status);
    final padding = dense ? 4.0 : 8.0;
    final iconSize = dense ? 16.0 : 18.0;

    return Tooltip(
      message: _formatStatus(status),
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: iconSize),
      ),
    );
  }

  (Color, IconData) _getStatusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return (Colors.grey, Icons.schedule);
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
