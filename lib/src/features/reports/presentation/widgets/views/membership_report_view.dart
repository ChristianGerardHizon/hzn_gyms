import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/breakpoints.dart';
import '../../../../../core/widgets/state/error_state.dart';
import '../../../domain/membership_report.dart';
import '../../../domain/report_period.dart';
import '../../controllers/membership_report_controller.dart';
import '../../controllers/report_period_controller.dart';
import '../charts/bar_chart_widget.dart';
import '../charts/line_chart_widget.dart';
import '../charts/pie_chart_widget.dart';
import '../report_kpi_card.dart';
import '../report_kpi_grid.dart';
import '../report_no_data_card.dart';

/// View displaying the membership lifecycle report.
class MembershipReportView extends ConsumerWidget {
  const MembershipReportView({super.key});

  static final _currencyFormat = NumberFormat.currency(symbol: '₱');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(membershipReportProvider);
    final period = ref.watch(reportPeriodControllerProvider);

    return reportAsync.when(
      data: (report) => _buildContent(context, report, period),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorState.fromError(
        error,
        compact: true,
        onRetry: () => ref.invalidate(membershipReportProvider),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    MembershipReport report,
    ReportPeriodSelection period,
  ) {
    final showTrend = period.period != ReportPeriod.day;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKpiSection(context, report),
          const SizedBox(height: 8),
          Text(
            'Plan value is sold amount from sale lines (or catalog fallback). '
            'Cash collected lives on the Sales tab — do not sum both. '
            'Walk-in / guest day-pass plans are counted in Sales only.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (showTrend) ...[
            const SizedBox(height: 24),
            _buildTrendChart(report),
          ],
          const SizedBox(height: 16),
          _buildDistributionCharts(report),
        ],
      ),
    );
  }

  Widget _buildTrendChart(MembershipReport report) {
    final spots = report.registrationsTrend.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value.toDouble());
    }).toList();

    if (spots.isEmpty || spots.every((s) => s.y <= 0)) {
      return const ReportNoDataCard(
        title: 'No registration trend',
        subtitle: 'There were no new member registrations in this period.',
        icon: Icons.show_chart,
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChartWidget(
          title: 'New Member Registrations',
          spots: spots,
          xLabels: report.registrationsTrend.map((r) => r.label).toList(),
          height: 250,
        ),
      ),
    );
  }

  Widget _buildDistributionCharts(MembershipReport report) {
    final planDistribution = Map<String, num>.fromEntries(
      report.membershipPlanDistribution.entries.where((e) => e.value > 0),
    );
    final revenueByPlan = Map<String, num>.fromEntries(
      report.revenueByPlan.entries.where((e) => e.value > 0),
    );

    final charts = <Widget>[
      if (hasReportChartData(planDistribution))
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: PieChartWidget(
              title: 'Membership Plan Distribution',
              data: planDistribution,
              height: 220,
            ),
          ),
        ),
      if (hasReportChartData(revenueByPlan))
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BarChartWidget(
              title: 'Plan Value by Membership',
              data: revenueByPlan,
              height: 220,
              barColor: Colors.teal,
              valueFormatter: (value) =>
                  _currencyFormat.format(value).replaceAll('.00', ''),
            ),
          ),
        ),
    ];

    if (charts.isEmpty) {
      return const ReportNoDataCard(
        title: 'No membership data',
        subtitle: 'There were no membership sales in this period.',
        icon: Icons.card_membership_outlined,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < Breakpoints.mobile;
        if (isMobile || charts.length == 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < charts.length; i++) ...[
                if (i > 0) const SizedBox(height: 16),
                charts[i],
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < charts.length; i++) ...[
              if (i > 0) const SizedBox(width: 16),
              Expanded(child: charts[i]),
            ],
          ],
        );
      },
    );
  }

  Widget _buildKpiSection(BuildContext context, MembershipReport report) {
    return ReportKpiGrid(
      crossAxisCount: 3,
      children: [
        ReportKpiCard(
          title: 'New Members',
          value: report.totalNewMembers.toString(),
          icon: Icons.person_add_outlined,
          color: Colors.blue,
          subtitle: 'Registered this period',
        ),
        ReportKpiCard(
          title: 'Active Memberships',
          value: report.activeMemberships.toString(),
          icon: Icons.card_membership_outlined,
          color: Colors.green,
          subtitle: 'Currently active',
        ),
        ReportKpiCard(
          title: 'New Subscriptions',
          value: report.newSubscriptions.toString(),
          icon: Icons.fiber_new_outlined,
          color: Colors.indigo,
          subtitle: 'First-time plans',
        ),
        ReportKpiCard(
          title: 'Renewals',
          value: report.renewals.toString(),
          icon: Icons.autorenew,
          color: Colors.cyan,
          subtitle: 'Returning members',
        ),
        ReportKpiCard(
          title: 'Expiring Soon',
          value: report.expiringSoonCount.toString(),
          icon: Icons.schedule,
          color: Colors.orange,
          subtitle: 'Next 7 days',
        ),
        ReportKpiCard(
          title: 'Lapsed',
          value: report.lapsedCount.toString(),
          icon: Icons.trending_down,
          color: Colors.red,
          subtitle: 'Ended without renewal',
        ),
        ReportKpiCard(
          title: 'Plan Value Sold',
          value: _currencyFormat.format(report.membershipRevenue),
          icon: Icons.attach_money,
          color: Colors.teal,
          subtitle: 'Not cash collected',
          featured: true,
        ),
        ReportKpiCard(
          title: 'Add-on Value Sold',
          value: _currencyFormat.format(report.addOnRevenue),
          icon: Icons.add_circle_outline,
          color: Colors.deepOrange,
          subtitle: 'Not cash collected',
        ),
      ],
    );
  }
}
