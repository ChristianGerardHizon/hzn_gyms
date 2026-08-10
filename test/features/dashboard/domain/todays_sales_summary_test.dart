import 'package:ebe_gym/src/features/dashboard/domain/todays_sales_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TodaySalesSummary count getters', () {
    test('default to zero when count fields are omitted', () {
      const summary = TodaySalesSummary(count: 1, total: 100);
      expect(summary.membershipCount, 0);
      expect(summary.walkInCount, 0);
    });
  });

  group('aggregateTodaysSalesSummary', () {
    test('returns zeros for empty rows', () {
      final summary = aggregateTodaysSalesSummary(const []);
      expect(summary.count, 0);
      expect(summary.total, 0);
      expect(summary.byBranch, isEmpty);
      expect(summary.membershipTotal, 0);
      expect(summary.walkInTotal, 0);
      expect(summary.membershipCount, 0);
      expect(summary.walkInCount, 0);
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

    test('carries membership and walk-in totals and counts through', () {
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
        membershipCount: 2,
        walkInCount: 4,
      );
      expect(summary.membershipTotal, 300);
      expect(summary.walkInTotal, 150);
      expect(summary.membershipCount, 2);
      expect(summary.walkInCount, 4);
    });
  });

  group('aggregateTodaysItemTypeRevenue', () {
    test('returns zeros for empty rows', () {
      final totals = aggregateTodaysItemTypeRevenue(const []);
      expect(totals.membershipTotal, 0);
      expect(totals.walkInTotal, 0);
      expect(totals.membershipCount, 0);
      expect(totals.walkInCount, 0);
    });

    test('sums membership and walkIn revenue and counts separately', () {
      final totals = aggregateTodaysItemTypeRevenue(const [
        TodaysItemTypeRevenueRow(
          itemType: 'membership',
          totalRevenue: 800,
          transactionCount: 2,
        ),
        TodaysItemTypeRevenueRow(
          itemType: 'walkIn',
          totalRevenue: 120,
          transactionCount: 3,
        ),
        TodaysItemTypeRevenueRow(
          itemType: 'membership',
          totalRevenue: 200,
          transactionCount: 1,
        ),
        TodaysItemTypeRevenueRow(
          itemType: 'walkIn',
          totalRevenue: 80,
          transactionCount: 2,
        ),
      ]);
      expect(totals.membershipTotal, 1000);
      expect(totals.walkInTotal, 200);
      expect(totals.membershipCount, 3);
      expect(totals.walkInCount, 5);
    });

    test('ignores product and addon item types', () {
      final totals = aggregateTodaysItemTypeRevenue(const [
        TodaysItemTypeRevenueRow(
          itemType: 'membership',
          totalRevenue: 500,
          transactionCount: 2,
        ),
        TodaysItemTypeRevenueRow(
          itemType: 'product',
          totalRevenue: 90,
          transactionCount: 9,
        ),
        TodaysItemTypeRevenueRow(
          itemType: 'addon',
          totalRevenue: 50,
          transactionCount: 1,
        ),
        TodaysItemTypeRevenueRow(
          itemType: 'walkIn',
          totalRevenue: 100,
          transactionCount: 4,
        ),
        TodaysItemTypeRevenueRow(
          itemType: '',
          totalRevenue: 25,
          transactionCount: 5,
        ),
      ]);
      expect(totals.membershipTotal, 500);
      expect(totals.walkInTotal, 100);
      expect(totals.membershipCount, 2);
      expect(totals.walkInCount, 4);
    });
  });
}
