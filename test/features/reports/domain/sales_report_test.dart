import 'package:ebe_gym/src/features/reports/domain/sales_report.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('SalesReport.mergeExtras', () {
    test('overlays unpaid, staff, and sales from extras', () {
      const core = SalesReport(
        totalRevenue: 1000,
        transactionCount: 5,
        averageTransactionValue: 200,
        revenueTrend: [],
        revenueByPaymentMethod: {},
        topSellingProducts: [],
      );
      final sale = buildSale(totalAmount: 100);
      final extras = SalesReportExtras(
        unpaidSalesCount: 2,
        unpaidBalance: 150,
        staffPerformance: const [
          StaffSalesSummary(
            staffId: 'u1',
            staffName: 'Ann',
            transactionCount: 3,
            revenue: 600,
          ),
        ],
        sales: [sale],
      );

      final merged = core.mergeExtras(extras);
      expect(merged.totalRevenue, 1000);
      expect(merged.transactionCount, 5);
      expect(merged.unpaidSalesCount, 2);
      expect(merged.unpaidBalance, 150);
      expect(merged.staffPerformance.single.staffName, 'Ann');
      expect(merged.sales, [sale]);
    });

    test('applies day KPI override only when core has zero transactions', () {
      const emptyCore = SalesReport.empty;
      final extras = SalesReportExtras(
        dayKpiOverride: (totalRevenue: 250, transactionCount: 2),
      );

      final merged = emptyCore.mergeExtras(extras);
      expect(merged.totalRevenue, 250);
      expect(merged.transactionCount, 2);
      expect(merged.averageTransactionValue, 125);

      const populatedCore = SalesReport(
        totalRevenue: 900,
        transactionCount: 3,
        averageTransactionValue: 300,
        revenueTrend: [],
        revenueByPaymentMethod: {},
        topSellingProducts: [],
      );
      final ignored = populatedCore.mergeExtras(extras);
      expect(ignored.totalRevenue, 900);
      expect(ignored.transactionCount, 3);
    });
  });
}
