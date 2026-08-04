import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/routes/members.routes.dart';
import '../../../../core/widgets/cached_avatar.dart';
import '../../../check_in/domain/check_in.dart';
import '../../../check_in/presentation/controllers/check_in_controller.dart';
import '../../../members/domain/member.dart';
import '../../../members/presentation/controllers/member_provider.dart';
import '../../../memberships/domain/member_membership.dart';
import '../../../pos/domain/sale.dart';
import '../controllers/active_members_count_controller.dart';
import '../controllers/new_members_controller.dart';
import '../controllers/todays_sales_controller.dart';
import 'kpi_breakdown_dialog.dart';
import 'sale_quick_view_dialog.dart';
import 'today_sale_list_tile.dart';

/// Opens today's full transactions dialog (View All from Recent Transactions).
Future<void> showTodaysTransactionsDialog(BuildContext context) {
  return showKpiBreakdownDialog(
    context: context,
    title: "Today's Transactions",
    bodyBuilder: _todaysSalesBody,
  );
}

/// Opens today's sales KPI breakdown dialog.
Future<void> showTodaysSalesBreakdownDialog(BuildContext context) {
  return showKpiBreakdownDialog(
    context: context,
    title: "Today's Sales",
    subtitle: 'Breakdown by payment status',
    bodyBuilder: _todaysSalesBody,
  );
}

Widget _todaysSalesBody(BuildContext context, WidgetRef ref) {
  final salesAsync = ref.watch(todaySalesProvider);
  final currency = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

  return KpiBreakdownListBody<Sale>(
    asyncValue: salesAsync,
    emptyMessage: 'No sales today',
    emptyIcon: Icons.point_of_sale_outlined,
    onRetry: () => ref.invalidate(todaySalesProvider),
    summaryBuilder: (sales) {
      final total = sales.fold<num>(0, (sum, s) => sum + s.totalAmount);
      final paid = sales.where((s) => s.isPaid).length;
      final unpaid = sales.length - paid;
      return [
        KpiSummaryChipData(
          label: 'Revenue',
          value: currency.format(total),
          color: Colors.green,
        ),
        KpiSummaryChipData(
          label: 'Transactions',
          value: sales.length.toString(),
          color: Colors.green.shade700,
        ),
        KpiSummaryChipData(
          label: 'Paid',
          value: paid.toString(),
          color: Colors.teal,
        ),
        KpiSummaryChipData(
          label: 'Unpaid',
          value: unpaid.toString(),
          color: Colors.orange,
        ),
      ];
    },
    itemBuilder: (context, sale) => TodaySaleListTile(
      sale: sale,
      onTap: () => showSaleQuickViewDialog(
        context,
        saleId: sale.id,
        fallbackSale: sale,
      ),
    ),
  );
}

/// Opens today's check-ins KPI breakdown dialog.
Future<void> showTodaysCheckInsBreakdownDialog(BuildContext context) {
  return showKpiBreakdownDialog(
    context: context,
    title: "Today's Check-ins",
    subtitle: 'Breakdown by check-in method',
    bodyBuilder: (context, ref) {
      final checkInsAsync = ref.watch(checkInControllerProvider);
      final timeFormat = DateFormat('hh:mm a');

      return KpiBreakdownListBody<CheckIn>(
        asyncValue: checkInsAsync,
        emptyMessage: 'No check-ins today',
        emptyIcon: Icons.how_to_reg_outlined,
        onRetry: () => ref.read(checkInControllerProvider.notifier).refresh(),
        summaryBuilder: (checkIns) {
          final manual = checkIns
              .where((c) => c.method == CheckInMethod.manual)
              .length;
          final rfid = checkIns
              .where((c) => c.method == CheckInMethod.rfid)
              .length;
          return [
            KpiSummaryChipData(
              label: 'Total',
              value: checkIns.length.toString(),
              color: Colors.teal,
            ),
            KpiSummaryChipData(
              label: 'Manual',
              value: manual.toString(),
              color: Colors.blueGrey,
            ),
            KpiSummaryChipData(
              label: 'RFID',
              value: rfid.toString(),
              color: Colors.teal.shade700,
            ),
          ];
        },
        itemBuilder: (context, checkIn) {
          final theme = Theme.of(context);
          return Consumer(
            builder: (context, ref, _) {
              final memberAsync = ref.watch(memberProvider(checkIn.memberId));
              return ListTile(
                leading: CachedAvatar(
                  imageUrl: memberAsync.value?.photo,
                  radius: 20,
                  thumbSize: 80,
                ),
                title: Text(checkIn.memberName ?? 'Unknown Member'),
                subtitle: Text(
                  '${timeFormat.format(checkIn.checkInTime)} · ${checkIn.method.displayName}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  MemberDetailRoute(id: checkIn.memberId).go(context);
                },
              );
            },
          );
        },
      );
    },
  );
}

