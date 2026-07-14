import 'package:intl/intl.dart';

import '../../../pos/domain/sale.dart';
import '../../domain/report_aggregations.dart';
import '../../domain/report_period.dart';
import '../../domain/sales_report.dart';
import 'report_pdf_constants.dart';
import 'report_pdf_generator.dart';

/// Builds [ReportPdfData] for the sales report tab (print / save PDF).
ReportPdfData buildSalesReportPdfData({
  required SalesReport report,
  required ReportPeriodSelection period,
  required NumberFormat currencyFormat,
  DateTime? generatedAt,
}) {
  final generated = generatedAt ?? DateTime.now();
  final salesRows = _salesTransactionRows(report.sales, currencyFormat);
  final itemTypeRows = report.revenueByItemType.entries
      .map((e) => [itemTypeLabel(e.key), currencyFormat.format(e.value)])
      .toList();

  final ({List<String> headers, List<List<String>> rows}) table;
  if (salesRows.isNotEmpty) {
    table = (
      headers: ['Receipt', 'Date', 'Description', 'Customer', 'Amount', 'Status'],
      rows: salesRows,
    );
  } else if (itemTypeRows.isNotEmpty) {
    table = (headers: ['Item Type', 'Revenue'], rows: itemTypeRows);
  } else {
    table = (
      headers: ['Item', 'Type', 'Quantity', 'Revenue'],
      rows: report.topSellingProducts
          .map(
            (p) => [
              p.productName,
              itemTypeLabel(p.itemType),
              p.quantity.toString(),
              currencyFormat.format(p.revenue),
            ],
          )
          .toList(),
    );
  }

  return ReportPdfData(
    reportTitle: 'Sales Report',
    period: period,
    generatedAt: generated,
    kpiData: {
      'Total Revenue': currencyFormat.format(report.totalRevenue),
      'Transactions': report.transactionCount.toString(),
      'Avg Transaction': currencyFormat.format(report.averageTransactionValue),
      'Unpaid Sales': report.unpaidSalesCount.toString(),
      'Unpaid Balance': currencyFormat.format(report.unpaidBalance),
    },
    tableHeaders: table.headers,
    tableRows: table.rows,
    tableTitle: salesRows.isNotEmpty ? 'SALES TRANSACTIONS' : 'DETAILED DATA',
    additionalNotes:
        'Revenue by item type is sale line subtotals (products and memberships). '
        'Total Revenue is cash collected from payments. Do not sum with Membership plan value.',
    footerDisclaimer: kSalesReportFooterDisclaimer,
  );
}

List<List<String>> _salesTransactionRows(
  List<Sale> sales,
  NumberFormat currencyFormat,
) {
  if (sales.isEmpty) return [];

  final dateFormat = DateFormat('MMM d, y hh:mm a');
  return sales.map<List<String>>((sale) {
    final created = sale.created;
    final dateLabel =
        created != null ? dateFormat.format(created) : '-';
    return [
      sale.receiptNumber,
      dateLabel,
      sale.listTitle,
      sale.customerDisplay,
      currencyFormat.format(sale.totalAmount),
      sale.isPaid ? 'Paid' : 'Unpaid',
    ];
  }).toList();
}
