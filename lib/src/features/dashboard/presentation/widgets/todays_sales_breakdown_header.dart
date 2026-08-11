import 'package:flutter/material.dart';

/// Structured summary header for the Today's Sales breakdown dialog.
///
/// Layout:
/// 1. Hero revenue + transaction count
/// 2. Memberships / Walk-ins / Products split cards
/// 3. Paid / Unpaid status row
/// 4. Optional branch pills when viewing all branches
class TodaysSalesBreakdownHeader extends StatelessWidget {
  const TodaysSalesBreakdownHeader({
    super.key,
    required this.revenueLabel,
    required this.transactionCount,
    required this.membershipTotalLabel,
    required this.membershipCount,
    required this.walkInTotalLabel,
    required this.walkInCount,
    required this.productTotalLabel,
    required this.productCount,
    required this.paidCount,
    required this.unpaidCount,
    this.branchChips = const [],
  });

  final String revenueLabel;
  final int transactionCount;
  final String membershipTotalLabel;
  final int membershipCount;
  final String walkInTotalLabel;
  final int walkInCount;
  final String productTotalLabel;
  final int productCount;
  final int paidCount;
  final int unpaidCount;

  /// Small branch labels (e.g. "BCD · 2") when viewing all branches.
  final List<String> branchChips;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onVariant = theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero revenue
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Revenue',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: onVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      revenueLabel,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.green.shade600,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$transactionCount ${transactionCount == 1 ? 'sale' : 'sales'}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: onVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Sale-type split (wraps on narrow dialog widths)
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 10.0;
              final useRow = constraints.maxWidth >= 420;
              final cards = [
                _TypeCard(
                  label: 'Memberships',
                  amount: membershipTotalLabel,
                  count: membershipCount,
                  color: Colors.purple,
                ),
                _TypeCard(
                  label: 'Walk-ins',
                  amount: walkInTotalLabel,
                  count: walkInCount,
                  color: Colors.indigo,
                ),
                _TypeCard(
                  label: 'Products',
                  amount: productTotalLabel,
                  count: productCount,
                  color: Colors.teal,
                ),
              ];

              if (useRow) {
                return Row(
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      if (i > 0) const SizedBox(width: gap),
                      Expanded(child: cards[i]),
                    ],
                  ],
                );
              }

              final cardWidth = (constraints.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final card in cards)
                    SizedBox(width: cardWidth, child: card),
                ],
              );
            },
          ),
          const SizedBox(height: 12),

          // Payment status
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusPill(
                label: 'Paid',
                count: paidCount,
                color: Colors.teal,
                filled: true,
              ),
              _StatusPill(
                label: 'Unpaid',
                count: unpaidCount,
                color: Colors.orange,
                filled: unpaidCount > 0,
              ),
              for (final chip in branchChips)
                _BranchPill(label: chip),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.label,
    required this.amount,
    required this.count,
    required this.color,
  });

  final String label;
  final String amount;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$count ${count == 1 ? 'sale' : 'sales'}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.count,
    required this.color,
    required this.filled,
  });

  final String label;
  final int count;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = filled
        ? color.withValues(alpha: 0.12)
        : theme.colorScheme.surfaceContainerHighest;
    final fg = filled ? color : theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            filled ? Icons.check_circle : Icons.schedule,
            size: 14,
            color: fg,
          ),
          const SizedBox(width: 6),
          Text(
            '$count $label',
            style: theme.textTheme.labelMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchPill extends StatelessWidget {
  const _BranchPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.indigo.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: Colors.indigo.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
