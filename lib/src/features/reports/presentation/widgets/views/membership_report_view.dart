import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/membership_report.dart';
import '../../controllers/membership_report_controller.dart';
import '../charts/bar_chart_widget.dart';
import '../charts/line_chart_widget.dart';
import '../charts/pie_chart_widget.dart';
import '../report_kpi_card.dart';
import '../report_kpi_grid.dart';

/// View displaying the membership report with charts and tables.
class MembershipReportView extends ConsumerWidget {
  const MembershipReportView({super.key});

  static final _currencyFormat = NumberFormat.currency(symbol: '₱');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(membershipReportProvider);

    return reportAsync.when(
      data: (report) => _buildContent(context, report),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading membership report: $error'),
      ),
    );
  }

  Widget _buildContent(BuildContext context, MembershipReport report) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards
          _buildKpiSection(context, report),
          const SizedBox(height: 24),

          // Member Registration Trend (Line Chart)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LineChartWidget(
                title: 'New Member Registrations',
                spots: report.registrationsByDay.asMap().entries.map((entry) {
                  return FlSpot(
                    entry.key.toDouble(),
                    entry.value.count.toDouble(),
                  );
                }).toList(),
                xLabels: report.registrationsByDay.map((r) {
                  return DateFormat('MMM d').format(r.date);
                }).toList(),
                height: 250,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Charts Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Membership Plan Distribution (Pie Chart)
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: PieChartWidget(
                      title: 'Membership Plan Distribution',
                      data: report.membershipPlanDistribution,
                      height: 220,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Revenue by Plan (Bar Chart)
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: BarChartWidget(
                      title: 'Revenue by Membership Plan',
                      data: report.revenueByPlan,
                      height: 220,
                      barColor: Colors.teal,
                      valueFormatter: (value) =>
                          _currencyFormat.format(value).replaceAll('.00', ''),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
          title: 'Expired / Cancelled',
          value: report.expiredCancelledMemberships.toString(),
          icon: Icons.cancel_outlined,
          color: Colors.red,
          subtitle: 'In selected period',
        ),
        ReportKpiCard(
          title: 'Membership Revenue',
          value: _currencyFormat.format(report.membershipRevenue),
          icon: Icons.attach_money,
          color: Colors.teal,
          subtitle: 'From plan subscriptions',
          featured: true,
        ),
        ReportKpiCard(
          title: 'Add-on Revenue',
          value: _currencyFormat.format(report.addOnRevenue),
          icon: Icons.add_circle_outline,
          color: Colors.orange,
          subtitle: 'From add-on purchases',
        ),
      ],
    );
  }

}
