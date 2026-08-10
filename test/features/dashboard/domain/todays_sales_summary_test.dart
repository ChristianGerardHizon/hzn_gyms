import 'package:ebe_gym/src/features/dashboard/domain/todays_sales_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('aggregateTodaysSalesSummary', () {
    test('returns zeros for empty rows', () {
      final summary = aggregateTodaysSalesSummary(const []);
      expect(summary.count, 0);
      expect(summary.total, 0);
      expect(summary.byBranch, isEmpty);
      expect(summary.membershipTotal, 0);
      expect(summary.walkInTotal, 0);
    });

    test('returns single branch row as-is', () {
      final summary = aggregateTodaysSalesSummary(const [
        TodaysSalesBranchRow(
          branchId: 'branch-a',
          transactionCount: 3,
          totalRevenue: 450,
        ),
      ]);
      expect(summary.count, 3);
      expect(summary.total, 450);
      expect(summary.byBranch, hasLength(1));
      expect(summary.byBranch.first.branchId, 'branch-a');
    });

    test('sums all branch rows for All branches', () {
      final summary = aggregateTodaysSalesSummary(const [
        TodaysSalesBranchRow(
          branchId: 'branch-a',
          transactionCount: 2,
          totalRevenue: 200,
        ),
        TodaysSalesBranchRow(
          branchId: 'branch-b',
          transactionCount: 5,
          totalRevenue: 800.5,
        ),
      ]);
      expect(summary.count, 7);
      expect(summary.total, 1000.5);
      expect(summary.byBranch.map((r) => r.branchId), ['branch-a', 'branch-b']);
    });

    test('carries membership and walk-in totals through', () {
      final summary = aggregateTodaysSalesSummary(
        const [
          TodaysSalesBranchRow(
            branchId: 'branch-a',
            transactionCount: 2,
            totalRevenue: 500,
          ),
        ],
        membershipTotal: 300,
        walkInTotal: 150,
      );
      expect(summary.membershipTotal, 300);
      expect(summary.walkInTotal, 150);
    });
  });

  group('aggregateTodaysItemTypeRevenue', () {
    test('returns zeros for empty rows', () {
      final totals = aggregateTodaysItemTypeRevenue(const []);
      expect(totals.membershipTotal, 0);
      expect(totals.walkInTotal, 0);
    });

    test('sums membership and walkIn separately', () {
      final totals = aggregateTodaysItemTypeRevenue(const [
        TodaysItemTypeRevenueRow(itemType: 'membership', totalRevenue: 800),
        TodaysItemTypeRevenueRow(itemType: 'walkIn', totalRevenue: 120),
        TodaysItemTypeRevenueRow(itemType: 'membership', totalRevenue: 200),
        TodaysItemTypeRevenueRow(itemType: 'walkIn', totalRevenue: 80),
      ]);
      expect(totals.membershipTotal, 1000);
      expect(totals.walkInTotal, 200);
    });

    test('ignores product and addon item types', () {
      final totals = aggregateTodaysItemTypeRevenue(const [
        TodaysItemTypeRevenueRow(itemType: 'membership', totalRevenue: 500),
        TodaysItemTypeRevenueRow(itemType: 'product', totalRevenue: 90),
        TodaysItemTypeRevenueRow(itemType: 'addon', totalRevenue: 50),
        TodaysItemTypeRevenueRow(itemType: 'walkIn', totalRevenue: 100),
        TodaysItemTypeRevenueRow(itemType: '', totalRevenue: 25),
      ]);
      expect(totals.membershipTotal, 500);
      expect(totals.walkInTotal, 100);
    });
  });
}
