import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/report_period.dart';
import '../controllers/inventory_report_controller.dart';
import '../controllers/membership_report_controller.dart';
import '../controllers/report_period_controller.dart';
import '../controllers/sales_report_controller.dart';
import '../pdf/report_pdf_generator.dart';
import '../widgets/report_period_selector.dart';
import '../widgets/views/inventory_report_view.dart';
import '../widgets/views/membership_report_view.dart';
import '../widgets/views/sales_report_view.dart';

/// Main reports page with tabbed navigation for different report types.
class ReportsPage extends HookConsumerWidget {
  const ReportsPage({super.key});

  static final _currencyFormat =
      NumberFormat.currency(symbol: '₱', decimalDigits: 2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 3);
    final activeTabIndex = useState(0);

    useEffect(() {
      void listener() => activeTabIndex.value = tabController.index;
      tabController.addListener(listener);
      return () => tabController.removeListener(listener);
    }, [tabController]);

    return Scaffold(
      body: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Row(
              children: [
                Text(
                  'Reports',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                _ExportReportButton(
                  tabIndex: activeTabIndex.value,
                  currencyFormat: _currencyFormat,
                ),
              ],
            ),
          ),

          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                controller: tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Sales'),
                  Tab(text: 'Inventory'),
                  Tab(text: 'Members & Memberships'),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // Period selector + date range
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ReportPeriodSelector(),
                      SizedBox(height: 8),
                      _DateRangeDisplay(),
                    ],
                  );
                }
                return Row(
                  children: const [
                    ReportPeriodSelector(),
                    Spacer(),
                    _DateRangeDisplay(),
                  ],
                );
              },
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: const [
                SalesReportView(),
                InventoryReportView(),
                MembershipReportView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateRangeDisplay extends ConsumerWidget {
  const _DateRangeDisplay();

  static final _dateFormat = DateFormat('MMM d, y');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(reportPeriodControllerProvider);
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.calendar_today,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          '${_dateFormat.format(period.startDate)} - ${_dateFormat.format(period.endDate)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ExportReportButton extends HookConsumerWidget {
  const _ExportReportButton({
    required this.tabIndex,
    required this.currencyFormat,
  });

  final int tabIndex;
  final NumberFormat currencyFormat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton.icon(
      onPressed: () => _handleExport(context, ref),
      icon: const Icon(Icons.download, size: 18),
      label: const Text('Export Report'),
    );
  }

  Future<void> _handleExport(BuildContext context, WidgetRef ref) async {
    final period = ref.read(reportPeriodControllerProvider);
    final pdfData = switch (tabIndex) {
      0 => _buildSalesPdfData(ref, period),
      1 => _buildInventoryPdfData(ref, period),
      2 => _buildMembershipPdfData(ref, period),
      _ => null,
    };
    if (pdfData == null || !context.mounted) return;
    await ReportPdfGenerator(pdfData).saveReport(context);
  }

  ReportPdfData? _buildSalesPdfData(WidgetRef ref, ReportPeriod period) {
    final report = ref.read(salesReportProvider).value;
    if (report == null) return null;
    return ReportPdfData(
      reportTitle: 'Sales Report',
      period: period,
      generatedAt: DateTime.now(),
      kpiData: {
        'Total Revenue': currencyFormat.format(report.totalRevenue),
        'Transactions': report.transactionCount.toString(),
        'Avg Transaction': currencyFormat.format(report.averageTransactionValue),
      },
      tableHeaders: ['Product', 'Quantity', 'Revenue'],
      tableRows: report.topSellingProducts
          .map((p) => [
                p.productName,
                p.quantity.toString(),
                currencyFormat.format(p.revenue),
              ])
          .toList(),
    );
  }

  ReportPdfData? _buildInventoryPdfData(WidgetRef ref, ReportPeriod period) {
    final report = ref.read(inventoryReportProvider).value;
    if (report == null) return null;
    return ReportPdfData(
      reportTitle: 'Inventory Report',
      period: period,
      generatedAt: DateTime.now(),
      kpiData: {
        'Total Products': report.totalProducts.toString(),
        'In Stock': report.inStockCount.toString(),
        'Low Stock': report.lowStockCount.toString(),
        'Out of Stock': report.outOfStockCount.toString(),
        'Expired': report.expiredCount.toString(),
        'Near Expiration': report.nearExpirationCount.toString(),
        'Inventory Value': currencyFormat.format(report.totalInventoryValue),
      },
      tableHeaders: ['Product', 'Category', 'Current', 'Threshold'],
      tableRows: report.lowStockItems
          .map((item) => [
                item.productName,
                item.categoryName,
                item.currentStock.toString(),
                item.threshold.toString(),
              ])
          .toList(),
    );
  }

  ReportPdfData? _buildMembershipPdfData(WidgetRef ref, ReportPeriod period) {
    final report = ref.read(membershipReportProvider).value;
    if (report == null) return null;
    return ReportPdfData(
      reportTitle: 'Members & Memberships Report',
      period: period,
      generatedAt: DateTime.now(),
      kpiData: {
        'New Members': report.totalNewMembers.toString(),
        'Active Memberships': report.activeMemberships.toString(),
        'Expired / Cancelled': report.expiredCancelledMemberships.toString(),
        'Membership Revenue': currencyFormat.format(report.membershipRevenue),
        'Add-on Revenue': currencyFormat.format(report.addOnRevenue),
      },
    );
  }
}
