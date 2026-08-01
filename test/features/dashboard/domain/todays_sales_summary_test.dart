import 'package:ebe_gym/src/features/dashboard/domain/todays_sales_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('aggregateTodaysSalesSummary', () {
    test('returns zeros for empty rows', () {
      final summary = aggregateTodaysSalesSummary(const []);
      expect(summary.count, 0);
      expect(summary.total, 0);
    });

    test('returns single branch row as-is', () {
      final summary = aggregateTodaysSalesSummary(const [
        TodaysSalesBranchRow(transactionCount: 3, totalRevenue: 450),
      ]);
      expect(summary.count, 3);
      expect(summary.total, 450);
    });

    test('sums all branch rows for All branches', () {
      final summary = aggregateTodaysSalesSummary(const [
        TodaysSalesBranchRow(transactionCount: 2, totalRevenue: 200),
        TodaysSalesBranchRow(transactionCount: 5, totalRevenue: 800.5),
      ]);
      expect(summary.count, 7);
      expect(summary.total, 1000.5);
    });
  });
}
