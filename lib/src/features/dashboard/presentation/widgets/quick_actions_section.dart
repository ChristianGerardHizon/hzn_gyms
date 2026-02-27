import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/routing/routes/check_in.routes.dart';
import '../../../../core/routing/routes/sales.routes.dart';
import '../../../members/presentation/widgets/member_form_dialog.dart';
import '../../../sales/presentation/widgets/record_payment_sheet.dart';

/// Section displaying quick action buttons on the dashboard.
///
/// Provides fast access to common tasks:
/// - Open POS/Cashier
/// - Show dashboard overview (tablet only)
class QuickActionsSection extends ConsumerWidget {
  const QuickActionsSection({
    super.key,
    this.onShowOverview,
  });

  /// Optional callback to show the dashboard overview (clears selection).
  /// Only shown when this callback is provided (tablet layout).
  final VoidCallback? onShowOverview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Show Dashboard Overview button only on tablet
                if (onShowOverview != null) ...[
                  _QuickActionButton(
                    icon: Icons.dashboard,
                    label: 'Overview',
                    color: Theme.of(context).colorScheme.primary,
                    onTap: onShowOverview!,
                  ),
                  const SizedBox(width: 12),
                ],
                _QuickActionButton(
                  icon: Icons.how_to_reg,
                  label: 'Check-In',
                  color: Colors.teal,
                  onTap: () => const CheckInRoute().go(context),
                ),
                const SizedBox(width: 12),
                _QuickActionButton(
                  icon: Icons.point_of_sale,
                  label: 'New Sale',
                  color: Colors.green,
                  onTap: () => const SalesRoute().go(context),
                ),
                const SizedBox(width: 12),
                _QuickActionButton(
                  icon: Icons.person_add,
                  label: 'New Member',
                  color: Colors.blue,
                  onTap: () async {
                    final result = await showMemberFormDialog(context);
                    if (result?.sale != null &&
                        result?.totalPrice != null &&
                        context.mounted) {
                      await showRecordPaymentSheet(
                        context,
                        sale: result!.sale!,
                        balanceDue: result.totalPrice!,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
