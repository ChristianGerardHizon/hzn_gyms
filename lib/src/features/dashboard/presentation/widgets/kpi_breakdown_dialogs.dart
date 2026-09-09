import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/routes/members.routes.dart';
import '../../../../core/widgets/branch_code_pill.dart';
import '../../../../core/widgets/cached_avatar.dart';
import '../../../check_in/domain/check_in.dart';
import '../../../check_in/presentation/controllers/check_in_controller.dart';
import '../../../members/presentation/controllers/member_provider.dart';
import '../../../memberships/domain/days_remaining_label.dart';
import '../../../memberships/domain/member_membership.dart';
import '../../../pos/domain/sale.dart';
import '../../../settings/presentation/controllers/branches_controller.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../controllers/active_members_count_controller.dart';import '../controllers/new_members_controller.dart';
import '../controllers/todays_sales_controller.dart';
import 'kpi_breakdown_dialog.dart';
import 'sale_quick_view_dialog.dart';
import 'today_sale_list_tile.dart';
import 'todays_sales_breakdown_header.dart';

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
    subtitle: 'Revenue by sale type, payment method, and status',
    bodyBuilder: _todaysSalesBody,
  );
}

Widget _todaysSalesBody(BuildContext context, WidgetRef ref) {
  final salesAsync = ref.watch(todaySalesProvider);
  final summaryAsync = ref.watch(todaySalesSummaryProvider);
  final currency = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
  final viewingAll = ref.watch(viewingAllBranchesProvider);
  final branches = ref.watch(branchesControllerProvider).value ?? const [];
  final labels = branchLabelMaps(branches);
  final summary = summaryAsync.value;
  final theme = Theme.of(context);

  return KpiBreakdownListBody<Sale>(
    asyncValue: salesAsync,
    emptyMessage: 'No sales today',
    emptyIcon: Icons.point_of_sale_outlined,
    onRetry: () {
      ref.invalidate(todaySalesProvider);
      ref.invalidate(todaySalesSummaryProvider);
    },
    listHeader: Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        'Transactions',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    summaryHeaderBuilder: (sales) {
      // Prefer server aggregate for totals; list is capped at 50.
      final total = summary?.total ??
          sales.fold<num>(0, (sum, s) => sum + s.totalAmount);
      final txnCount = summary?.count ?? sales.length;
      final paid = sales.where((s) => s.isPaid).length;
      final unpaid = sales.length - paid;

      final paymentLabels = <String, String>{
        for (final e in (summary?.revenueByPaymentMethod ?? const {}).entries)
          e.key: currency.format(e.value),
      };
      return TodaysSalesBreakdownHeader(
        revenueLabel: currency.format(total),
        transactionCount: txnCount,
        membershipTotalLabel: currency.format(summary?.membershipTotal ?? 0),
        membershipCount: summary?.membershipCount ?? 0,
        walkInTotalLabel: currency.format(summary?.walkInTotal ?? 0),
        walkInCount: summary?.walkInCount ?? 0,
        productTotalLabel: currency.format(summary?.productTotal ?? 0),
        productCount: summary?.productCount ?? 0,
        paymentMethodTotalLabels: paymentLabels,
        paymentMethodCounts:
            summary?.transactionCountByPaymentMethod ?? const {},
        paidCount: paid,
        unpaidCount: unpaid,
        branchChips: viewingAll
            ? _branchSalesLabels(
                rows: summary?.byBranch ?? const [],
                codeById: labels.codeById,
                nameById: labels.nameById,
                fallbackBranchIds: sales.map((s) => s.branchId),
              )
            : const [],
      );
    },
    itemBuilder: (context, sale) {
      final code = viewingAll ? labels.codeById[sale.branchId] : null;
      final name = viewingAll ? labels.nameById[sale.branchId] : null;
      return TodaySaleListTile(
        sale: sale,
        branchLabel: code ?? (viewingAll ? sale.branchId : null),
        branchTooltip: name,
        onTap: () => showSaleQuickViewDialog(
          context,
          saleId: sale.id,
          fallbackSale: sale,
        ),
      );
    },
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
      final viewingAll = ref.watch(viewingAllBranchesProvider);
      final branches = ref.watch(branchesControllerProvider).value ?? const [];
      final labels = branchLabelMaps(branches);

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
            if (viewingAll)
              ..._branchCountChips(
                branchIds: checkIns.map((c) => c.branchId),
                codeById: labels.codeById,
                nameById: labels.nameById,
                color: Colors.indigo,
              ),
          ];
        },
        itemBuilder: (context, checkIn) {
          final theme = Theme.of(context);
          final branchPill = viewingAll
              ? BranchCodePill.fromBranches(
                  branchId: checkIn.branchId,
                  branches: branches,
                  dense: true,
                )
              : null;
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
                trailing: branchPill,
                onTap: () {
                  // Root-navigator dialogs sit outside RouteBase.builder, so
                  // GoRouterState.of(context) throws. Read the org/branch
                  // scope from the router's current path instead, mirroring
                  // `OrgScopedGoRouteData._scopedLocation`.
                  final router = GoRouter.of(context);
                  final segments = router.state.uri.pathSegments;
                  final memberLocation = MemberDetailRoute(
                    id: checkIn.memberId,
                  ).location;
                  final location = segments.length >= 2
                      ? '/${segments[0]}/${segments[1]}$memberLocation'
                      : memberLocation;
                  Navigator.of(context).pop();
                  router.go(location);
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
      final viewingAll = ref.watch(viewingAllBranchesProvider);
      final branches = ref.watch(branchesControllerProvider).value ?? const [];
      final labels = branchLabelMaps(branches);

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
            if (viewingAll)
              ..._branchCountChips(
                branchIds: memberships.map((m) => m.branchId),
                codeById: labels.codeById,
                nameById: labels.nameById,
                color: Colors.indigo,
              ),
          ];
        },
        itemBuilder: (context, membership) {
          final theme = Theme.of(context);
          final days = membership.daysRemaining;
          final branchPill = viewingAll
              ? BranchCodePill.fromBranches(
                  branchId: membership.branchId,
                  branches: branches,
                  dense: true,
                )
              : null;
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
                formatDaysRemainingLabel(days),
              ].join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: branchPill,
            onTap: () {
              // Root-navigator dialogs sit outside RouteBase.builder, so
              // GoRouterState.of(context) throws. Read the org/branch scope
              // from the router's current path instead, mirroring
              // `OrgScopedGoRouteData._scopedLocation`.
              final router = GoRouter.of(context);
              final segments = router.state.uri.pathSegments;
              final memberLocation = MemberDetailRoute(
                id: membership.memberId,
              ).location;
              final location = segments.length >= 2
                  ? '/${segments[0]}/${segments[1]}$memberLocation'
                  : memberLocation;
              Navigator.of(context).pop();
              router.go(location);
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
      final viewingAll = ref.watch(viewingAllBranchesProvider);
      final branches = ref.watch(branchesControllerProvider).value ?? const [];
      final labels = branchLabelMaps(branches);

      return KpiBreakdownListBody<NewMemberEntry>(
        asyncValue: listAsync,
        emptyMessage: 'No new members today',
        emptyIcon: Icons.person_add_outlined,
        onRetry: () => ref.invalidate(todaysNewMembersListProvider),
        summaryBuilder: (entries) => [
          KpiSummaryChipData(
            label: 'Registered today',
            value: entries.length.toString(),
            color: Colors.blue,
          ),
          if (viewingAll)
            ..._branchCountChips(
              branchIds: entries
                  .map((e) => e.effectiveBranchId)
                  .whereType<String>()
                  .where((id) => id.isNotEmpty),
              codeById: labels.codeById,
              nameById: labels.nameById,
              color: Colors.indigo,
            ),
        ],
        itemBuilder: (context, entry) {
          final member = entry.member;
          final theme = Theme.of(context);
          final registeredAt = member.created != null
              ? timeFormat.format(member.created!)
              : null;
          final subtitleParts = <String>[
            if (member.mobileNumber != null && member.mobileNumber!.isNotEmpty)
              member.mobileNumber!,
            if (registeredAt != null) registeredAt,
          ];
          final planName = entry.membership?.membershipName;
          final branchPill = viewingAll
              ? BranchCodePill.fromBranches(
                  branchId: entry.effectiveBranchId,
                  branches: branches,
                  dense: true,
                )
              : null;

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
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (planName != null && planName.isNotEmpty)
                  Text(
                    planName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (branchPill != null) branchPill,
              ],
            ),
            onTap: () {
              // Root-navigator dialogs sit outside RouteBase.builder, so
              // GoRouterState.of(context) throws. Read the org/branch scope
              // from the router's current path instead, mirroring
              // `OrgScopedGoRouteData._scopedLocation`.
              final router = GoRouter.of(context);
              final segments = router.state.uri.pathSegments;
              final memberLocation = MemberDetailRoute(id: member.id).location;
              final location = segments.length >= 2
                  ? '/${segments[0]}/${segments[1]}$memberLocation'
                  : memberLocation;
              Navigator.of(context).pop();
              router.go(location);
            },
          );
        },
      );
    },
  );
}

