import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/permissions/current_user_permissions.dart';
import '../../../../core/routing/routes/check_in.routes.dart';
import '../../../members/presentation/widgets/member_form_dialog.dart';
import '../../../members/presentation/widgets/member_picker_dialog.dart';
import '../../../memberships/presentation/widgets/purchase_membership_dialog.dart';
import '../../../pos/presentation/components/cashier_dialog.dart';
import 'dashboard_member_search_flow.dart';
import 'todays_activity_logs_dialog.dart';

/// Section displaying quick action buttons on the dashboard.
///
/// Provides fast access to common tasks:
/// - Cashier (product POS dialog)
/// - Walk-in (day pass / name-only sale for plans with membership not required)
/// - Show dashboard overview (tablet only)
class QuickActionsSection extends ConsumerWidget {
  const QuickActionsSection({super.key, this.onShowOverview});

  /// Optional callback to show the dashboard overview (clears selection).
  /// Only shown when this callback is provided (tablet layout).
  final VoidCallback? onShowOverview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canViewActivityLog =
        ref.watch(currentUserPermissionsProvider).value?.canViewActivityLog ??
        false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
                  icon: Icons.storefront,
                  label: 'Cashier',
                  color: Colors.green,
                  onTap: () => showCashierDialog(context, ref),
                ),
                const SizedBox(width: 12),
                _QuickActionButton(
                  icon: Icons.directions_walk,
                  label: 'Walk-in',
                  color: Colors.indigo,
                  onTap: () => sellWalkInAndRecordPayment(context),
                ),
                const SizedBox(width: 12),
                _QuickActionButton(
                  icon: Icons.autorenew,
                  label: 'Renew',
                  color: Colors.deepOrange,
                  onTap: () async {
                    final member = await showMemberPickerDialog(
                      context,
                      title: 'Renew Membership',
                      subtitle: 'Select a member to renew',
                    );
                    if (member == null || !context.mounted) return;

                    await purchaseMembershipAndRecordPayment(
                      context,
                      memberId: member.id,
                      memberName: member.name,
                      isRenewal: true,
                    );
                  },
                ),
                const SizedBox(width: 12),
                _QuickActionButton(
                  icon: Icons.person_search,
                  label: 'Search Member',
                  color: Colors.purple,
                  onTap: () => searchMemberFromDashboard(context, ref),
                ),
                const SizedBox(width: 12),
                _QuickActionButton(
                  icon: Icons.person_add,
                  label: 'New Member',
                  color: Colors.blue,
                  onTap: () async {
                    final result = await showMemberFormDialog(context);
                    if (context.mounted) {
                      await handleMemberFormPaymentResult(context, result);
                    }
                  },
                ),
                if (canViewActivityLog) ...[
                  const SizedBox(width: 12),
                  _QuickActionButton(
                    icon: Icons.history,
                    label: "Today's Logs",
                    color: Colors.blueGrey,
                    onTap: () => showTodaysActivityLogsDialog(context),
                  ),
                ],
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
              Icon(icon, color: color, size: 20),
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