/// Opens active members KPI breakdown dialog.
Future<void> showActiveMembersBreakdownDialog(BuildContext context) {
  return showKpiBreakdownDialog(
    context: context,
    title: 'Active Members',
    subtitle: 'Active memberships by plan',
    bodyBuilder: (context, ref) {
      final listAsync = ref.watch(activeMembersListProvider);
      final dateFormat = DateFormat.MMMd();

      return KpiBreakdownListBody<MemberMembership>(
        asyncValue: listAsync,
        emptyMessage: 'No active memberships',
        emptyIcon: Icons.card_membership_outlined,
        onRetry: () => ref.invalidate(activeMembersListProvider),
        summaryBuilder: (memberships) {
          final byPlan = <String, int>{};
          for (final m in memberships) {
            final plan = m.membershipName?.trim().isNotEmpty == true
                ? m.membershipName!
                : 'Unknown plan';
            byPlan[plan] = (byPlan[plan] ?? 0) + 1;
          }
          final planEntries = byPlan.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final planChips = planEntries
              .map(
                (e) => KpiSummaryChipData(
                  label: e.key,
                  value: e.value.toString(),
                  color: Colors.purple,
                ),
              )
              .toList();

          return [
            KpiSummaryChipData(
              label: 'Total',
              value: memberships.length.toString(),
              color: Colors.purple.shade700,
            ),
            ...planChips,
          ];
        },
        itemBuilder: (context, membership) {
          final theme = Theme.of(context);
          final days = membership.daysRemaining;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple.withValues(alpha: 0.15),
              child: Text(
                (membership.memberName ?? '?').isNotEmpty
                    ? membership.memberName![0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(membership.memberName ?? 'Unknown Member'),
            subtitle: Text(
              [
                membership.membershipName ?? 'Unknown plan',
                'Ends ${dateFormat.format(membership.endDate)}',
                days == 0 ? 'Expires today' : '$days days left',
              ].join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            onTap: () {
              Navigator.of(context).pop();
              MemberDetailRoute(id: membership.memberId).go(context);
            },
          );
        },
      );
    },
  );
}

/// Opens new members KPI breakdown dialog.
Future<void> showNewMembersBreakdownDialog(BuildContext context) {
  return showKpiBreakdownDialog(
    context: context,
    title: 'New Members',
    subtitle: 'Registered today',
    bodyBuilder: (context, ref) {
      final listAsync = ref.watch(todaysNewMembersListProvider);
      final timeFormat = DateFormat('hh:mm a');

      return KpiBreakdownListBody<Member>(
        asyncValue: listAsync,
        emptyMessage: 'No new members today',
        emptyIcon: Icons.person_add_outlined,
        onRetry: () => ref.invalidate(todaysNewMembersListProvider),
        summaryBuilder: (members) => [
          KpiSummaryChipData(
            label: 'Registered today',
            value: members.length.toString(),
            color: Colors.blue,
          ),
        ],
        itemBuilder: (context, member) {
          final theme = Theme.of(context);
          final registeredAt = member.created != null
              ? timeFormat.format(member.created!)
              : null;
          final subtitleParts = <String>[
            if (member.mobileNumber != null && member.mobileNumber!.isNotEmpty)
              member.mobileNumber!,
            if (registeredAt != null) registeredAt,
          ];

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withValues(alpha: 0.15),
              child: Text(
                member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(member.name),
            subtitle: subtitleParts.isEmpty
                ? null
                : Text(
                    subtitleParts.join(' · '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
            onTap: () {
              Navigator.of(context).pop();
              MemberDetailRoute(id: member.id).go(context);
            },
          );
        },
      );
    },
  );
}
