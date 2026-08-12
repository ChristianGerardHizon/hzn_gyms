import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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
import '../report_no_data_card.dart';
import '../sales_item_type_transactions_dialog.dart';

/// View displaying the sales report with charts and tables.
class SalesReportView extends HookConsumerWidget {
  const SalesReportView({super.key});

  static final _currencyFormat = NumberFormat.currency(symbol: '₱');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(salesReportProvider);
    final extrasAsync = ref.watch(salesReportExtrasProvider);
    final period = ref.watch(reportPeriodControllerProvider);
    final didRefetchForCounts = useRef(false);

    return reportAsync.when(
      data: (core) {
        final extras = extrasAsync.value ?? SalesReportExtras.empty;
        final report = core.mergeExtras(extras);
        // keepAlive can retain a pre-counts report after hot reload; refetch once.
        final missingCounts = report.transactionCountByItemType == null &&
            report.revenueByItemType.isNotEmpty;
        if (missingCounts && !didRefetchForCounts.value) {
          didRefetchForCounts.value = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.invalidate(scopedSalesReportBundleProvider);
            ref.invalidate(salesReportProvider);
          });
        }
        final extrasLoading = extrasAsync.isLoading;
        return _buildContent(
          context,
          report,
          period,
          extrasLoading: extrasLoading,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorState.fromError(
        error,
        compact: true,
        onRetry: () {
          ref.invalidate(scopedSalesReportBundleProvider);
          ref.invalidate(salesReportProvider);
          ref.invalidate(salesReportExtrasProvider);
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    SalesReport report,
    ReportPeriodSelection period, {
    required bool extrasLoading,
  }) {
    final showTrend = period.period != ReportPeriod.day;
    final showSalesList = period.period == ReportPeriod.day;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKpiSection(context, report, extrasLoading: extrasLoading),
          if (showTrend) ...[
            const SizedBox(height: 24),
            _buildTrendChart(report),
          ],
          const SizedBox(height: 16),
          _buildDistributionCharts(context, report, showSalesList: showSalesList),
          if (showSalesList) ...[
            const SizedBox(height: 24),
            _buildSalesList(context, report.sales, loading: extrasLoading),
          ],
          const SizedBox(height: 24),
          _buildTopProductsTable(context, report),
          if (extrasLoading || report.staffPerformance.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildStaffTable(context, report, loading: extrasLoading),
          ],
        ],
      ),
    );
  }

  Widget _buildTrendChart(SalesReport report) {
    final spots = report.revenueTrend.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value.toDouble());
    }).toList();

    if (spots.isEmpty || spots.every((s) => s.y <= 0)) {
      return const ReportNoDataCard(
        title: 'No revenue trend',
        subtitle: 'There were no completed sales in this period.',
        icon: Icons.show_chart,
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChartWidget(
          title: 'Revenue Trend',
          spots: spots,
          xLabels: report.revenueTrend.map((r) => r.label).toList(),
          yAxisFormatter: (value) =>
              _currencyFormat.format(value).replaceAll('.00', ''),
          height: 250,
        ),
      ),
    );
  }

  Widget _buildDistributionCharts(
    BuildContext context,
    SalesReport report, {
    required bool showSalesList,
  }) {
    final itemTypeData = Map.fromEntries(
      report.revenueByItemType.entries
          .where((e) => e.value > 0)
          .map((e) => MapEntry(itemTypeLabel(e.key), e.value)),
    );
    final paymentMethodData = Map.fromEntries(
      report.revenueByPaymentMethod.entries.where((e) => e.value > 0),
    );
    final topProductsData = Map.fromEntries(
      report.topSellingProducts
          .where((p) => p.revenue > 0)
          .take(5)
          .map((p) => MapEntry(p.productName, p.revenue)),
    );

    final charts = <Widget>[
      if (hasReportChartData(itemTypeData))
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: PieChartWidget(
              title: 'Revenue by Item Type',
              data: itemTypeData,
              height: 200,
            ),
          ),
        ),
      if (hasReportChartData(paymentMethodData))
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: PieChartWidget(
              title: 'Revenue by Payment Method',
              data: paymentMethodData,
              height: 200,
            ),
          ),
        ),
      if (hasReportChartData(topProductsData))
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BarChartWidget(
              title: 'Top Selling by Revenue',
              data: topProductsData,
              height: 200,
              valueFormatter: (value) =>
                  _currencyFormat.format(value).replaceAll('.00', ''),
            ),
          ),
        ),
    ];

    if (charts.isEmpty) {
      // Day view already shows "No sales on this day" in the sales list.
      if (showSalesList) return const SizedBox.shrink();
      return const ReportNoDataCard(
        title: 'No sales data',
        subtitle: 'There were no completed sales in this period.',
        icon: Icons.receipt_long_outlined,
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

        // First two charts side-by-side; any remaining full width below.
        final firstRow = charts.take(2).toList();
        final rest = charts.skip(2).toList();
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < firstRow.length; i++) ...[
                  if (i > 0) const SizedBox(width: 16),
                  Expanded(child: firstRow[i]),
                ],
              ],
            ),
            for (final chart in rest) ...[
              const SizedBox(height: 16),
              chart,
            ],
          ],
        );
      },
    );
  }

  Widget _buildKpiSection(
    BuildContext context,
    SalesReport report, {
    required bool extrasLoading,
  }) {
    final typeTotals = primarySalesItemTypeTotals(
      report.revenueByItemType,
      transactionCountByItemType: report.transactionCountByItemType,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primary: line-revenue highlights
        ReportKpiGrid(
          crossAxisCount: 3,
          children: [
            ReportKpiCard(
              title: 'Memberships',
              value: _currencyFormat.format(typeTotals.membershipTotal),
              icon: Icons.card_membership_outlined,
              color: Colors.purple,
              subtitle: salesCountLabel(typeTotals.membershipCount),
              featured: true,
              onTap: () => showSalesItemTypeTransactionsDialog(
                context,
                itemType: 'membership',
                revenueLabel:
                    _currencyFormat.format(typeTotals.membershipTotal),
              ),
            ),
            ReportKpiCard(
              title: 'Walk-ins',
              value: _currencyFormat.format(typeTotals.walkInTotal),
              icon: Icons.directions_walk_outlined,
              color: Colors.indigo,
              subtitle: salesCountLabel(typeTotals.walkInCount),
              featured: true,
              onTap: () => showSalesItemTypeTransactionsDialog(
                context,
                itemType: 'walkIn',
                revenueLabel: _currencyFormat.format(typeTotals.walkInTotal),
              ),
            ),
            ReportKpiCard(
              title: 'Products',
              value: _currencyFormat.format(typeTotals.productTotal),
              icon: Icons.inventory_2_outlined,
              color: Colors.teal,
              subtitle: salesCountLabel(typeTotals.productCount),
              featured: true,
              onTap: () => showSalesItemTypeTransactionsDialog(
                context,
                itemType: 'product',
                revenueLabel: _currencyFormat.format(typeTotals.productTotal),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Secondary: cash collected + AR details
        ReportKpiGrid(
          crossAxisCount: 3,
          children: [
            ReportKpiCard(
              title: 'Total Revenue',
              value: _currencyFormat.format(report.totalRevenue),
              icon: Icons.attach_money,
              color: Colors.green,
              subtitle: 'Cash collected (payments)',
              compact: true,
            ),
            ReportKpiCard(
              title: 'Transactions',
              value: report.transactionCount.toString(),
              icon: Icons.receipt_long_outlined,
              color: Colors.blue,
              subtitle: 'Completed sales',
              compact: true,
            ),
            ReportKpiCard(
              title: 'Average Transaction',
              value: _currencyFormat.format(report.averageTransactionValue),
              icon: Icons.trending_up,
              color: Colors.orange,
              subtitle: 'Per transaction',
              compact: true,
            ),
            ReportKpiCard(
              title: 'Unpaid Sales',
              value: extrasLoading ? '…' : report.unpaidSalesCount.toString(),
              icon: Icons.money_off_outlined,
              color: Colors.red,
              subtitle: 'Accounts receivable',
              compact: true,
            ),
            ReportKpiCard(
              title: 'Unpaid Balance',
              value: extrasLoading
                  ? '…'
                  : _currencyFormat.format(report.unpaidBalance),
              icon: Icons.account_balance_wallet_outlined,
              color: Colors.deepOrange,
              subtitle: 'Outstanding total',
              compact: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSalesList(
    BuildContext context,
    List<Sale> sales, {
    required bool loading,
  }) {
    final theme = Theme.of(context);
    const title = 'Sales';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
                if (loading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Text(
                    '${sales.length}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (loading && sales.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (sales.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 36,
                        color: theme.colorScheme.outlineVariant,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No sales on this day',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
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
            Text('Top Selling Items', style: theme.textTheme.titleSmall),
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
                  return DataRow(
                    cells: [
                      DataCell(Text(product.productName)),
                      DataCell(Text(itemTypeLabel(product.itemType))),
                      DataCell(Text(product.quantity.toString())),
                      DataCell(Text(_currencyFormat.format(product.revenue))),
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

  Widget _buildStaffTable(
    BuildContext context,
    SalesReport report, {
    required bool loading,
  }) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Staff Performance',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                if (loading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (loading && report.staffPerformance.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (report.staffPerformance.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'No staff sales in this period',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Staff')),
                    DataColumn(label: Text('Transactions'), numeric: true),
                    DataColumn(label: Text('Revenue'), numeric: true),
                  ],
                  rows: report.staffPerformance.map((staff) {
                    return DataRow(
                      cells: [
                        DataCell(Text(staff.staffName)),
                        DataCell(Text(staff.transactionCount.toString())),
                        DataCell(Text(_currencyFormat.format(staff.revenue))),
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
