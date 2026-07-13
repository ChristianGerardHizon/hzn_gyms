import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/routing/routes/sales_history.routes.dart';
import '../../../../../core/utils/breakpoints.dart';
import '../../../../../core/widgets/state/error_state.dart';
import '../../../../dashboard/presentation/widgets/today_sale_list_tile.dart';
import '../../../../pos/domain/sale.dart';
import '../../../domain/report_aggregations.dart';
import '../../../domain/report_period.dart';
import '../../../domain/sales_report.dart';
import '../../controllers/report_period_controller.dart';
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
    final period = ref.watch(reportPeriodControllerProvider);

    return reportAsync.when(
      data: (report) => _buildContent(context, report, period),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorState.fromError(
        error,
        compact: true,
        onRetry: () => ref.invalidate(salesReportProvider),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    SalesReport report,
    ReportPeriodSelection period,
  ) {
    final itemTypeData = Map.fromEntries(
      report.revenueByItemType.entries.map(
        (e) => MapEntry(itemTypeLabel(e.key), e.value),
      ),
    );
    final multiDay = startOfDay(period.rangeStart) != startOfDay(period.rangeEnd);
    final showTrend = period.period != ReportPeriod.day || multiDay;
    final showSalesList = period.period == ReportPeriod.day;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKpiSection(context, report),
          if (showTrend) ...[
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LineChartWidget(
                  title: 'Revenue Trend',
                  spots: report.revenueTrend.asMap().entries.map((entry) {
                    return FlSpot(
                      entry.key.toDouble(),
                      entry.value.value.toDouble(),
                    );
                  }).toList(),
                  xLabels: report.revenueTrend.map((r) => r.label).toList(),
                  yAxisFormatter: (value) =>
                      _currencyFormat.format(value).replaceAll('.00', ''),
                  height: 250,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < Breakpoints.mobile;
              final itemTypeChart = itemTypeData.isEmpty
                  ? const SizedBox.shrink()
                  : Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: PieChartWidget(
                          title: 'Revenue by Item Type',
                          data: itemTypeData,
                          height: 200,
                        ),
                      ),
                    );
              final paymentMethodChart = Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: PieChartWidget(
                    title: 'Revenue by Payment Method',
                    data: report.revenueByPaymentMethod,
                    height: 200,
                  ),
                ),
              );
              final topProductsChart = Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: BarChartWidget(
                    title: 'Top Selling by Revenue',
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
              );

              if (isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    itemTypeChart,
                    const SizedBox(height: 16),
                    paymentMethodChart,
                    const SizedBox(height: 16),
                    topProductsChart,
                  ],
                );
              }

              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: itemTypeChart),
                      const SizedBox(width: 16),
                      Expanded(child: paymentMethodChart),
                    ],
                  ),
                  const SizedBox(height: 16),
                  topProductsChart,
                ],
              );
            },
          ),
          if (showSalesList) ...[
            const SizedBox(height: 24),
            _buildSalesList(context, report.sales, period),
          ],
          const SizedBox(height: 24),
          _buildTopProductsTable(context, report),
          if (report.staffPerformance.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildStaffTable(context, report),
          ],
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
          subtitle: 'Cash collected (payments)',
          featured: true,
        ),
        ReportKpiCard(
          title: 'Transactions',
          value: report.transactionCount.toString(),
          icon: Icons.receipt_long_outlined,
          color: Colors.blue,
          subtitle: 'Completed sales',
        ),
        ReportKpiCard(
          title: 'Average Transaction',
          value: _currencyFormat.format(report.averageTransactionValue),
          icon: Icons.trending_up,
          color: Colors.orange,
          subtitle: 'Per transaction',
        ),
        ReportKpiCard(
          title: 'Unpaid Sales',
          value: report.unpaidSalesCount.toString(),
          icon: Icons.money_off_outlined,
          color: Colors.red,
          subtitle: 'Accounts receivable',
        ),
        ReportKpiCard(
          title: 'Unpaid Balance',
          value: _currencyFormat.format(report.unpaidBalance),
          icon: Icons.account_balance_wallet_outlined,
          color: Colors.deepOrange,
          subtitle: 'Outstanding total',
        ),
      ],
    );
  }

  Widget _buildSalesList(
    BuildContext context,
    List<Sale> sales,
    ReportPeriodSelection period,
  ) {
    final theme = Theme.of(context);
    final title = startOfDay(period.rangeStart) == startOfDay(period.rangeEnd)
        ? 'Sales'
        : 'Sales in Range';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: theme.textTheme.titleSmall),
                ),
                Text(
                  '${sales.length}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (sales.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No sales in this date range',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sales.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final sale = sales[index];
                  return TodaySaleListTile(
                    sale: sale,
                    showDate: startOfDay(period.rangeStart) !=
                        startOfDay(period.rangeEnd),
                    onTap: () => SaleDetailRoute(id: sale.id).push(context),
                  );
                },
              ),
          ],
        ),
      ),
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
              'Top Selling Items',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Item')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Quantity'), numeric: true),
                  DataColumn(label: Text('Revenue'), numeric: true),
                ],
                rows: report.topSellingProducts.map((product) {
                  return DataRow(cells: [
                    DataCell(Text(product.productName)),
                    DataCell(Text(itemTypeLabel(product.itemType))),
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

  Widget _buildStaffTable(BuildContext context, SalesReport report) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Staff Performance',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Staff')),
                  DataColumn(label: Text('Transactions'), numeric: true),
                  DataColumn(label: Text('Revenue'), numeric: true),
                ],
                rows: report.staffPerformance.map((staff) {
                  return DataRow(cells: [
                    DataCell(Text(staff.staffName)),
                    DataCell(Text(staff.transactionCount.toString())),
                    DataCell(Text(_currencyFormat.format(staff.revenue))),
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
