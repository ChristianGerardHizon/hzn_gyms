import 'package:flutter/material.dart';

/// A prominent banner that highlights the most important status of a sale.
///
/// Priority logic:
/// 1. Refunded - special case, always show prominently
/// 2. Voided - cancelled sale
/// 3. Pending + Unpaid - payment pending
/// 4. Pending + Paid - payment received
/// 5. Completed + Unpaid - unusual case, awaiting payment
/// 6. Completed + Paid - fully completed
class SaleHighlightBanner extends StatelessWidget {
  const SaleHighlightBanner({
    super.key,
    required this.isPaid,
    required this.saleStatus,
  });

  final bool isPaid;
  final String saleStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlight = _getHighlight();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            highlight.color.withValues(alpha: 0.15),
            highlight.color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight.color.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: highlight.color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              highlight.icon,
              color: highlight.color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  highlight.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: highlight.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  highlight.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (highlight.secondaryInfo != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        highlight.secondaryIcon ?? Icons.info_outline,
                        size: 16,
                        color: highlight.secondaryColor ??
                            theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        highlight.secondaryInfo!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: highlight.secondaryColor ??
                              theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  _HighlightInfo _getHighlight() {
    final status = saleStatus.toLowerCase();

    // Priority 1: Refunded sale
    if (status == 'refunded') {
      return _HighlightInfo(
        color: Colors.orange,
        icon: Icons.replay,
        title: 'Refunded',
        description: 'This sale has been refunded to the customer.',
      );
    }

    // Priority 2: Voided sale
    if (status == 'voided') {
      return _HighlightInfo(
        color: Colors.red,
        icon: Icons.cancel,
        title: 'Voided',
        description: 'This sale has been voided and cancelled.',
      );
    }

    // Priority 3: Pending
    if (status == 'pending') {
      return _HighlightInfo(
        color: Colors.grey,
        icon: Icons.schedule,
        title: 'Pending',
        description: 'This sale is pending.',
      );
    }

    // Priority 4: Awaiting Payment
    if (status == 'awaitingpayment') {
      return _HighlightInfo(
        color: Colors.amber.shade700,
        icon: Icons.payment,
        title: 'Awaiting Payment',
        description: 'This sale is awaiting full payment.',
        secondaryInfo: 'Partial payment received',
        secondaryIcon: Icons.pending,
        secondaryColor: Colors.orange,
      );
    }

    // Priority 5: Paid
    if (status == 'paid' || (status == 'completed' && isPaid)) {
      return _HighlightInfo(
        color: Colors.green,
        icon: Icons.task_alt,
        title: 'Paid',
        description: 'This sale has been fully paid.',
        secondaryInfo: 'Fully paid',
        secondaryIcon: Icons.paid,
        secondaryColor: Colors.green,
      );
    }

    // Default fallback
    return _HighlightInfo(
      color: Colors.grey,
      icon: Icons.receipt_long,
      title: 'Sale',
      description: 'View sale details below.',
    );
  }
}

class _HighlightInfo {
  const _HighlightInfo({
    required this.color,
    required this.icon,
    required this.title,
    required this.description,
    this.secondaryInfo,
    this.secondaryIcon,
    this.secondaryColor,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String description;
  final String? secondaryInfo;
  final IconData? secondaryIcon;
  final Color? secondaryColor;
}
