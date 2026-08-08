import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/breakpoints.dart';
import '../../../../../core/widgets/state/error_state.dart';
import '../../../domain/inventory_report.dart';
import '../../controllers/inventory_report_controller.dart';
import '../charts/bar_chart_widget.dart';
import '../charts/pie_chart_widget.dart';
import '../report_kpi_card.dart';
import '../report_kpi_grid.dart';
import '../report_no_data_card.dart';

/// View displaying the inventory report with charts and tables.
class InventoryReportView extends ConsumerWidget {
  const InventoryReportView({super.key});

  static final _currencyFormat = NumberFormat.currency(symbol: '₱');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(inventoryReportProvider);

    return reportAsync.when(
      data: (report) => _buildContent(context, report),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorState.fromError(error, compact: true),
    );
  }

  Widget _buildContent(BuildContext context, InventoryReport report) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards
          _buildKpiSection(context, report),
          const SizedBox(height: 24),

          _buildCharts(context, report),
          const SizedBox(height: 24),

          // Low Stock Items Table
          _buildLowStockTable(context, report),
        ],
      ),
    );
  }

  Widget _buildCharts(BuildContext context, InventoryReport report) {
    final stockStatusData = Map<String, num>.fromEntries(
      report.stockStatusBreakdown.entries.where((e) => e.value > 0),
    );
    final categoryData = Map<String, num>.fromEntries(
      report.productsByCategory.entries.where((e) => e.value > 0),
    );

    final charts = <Widget>[
      if (hasReportChartData(stockStatusData))
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: PieChartWidget(
              title: 'Stock Status',
              data: stockStatusData,
              height: 220,
              colors: const [
                Color(0xFF4CAF50), // In Stock - Green
                Color(0xFFFBC02D), // Low Stock - Yellow
                Color(0xFFF44336), // Out of Stock - Red
              ],
            ),
          ),
        ),
      if (hasReportChartData(categoryData))
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BarChartWidget(
              title: 'Products by Category',
              data: categoryData,
              height: 220,
              barColor: Colors.deepPurple,
            ),
          ),
        ),
    ];

    if (charts.isEmpty) {
      return const ReportNoDataCard(
        title: 'No inventory data',
        subtitle: 'Add products to see stock and category breakdowns.',
        icon: Icons.inventory_2_outlined,
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

  Widget _buildKpiSection(BuildContext context, InventoryReport report) {
    final inStockPct = report.totalProducts > 0
        ? (report.inStockCount / report.totalProducts * 100).toStringAsFixed(1)
        : '0';

    return ReportKpiGrid(
      children: [
        ReportKpiCard(
          title: 'Total Products',
          value: report.totalProducts.toString(),
          icon: Icons.inventory_2_outlined,
          color: Colors.deepPurple,
          subtitle: 'All products in catalog',
        ),
        ReportKpiCard(
          title: 'In Stock',
          value: report.inStockCount.toString(),
          icon: Icons.check_circle_outline,
          color: Colors.green,
          subtitle: '$inStockPct% of total inventory',
        ),
        ReportKpiCard(
          title: 'Low Stock',
          value: report.lowStockCount.toString(),
          icon: Icons.warning_amber_outlined,
          color: Colors.amber.shade700,
          subtitle: 'Requires reorder soon',
        ),
        ReportKpiCard(
          title: 'Out of Stock',
          value: report.outOfStockCount.toString(),
          icon: Icons.remove_shopping_cart_outlined,
          color: Colors.red,
          subtitle: 'Immediate action required',
        ),
        ReportKpiCard(
          title: 'Expired',
          value: report.expiredCount.toString(),
          icon: Icons.dangerous_outlined,
          color: Colors.red.shade900,
          subtitle: 'Items past shelf life',
        ),
        ReportKpiCard(
          title: 'Near Expiration',
          value: report.nearExpirationCount.toString(),
          icon: Icons.access_time,
          color: Colors.orange,
          subtitle: 'Expiring within 30 days',
        ),
        ReportKpiCard(
          title: 'Inventory Value',
          value: _currencyFormat.format(report.totalInventoryValue),
          icon: Icons.monetization_on_outlined,
          color: Colors.blue,
          subtitle: 'Estimated current total',
          featured: true,
        ),
      ],
    );
  }

  Widget _buildLowStockTable(BuildContext context, InventoryReport report) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, y');

    if (report.lowStockItems.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Low Stock Items', style: theme.textTheme.titleSmall),
              const SizedBox(height: 16),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No low stock items',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Low Stock Items', style: theme.textTheme.titleSmall),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Product')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Current'), numeric: true),
                  DataColumn(label: Text('Threshold'), numeric: true),
                  DataColumn(label: Text('Expiration')),
                ],
                rows: report.lowStockItems.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(Text(item.productName)),
                      DataCell(Text(item.categoryName)),
                      DataCell(Text(item.currentStock.toString())),
                      DataCell(Text(item.threshold.toString())),
                      DataCell(
                        Text(
                          item.expirationDate != null
                              ? dateFormat.format(item.expirationDate!)
                              : '-',
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
