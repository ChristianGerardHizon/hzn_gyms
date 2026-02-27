import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/routes/check_in.routes.dart';
import '../../../../core/routing/routes/members.routes.dart';
import '../../../../core/routing/routes/sales_history.routes.dart';
import '../controllers/active_members_count_controller.dart';
import '../controllers/new_members_controller.dart';
import '../controllers/todays_checkins_controller.dart';
import '../controllers/todays_sales_controller.dart';
import 'kpi_card.dart';

/// Section displaying KPI summary cards on the dashboard.
///
/// Shows:
/// - Today's sales count and total
/// - Today's check-ins
/// - Active members (with active memberships)
/// - New members registered today
class KpiSummarySection extends ConsumerWidget {
  const KpiSummarySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesSummaryAsync = ref.watch(todaySalesSummaryProvider);
    final checkInsAsync = ref.watch(todaysCheckInsCountProvider);
    final activeMembersAsync = ref.watch(activeMembersCountProvider);
    final newMembersAsync = ref.watch(todaysNewMembersCountProvider);

    const spacing = 12.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // First row: Sales + Check-ins
          Row(
            children: [
              Expanded(
                child: salesSummaryAsync.when(
                  data: (summary) => KpiCard(
                    title: "Today's Sales",
                    value: summary.count.toString(),
                    icon: Icons.point_of_sale,
                    subtitle: _formatCurrency(summary.total),
                    compact: true,
                    color: Colors.green,
                    onTap: () => const SalesHistoryRoute().go(context),
                  ),
                  loading: () => _buildLoadingCard(),
                  error: (_, __) => _buildErrorCard(
                    context,
                    "Today's Sales",
                    Icons.point_of_sale,
                  ),
                ),
              ),
              const SizedBox(width: spacing),
              Expanded(
                child: checkInsAsync.when(
                  data: (count) => KpiCard(
                    title: "Today's Check-ins",
                    value: count.toString(),
                    icon: Icons.how_to_reg,
                    subtitle: 'Members checked in',
                    compact: true,
                    color: Colors.teal,
                    onTap: () => const CheckInRoute().go(context),
                  ),
                  loading: () => _buildLoadingCard(),
                  error: (_, __) => _buildErrorCard(
                    context,
                    "Today's Check-ins",
                    Icons.how_to_reg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: spacing),
          // Second row: Active Members + New Members
          Row(
            children: [
              Expanded(
                child: activeMembersAsync.when(
                  data: (count) => KpiCard(
                    title: 'Active Members',
                    value: count.toString(),
                    icon: Icons.card_membership,
                    subtitle: 'With active membership',
                    compact: true,
                    color: Colors.purple,
                    onTap: () => const MembersRoute().go(context),
                  ),
                  loading: () => _buildLoadingCard(),
                  error: (_, __) => _buildErrorCard(
                    context,
                    'Active Members',
                    Icons.card_membership,
                  ),
                ),
              ),
              const SizedBox(width: spacing),
              Expanded(
                child: newMembersAsync.when(
                  data: (count) => KpiCard(
                    title: 'New Members',
                    value: count.toString(),
                    icon: Icons.person_add_outlined,
                    subtitle: 'Registered today',
                    compact: true,
                    color: Colors.blue,
                  ),
                  loading: () => _buildLoadingCard(),
                  error: (_, __) => _buildErrorCard(
                    context,
                    'New Members',
                    Icons.person_add_outlined,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return const Card(
      child: SizedBox(
        height: 76,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: theme.colorScheme.error, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '--',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(num amount) {
    final formatter = NumberFormat.currency(
      symbol: '\u20B1',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
}
