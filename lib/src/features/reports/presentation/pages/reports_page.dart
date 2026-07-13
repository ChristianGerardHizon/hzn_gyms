import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/breakpoints.dart';
import '../../domain/report_aggregations.dart';
import '../../domain/report_period.dart';
import '../controllers/attendance_report_controller.dart';
import '../controllers/inventory_report_controller.dart';
import '../controllers/membership_report_controller.dart';
import '../controllers/report_period_controller.dart';
import '../controllers/sales_report_controller.dart';
import '../export/report_csv_exporter.dart';
import '../pdf/report_pdf_generator.dart';
import '../widgets/report_period_selector.dart';
import '../widgets/views/attendance_report_view.dart';
import '../widgets/views/inventory_report_view.dart';
import '../widgets/views/membership_report_view.dart';
import '../widgets/views/sales_report_view.dart';

/// Main reports page with tabbed navigation for different report types.
///
/// Tabs are mounted lazily (visited set + IndexedStack) so inactive tabs
/// do not fetch until first opened. Providers are keepAlive so revisiting
/// a tab does not refetch unless period/branch changes.
class ReportsPage extends HookConsumerWidget {
  const ReportsPage({super.key});

  static final _currencyFormat =
      NumberFormat.currency(symbol: '₱', decimalDigits: 2);

