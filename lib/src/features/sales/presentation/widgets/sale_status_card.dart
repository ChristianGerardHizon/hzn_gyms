import 'package:flutter/material.dart';

/// Card displaying sale status with icon, title, and description.
class SaleStatusCard extends StatelessWidget {
  const SaleStatusCard({
    super.key,
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (color, icon, title, description) = _getStatusInfo(status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (Color, IconData, String, String) _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return (
          Colors.grey,
          Icons.schedule,
          'Pending',
          'This sale is pending',
        );
      case 'awaitingpayment':
        return (
          Colors.amber,
          Icons.payment,
          'Awaiting Payment',
          'This sale is awaiting payment',
        );
      case 'paid':
        return (
          Colors.green,
          Icons.check_circle,
          'Paid',
          'This sale has been fully paid',
        );
      case 'completed':
        return (
          Colors.green,
          Icons.check_circle,
          'Completed',
          'This sale has been successfully completed',
        );
      case 'refunded':
        return (
          Colors.orange,
          Icons.refresh,
          'Refunded',
          'This sale has been refunded to the customer',
        );
      case 'voided':
        return (
          Colors.red,
          Icons.cancel,
          'Voided',
          'This sale has been voided and cancelled',
        );
      default:
        return (
          Colors.grey,
          Icons.help,
          status,
          'Unknown status',
        );
    }
  }
}
