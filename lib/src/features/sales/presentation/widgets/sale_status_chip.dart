import 'package:flutter/material.dart';

/// Color-coded chip showing sale status.
class SaleStatusChip extends StatelessWidget {
  const SaleStatusChip({
    super.key,
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _getStatusStyle(status);

    return Tooltip(
      message: _formatStatus(status),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 18),
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
      case 'refunded':
        return (Colors.orange, Icons.refresh);
      case 'voided':
        return (Colors.red, Icons.cancel);
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
      case 'refunded':
        return 'Refunded';
      case 'voided':
        return 'Voided';
      default:
        return status;
    }
  }
}
