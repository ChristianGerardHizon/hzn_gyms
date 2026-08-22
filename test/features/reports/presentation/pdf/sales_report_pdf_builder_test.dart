import 'package:kylie_gym/src/features/reports/domain/report_period.dart';
import 'package:kylie_gym/src/features/reports/domain/sales_report.dart';
import 'package:kylie_gym/src/features/reports/presentation/pdf/report_pdf_constants.dart';
import 'package:kylie_gym/src/features/reports/presentation/pdf/sales_report_pdf_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  final currencyFormat = NumberFormat.currency(symbol: 'P', decimalDigits: 2);
  final period = ReportPeriodSelection.current(ReportPeriod.day);

  group('buildSalesReportPdfData', () {
    test('includes BIR disclaimer in footer', () {
      final data = buildSalesReportPdfData(
        report: SalesReport.empty,
        period: period,
        currencyFormat: currencyFormat,
        generatedAt: DateTime(2026, 7, 14, 12),
      );

      expect(data.footerDisclaimer, kSalesReportFooterDisclaimer);
      expect(
        data.footerDisclaimer,
        contains('not an official sales invoice'),
      );
      expect(data.footerDisclaimer, contains('BIR'));
    });

    test('uses sales transactions table when sales are present', () {
      final sale = buildSale(
        receiptNumber: 'S-250714-0001',
        totalAmount: 500,
        isPaid: true,
        descriptor: 'Monthly Plan',
        customerName: 'Juan Dela Cruz',
      ).copyWith(created: DateTime(2026, 7, 14, 10, 30));

      final data = buildSalesReportPdfData(
        report: SalesReport.empty.copyWith(sales: [sale]),
        period: period,
        currencyFormat: currencyFormat,
      );

      expect(data.tableTitle, 'SALES TRANSACTIONS');
      expect(
        data.tableHeaders,
        [
          'Receipt',
          'Date',
          'Description',
          'Customer',
          'Amount',
          'Status',
        ],
      );
      expect(data.tableRows, hasLength(1));
      expect(data.tableRows!.first[0], 'S-250714-0001');
      expect(data.tableRows!.first[2], 'Monthly Plan');
      expect(data.tableRows!.first[3], 'Juan Dela Cruz');
      expect(data.tableRows!.first[4], currencyFormat.format(500));
      expect(data.tableRows!.first[5], 'Paid');
    });

    test('falls back to item type revenue when no sales', () {
      final data = buildSalesReportPdfData(
        report: SalesReport.empty.copyWith(
          revenueByItemType: {'product': 1200, 'membership': 800},
        ),
        period: period,
        currencyFormat: currencyFormat,
      );

      expect(data.tableTitle, isNull);
      expect(data.tableHeaders, ['Item Type', 'Revenue']);
      expect(data.tableRows, hasLength(2));
    });

    test('includes KPI metrics from report', () {
      final data = buildSalesReportPdfData(
        report: SalesReport.empty.copyWith(
          totalRevenue: 1500,
          transactionCount: 3,
          averageTransactionValue: 500,
          unpaidSalesCount: 1,
          unpaidBalance: 200,
          revenueByItemType: {
            'product': 400,
            'membership': 900,
            'walkIn': 200,
            'addon': 50,
          },
          transactionCountByItemType: {
            'product': 4,
            'membership': 2,
            'walkIn': 5,
            'addon': 1,
          },
        ),
        period: period,
        currencyFormat: currencyFormat,
      );

      expect(data.kpiData['Total Revenue'], currencyFormat.format(1500));
      expect(data.kpiData['Transactions'], '3');
      expect(
        data.kpiData['Walk-ins'],
        '${currencyFormat.format(200)} · 5 sales',
      );
      expect(
        data.kpiData['Memberships'],
        '${currencyFormat.format(900)} · 2 sales',
      );
      expect(
        data.kpiData['Products'],
        '${currencyFormat.format(400)} · 4 sales',
      );
      expect(data.kpiData['Unpaid Sales'], '1');
      expect(data.kpiData['Unpaid Balance'], currencyFormat.format(200));
      expect(data.kpiData.keys.take(3).toList(), [
        'Memberships',
        'Walk-ins',
        'Products',
      ]);
    });

    test('skips transaction table for non-Day periods even if sales present', () {
      final sale = buildSale(totalAmount: 100);
      final weekly = ReportPeriodSelection.current(ReportPeriod.weekly);
      final data = buildSalesReportPdfData(
        report: SalesReport.empty.copyWith(
          sales: [sale],
          revenueByItemType: {'product': 500},
        ),
        period: weekly,
        currencyFormat: currencyFormat,
      );

      expect(data.tableTitle, isNull);
      expect(data.tableHeaders, ['Item Type', 'Revenue']);
    });
  });
}
