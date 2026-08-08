import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../core/utils/breakpoints.dart';
import '../../../../../core/widgets/state/error_state.dart';
import '../../../domain/attendance_report.dart';
import '../../../domain/report_period.dart';
import '../../controllers/attendance_report_controller.dart';
import '../../controllers/report_period_controller.dart';
import '../charts/bar_chart_widget.dart';
import '../charts/line_chart_widget.dart';
import '../charts/pie_chart_widget.dart';
import '../report_kpi_card.dart';
import '../report_kpi_grid.dart';
import '../report_no_data_card.dart';

/// View displaying the attendance / check-ins report.
class AttendanceReportView extends ConsumerWidget {
  const AttendanceReportView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(attendanceReportProvider);
    final period = ref.watch(reportPeriodControllerProvider);

    return reportAsync.when(
      data: (report) => _buildContent(context, report, period),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorState.fromError(
        error,
        compact: true,
        onRetry: () => ref.invalidate(attendanceReportProvider),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AttendanceReport report,
    ReportPeriodSelection period,
  ) {
    final showPeakHours =
        period.period == ReportPeriod.day && report.checkInsByHour.isNotEmpty;
    final showTrend = period.period != ReportPeriod.day;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReportKpiGrid(
            crossAxisCount: 3,
            children: [
              ReportKpiCard(
                title: 'Total Check-ins',
                value: report.totalCheckIns.toString(),
                icon: Icons.login,
                color: Colors.indigo,
                subtitle: 'For selected period',
                featured: true,
              ),
              ReportKpiCard(
                title: 'Unique Members',
                value: report.uniqueMembers.toString(),
                icon: Icons.people_outline,
                color: Colors.teal,
                subtitle: 'Distinct visitors',
              ),
              if (period.period == ReportPeriod.day)
                ReportKpiCard(
                  title: 'No Active Membership',
                  value: report.withoutActiveMembershipCount.toString(),
                  icon: Icons.warning_amber_outlined,
                  color: Colors.orange,
                  subtitle: 'Check-ins without membership link',
                ),
            ],
          ),
          if (showTrend) ...[
            const SizedBox(height: 24),
            _buildTrendChart(report),
          ],
          const SizedBox(height: 16),
          _buildDistributionCharts(
            report,
            showPeakHours: showPeakHours,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart(AttendanceReport report) {
    final spots = report.checkInsTrend.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value.toDouble());
    }).toList();

    if (spots.isEmpty || spots.every((s) => s.y <= 0)) {
      return const ReportNoDataCard(
        title: 'No check-in trend',
        subtitle: 'There were no check-ins in this period.',
        icon: Icons.show_chart,
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChartWidget(
          title: 'Check-ins Trend',
          spots: spots,
          xLabels: report.checkInsTrend.map((r) => r.label).toList(),
          height: 250,
        ),
      ),
    );
  }

  Widget _buildDistributionCharts(
    AttendanceReport report, {
    required bool showPeakHours,
  }) {
    final methodData = Map<String, num>.fromEntries(
      report.checkInsByMethod.entries.where((e) => e.value > 0),
    );
    final hourData = showPeakHours
        ? Map<String, num>.fromEntries(
            report.checkInsByHour.entries.where((e) => e.value > 0),
          )
        : const <String, num>{};

    final charts = <Widget>[
      if (hasReportChartData(methodData))
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: PieChartWidget(
              title: 'Check-ins by Method',
              data: methodData,
              height: 220,
            ),
          ),
        ),
      if (hasReportChartData(hourData))
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BarChartWidget(
              title: 'Peak Hours',
              data: hourData,
              height: 220,
              barColor: Colors.indigo,
            ),
          ),
        ),
    ];

    if (charts.isEmpty) {
      return const ReportNoDataCard(
        title: 'No check-in data',
        subtitle: 'There were no check-ins in this period.',
        icon: Icons.login,
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
}