List<String> _branchSalesLabels({
  required List<TodaysSalesBranchRow> rows,
  required Map<String, String> codeById,
  required Map<String, String> nameById,
  required Iterable<String> fallbackBranchIds,
}) {
  if (rows.isNotEmpty) {
    final sorted = [...rows]
      ..sort((a, b) => b.transactionCount.compareTo(a.transactionCount));
    return [
      for (final row in sorted)
        '${codeById[row.branchId] ?? nameById[row.branchId] ?? row.branchId}'
        ' · ${row.transactionCount}',
    ];
  }

  final counts = <String, int>{};
  for (final id in fallbackBranchIds) {
    if (id.isEmpty) continue;
    counts[id] = (counts[id] ?? 0) + 1;
  }
  if (counts.isEmpty) return const [];

  final entries = counts.entries.toList()
    ..sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      if (byCount != 0) return byCount;
      final aLabel = codeById[a.key] ?? nameById[a.key] ?? a.key;
      final bLabel = codeById[b.key] ?? nameById[b.key] ?? b.key;
      return aLabel.compareTo(bLabel);
    });

  return [
    for (final e in entries)
      '${codeById[e.key] ?? nameById[e.key] ?? e.key} · ${e.value}',
  ];
}

List<KpiSummaryChipData> _branchCountChips({
  required Iterable<String> branchIds,
  required Map<String, String> codeById,
  required Map<String, String> nameById,
  required Color color,
}) {
  final counts = <String, int>{};
  for (final id in branchIds) {
    if (id.isEmpty) continue;
    counts[id] = (counts[id] ?? 0) + 1;
  }
  if (counts.isEmpty) return const [];

  final entries = counts.entries.toList()
    ..sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      if (byCount != 0) return byCount;
      final aLabel = codeById[a.key] ?? nameById[a.key] ?? a.key;
      final bLabel = codeById[b.key] ?? nameById[b.key] ?? b.key;
      return aLabel.compareTo(bLabel);
    });

  return [
    for (final e in entries)
      KpiSummaryChipData(
        label: codeById[e.key] ?? nameById[e.key] ?? e.key,
        value: e.value.toString(),
        color: color,
      ),
  ];
}