  static const _tabCount = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: _tabCount);
    final activeTabIndex = useState(0);
    final visitedTabs = useState<Set<int>>({0});

    useEffect(() {
      void listener() {
        final index = tabController.index;
        activeTabIndex.value = index;
        if (!visitedTabs.value.contains(index)) {
          visitedTabs.value = {...visitedTabs.value, index};
        }
      }

      tabController.addListener(listener);
      return () => tabController.removeListener(listener);
    }, [tabController]);

    final isMobile = Breakpoints.isMobile(context);
    final horizontalPad = isMobile ? 16.0 : 24.0;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPad,
              isMobile ? 12 : 20,
              horizontalPad,
              isMobile ? 4 : 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Reports',
                    style: (isMobile
                            ? Theme.of(context).textTheme.titleLarge
                            : Theme.of(context).textTheme.headlineMedium)
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                _ExportButtons(
                  tabIndex: activeTabIndex.value,
                  currencyFormat: _currencyFormat,
                  compact: isMobile,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPad),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                controller: tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                labelPadding: isMobile
                    ? const EdgeInsets.symmetric(horizontal: 12)
                    : null,
                tabs: [
                  const Tab(text: 'Sales'),
                  const Tab(text: 'Inventory'),
                  Tab(text: isMobile ? 'Members' : 'Members & Memberships'),
                  const Tab(text: 'Attendance'),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPad,
              isMobile ? 8 : 12,
              horizontalPad,
              isMobile ? 6 : 8,
            ),
            child: const ReportPeriodSelector(),
          ),
          Expanded(
            child: IndexedStack(
              index: activeTabIndex.value,
              children: List.generate(_tabCount, (index) {
                if (!visitedTabs.value.contains(index)) {
                  return const SizedBox.shrink();
                }
                return switch (index) {
                  0 => const SalesReportView(),
                  1 => const InventoryReportView(),
                  2 => const MembershipReportView(),
                  3 => const AttendanceReportView(),
                  _ => const SizedBox.shrink(),
                };
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportButtons extends HookConsumerWidget {
  const _ExportButtons({
    required this.tabIndex,
    required this.currencyFormat,
    this.compact = false,
  });

  final int tabIndex;
  final NumberFormat currencyFormat;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton.outlined(
            onPressed: () => _handleCsvExport(context, ref),
            icon: const Icon(Icons.table_view, size: 20),
            tooltip: 'Export CSV',
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 4),
          IconButton.filled(
            onPressed: () => _handlePdfExport(context, ref),
            icon: const Icon(Icons.download, size: 20),
            tooltip: 'Export PDF',
            visualDensity: VisualDensity.compact,
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton.icon(
          onPressed: () => _handleCsvExport(context, ref),
          icon: const Icon(Icons.table_view, size: 18),
          label: const Text('CSV'),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: () => _handlePdfExport(context, ref),
          icon: const Icon(Icons.download, size: 18),
          label: const Text('PDF'),
        ),
      ],
    );
  }

  Future<void> _handleCsvExport(BuildContext context, WidgetRef ref) async {
    final period = ref.read(reportPeriodControllerProvider);
    switch (tabIndex) {
      case 0:
        final report = ref.read(salesReportProvider).value;
        if (report == null) return;
        await ReportCsvExporter.exportSales(
          context: context,
          report: report,
          period: period,
        );
      case 1:
        final report = ref.read(inventoryReportProvider).value;
        if (report == null) return;
        await ReportCsvExporter.exportInventory(
          context: context,
          report: report,
        );
      case 2:
        final report = ref.read(membershipReportProvider).value;
        if (report == null) return;
        await ReportCsvExporter.exportMembership(
          context: context,
          report: report,
          period: period,
        );
      case 3:
        final report = ref.read(attendanceReportProvider).value;
        if (report == null) return;
        await ReportCsvExporter.exportAttendance(
          context: context,
          report: report,
          period: period,
        );
    }
  }

  Future<void> _handlePdfExport(BuildContext context, WidgetRef ref) async {
    final period = ref.read(reportPeriodControllerProvider);
    final pdfData = switch (tabIndex) {
      0 => _buildSalesPdfData(ref, period),
      1 => _buildInventoryPdfData(ref, period),
      2 => _buildMembershipPdfData(ref, period),
      3 => _buildAttendancePdfData(ref, period),
      _ => null,
    };
    if (pdfData == null || !context.mounted) return;
    await ReportPdfGenerator(pdfData).saveReport(context);
  }

  ReportPdfData? _buildSalesPdfData(WidgetRef ref, ReportPeriodSelection period) {
    final report = ref.read(salesReportProvider).value;
    if (report == null) return null;
    final itemTypeRows = report.revenueByItemType.entries
        .map(
          (e) => [
            itemTypeLabel(e.key),
            currencyFormat.format(e.value),
          ],
        )
        .toList();
    return ReportPdfData(
      reportTitle: 'Sales Report',
      period: period,
      generatedAt: DateTime.now(),
      kpiData: {
        'Total Revenue': currencyFormat.format(report.totalRevenue),
        'Transactions': report.transactionCount.toString(),
        'Avg Transaction':
            currencyFormat.format(report.averageTransactionValue),
        'Unpaid Sales': report.unpaidSalesCount.toString(),
        'Unpaid Balance': currencyFormat.format(report.unpaidBalance),
      },
      tableHeaders: itemTypeRows.isNotEmpty
          ? ['Item Type', 'Revenue']
          : ['Item', 'Type', 'Quantity', 'Revenue'],
      tableRows: itemTypeRows.isNotEmpty
          ? itemTypeRows
          : report.topSellingProducts
              .map(
                (p) => [
                  p.productName,
                  itemTypeLabel(p.itemType),
                  p.quantity.toString(),
                  currencyFormat.format(p.revenue),
                ],
              )
              .toList(),
      additionalNotes:
          'Revenue by item type is sale line subtotals (products and memberships). '
          'Total Revenue is cash collected from payments. Do not sum with Membership plan value.',
    );
  }

  ReportPdfData? _buildInventoryPdfData(
    WidgetRef ref,
    ReportPeriodSelection period,
  ) {
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
          .map(
            (item) => [
              item.productName,
              item.categoryName,
              item.currentStock.toString(),
              item.threshold.toString(),
            ],
          )
          .toList(),
    );
  }

  ReportPdfData? _buildMembershipPdfData(
    WidgetRef ref,
    ReportPeriodSelection period,
  ) {
    final report = ref.read(membershipReportProvider).value;
    if (report == null) return null;
    return ReportPdfData(
      reportTitle: 'Members & Memberships Report',
      period: period,
      generatedAt: DateTime.now(),
      kpiData: {
        'New Members': report.totalNewMembers.toString(),
        'Active Memberships': report.activeMemberships.toString(),
        'New Subscriptions': report.newSubscriptions.toString(),
        'Renewals': report.renewals.toString(),
        'Expiring Soon (7d)': report.expiringSoonCount.toString(),
        'Lapsed': report.lapsedCount.toString(),
        'Plan Value Sold': currencyFormat.format(report.membershipRevenue),
        'Add-on Value Sold': currencyFormat.format(report.addOnRevenue),
      },
      additionalNotes:
          'Plan Value Sold is from sale line items (or catalog fallback). Cash collected is on the Sales report — do not sum both.',
    );
  }

  ReportPdfData? _buildAttendancePdfData(
    WidgetRef ref,
    ReportPeriodSelection period,
  ) {
    final report = ref.read(attendanceReportProvider).value;
    if (report == null) return null;
    return ReportPdfData(
      reportTitle: 'Attendance Report',
      period: period,
      generatedAt: DateTime.now(),
      kpiData: {
        'Total Check-ins': report.totalCheckIns.toString(),
        'Unique Members': report.uniqueMembers.toString(),
        'No Membership Link':
            report.withoutActiveMembershipCount.toString(),
      },
      tableHeaders: period.period == ReportPeriod.day
          ? null
          : ['Bucket', 'Check-ins'],
      tableRows: period.period == ReportPeriod.day
          ? null
          : report.checkInsTrend
              .map(
                (d) => [
                  d.label,
                  d.value.toString(),
                ],
              )
              .toList(),
    );
  }
}
