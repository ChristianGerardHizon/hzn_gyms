import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/sales_report.dart';
import '../../controllers/sales_report_controller.dart';
import '../charts/bar_chart_widget.dart';
import '../charts/line_chart_widget.dart';
import '../charts/pie_chart_widget.dart';
import '../report_kpi_card.dart';
import '../report_kpi_grid.dart';

/// View displaying the sales report with charts and tables.
class SalesReportView extends ConsumerWidget {
  const SalesReportView({super.key});

  static final _currencyFormat = NumberFormat.currency(symbol: '₱');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(salesReportProvider);

    return reportAsync.when(
      data: (report) => _buildContent(context, report),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading sales report: $error'),
      ),
    );
  }

  Widget _buildContent(BuildContext context, SalesReport report) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards
          _buildKpiSection(context, report),
          const SizedBox(height: 24),

          // Revenue Trend Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LineChartWidget(
                title: 'Revenue Trend',
                spots: report.revenueByDay.asMap().entries.map((entry) {
                  return FlSpot(
                    entry.key.toDouble(),
                    entry.value.amount.toDouble(),
                  );
                }).toList(),
                xLabels: report.revenueByDay.map((r) {
                  return DateFormat('MMM d').format(r.date);
                }).toList(),
                yAxisFormatter: (value) =>
                    _currencyFormat.format(value).replaceAll('.00', ''),
                height: 250,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Charts Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Method Pie Chart
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: PieChartWidget(
                      title: 'Revenue by Payment Method',
                      data: report.revenueByPaymentMethod,
                      height: 200,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Top Products Bar Chart
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: BarChartWidget(
                      title: 'Top Products by Revenue',
                      data: Map.fromEntries(
                        report.topSellingProducts.take(5).map(
                              (p) => MapEntry(p.productName, p.revenue),
                            ),
                      ),
                      height: 200,
                      valueFormatter: (value) =>
                          _currencyFormat.format(value).replaceAll('.00', ''),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Top Products Table
          _buildTopProductsTable(context, report),
        ],
      ),
    );
  }

  Widget _buildKpiSection(BuildContext context, SalesReport report) {
    return ReportKpiGrid(
      crossAxisCount: 3,
      children: [
        ReportKpiCard(
          title: 'Total Revenue',
          value: _currencyFormat.format(report.totalRevenue),
          icon: Icons.attach_money,
          color: Colors.green,
          subtitle: 'For selected period',
          featured: true,
        ),
        ReportKpiCard(
          title: 'Transactions',
          value: report.transactionCount.toString(),
          icon: Icons.receipt_long_outlined,
          color: Colors.blue,
          subtitle: 'Total completed sales',
        ),
        ReportKpiCard(
          title: 'Average Transaction',
          value: _currencyFormat.format(report.averageTransactionValue),
          icon: Icons.trending_up,
          color: Colors.orange,
          subtitle: 'Per transaction',
        ),
      ],
    );
  }

  Widget _buildTopProductsTable(BuildContext context, SalesReport report) {
    final theme = Theme.of(context);

    if (report.topSellingProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Selling Products',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Product')),
                  DataColumn(label: Text('Quantity'), numeric: true),
                  DataColumn(label: Text('Revenue'), numeric: true),
                ],
                rows: report.topSellingProducts.map((product) {
                  return DataRow(cells: [
                    DataCell(Text(product.productName)),
                    DataCell(Text(product.quantity.toString())),
                    DataCell(Text(_currencyFormat.format(product.revenue))),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
