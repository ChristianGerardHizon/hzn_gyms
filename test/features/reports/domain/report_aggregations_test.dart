import 'package:ebe_gym/src/features/reports/domain/report_aggregations.dart';
import 'package:ebe_gym/src/features/reports/domain/report_period.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatViewDate', () {
    test('pads month and day', () {
      expect(formatViewDate(DateTime(2026, 7, 4)), '2026-07-04');
    });
  });

  group('calendar boundaries', () {
    test('startOfWeekMonday is Monday', () {
      // 2026-07-14 is Tuesday
      final monday = startOfWeekMonday(DateTime(2026, 7, 14));
      expect(monday.weekday, DateTime.monday);
      expect(monday, DateTime(2026, 7, 13));
    });

    test('endOfWeekSunday is Sunday', () {
      final sunday = endOfWeekSunday(DateTime(2026, 7, 14));
      expect(sunday.weekday, DateTime.sunday);
      expect(sunday.day, 19);
    });

    test('startOfMonth / endOfMonth', () {
      expect(startOfMonth(DateTime(2026, 7, 14)), DateTime(2026, 7));
      final end = endOfMonth(DateTime(2026, 7, 14));
      expect(end.day, 31);
      expect(end.month, 7);
    });

    test('startOfYear / endOfYear', () {
      expect(startOfYear(DateTime(2026, 7, 14)), DateTime(2026));
      final end = endOfYear(DateTime(2026, 7, 14));
      expect(end, DateTime(2026, 12, 31, 23, 59, 59, 999));
    });
  });

  group('ReportPeriodSelection calendar ranges', () {
    test('day starts at midnight today', () {
      final now = DateTime.now();
      final selection = ReportPeriodSelection.current(ReportPeriod.day);
      expect(selection.startDate, DateTime(now.year, now.month, now.day));
      expect(selection.trendGranularity, TrendGranularity.day);
    });

    test('weekly is Mon–Sun grain day', () {
      final selection = ReportPeriodSelection.current(ReportPeriod.weekly);
      expect(selection.trendGranularity, TrendGranularity.day);
      expect(selection.startDate.weekday, DateTime.monday);
    });

    test('monthly grain is week', () {
      final selection = ReportPeriodSelection.current(ReportPeriod.monthly);
      expect(selection.trendGranularity, TrendGranularity.week);
      expect(selection.startDate.day, 1);
    });

    test('yearly grain is month and starts Jan 1', () {
      final selection = ReportPeriodSelection.current(ReportPeriod.yearly);
      expect(selection.trendGranularity, TrendGranularity.month);
      expect(selection.startDate.month, 1);
      expect(selection.startDate.day, 1);
    });

    test('allTime grain is year', () {
      final selection = ReportPeriodSelection.current(ReportPeriod.allTime);
      expect(selection.trendGranularity, TrendGranularity.year);
      expect(selection.startDate.year, 2019);
    });

    test('withRangeStart snaps week to Monday', () {
      // 2026-07-15 is Wednesday
      final selection = ReportPeriodSelection.current(
        ReportPeriod.weekly,
      ).withRangeStart(DateTime(2026, 7, 15));
      expect(selection.rangeStart, DateTime(2026, 7, 13));
      expect(selection.rangeStart.weekday, DateTime.monday);
    });

    test('withRangeEnd snaps month to month end', () {
      final selection = ReportPeriodSelection(
        period: ReportPeriod.monthly,
        rangeStart: DateTime(2026, 1),
        rangeEnd: DateTime(2026, 1, 31, 23, 59, 59, 999),
      ).withRangeEnd(DateTime(2026, 3, 10));
      expect(selection.rangeEnd.month, 3);
      expect(selection.rangeEnd.day, 31);
    });

    test('withRangeStart after end moves end forward', () {
      final selection = ReportPeriodSelection(
        period: ReportPeriod.day,
        rangeStart: DateTime(2026, 7, 1),
        rangeEnd: DateTime(2026, 7, 1, 23, 59, 59, 999),
      ).withRangeStart(DateTime(2026, 7, 10));
      expect(selection.rangeStart, DateTime(2026, 7, 10));
      expect(startOfDay(selection.rangeEnd), DateTime(2026, 7, 10));
    });

    test('displayRangeLabel for single month', () {
      final selection = ReportPeriodSelection(
        period: ReportPeriod.monthly,
        rangeStart: DateTime(2026, 7),
        rangeEnd: DateTime(2026, 7, 31, 23, 59, 59, 999),
      );
      expect(selection.displayRangeLabel, 'July 2026');
    });

    test('withDay sets a single calendar day', () {
      final selection = ReportPeriodSelection.current(
        ReportPeriod.day,
      ).withDay(DateTime(2026, 7, 4, 15, 30));
      expect(selection.rangeStart, DateTime(2026, 7, 4));
      expect(selection.rangeEnd.day, 4);
      expect(selection.rangeEnd.hour, 23);
      expect(selection.displayRangeLabel, contains('Jul 4'));
    });

    test('day range start/end keep a single calendar day', () {
      final selection = ReportPeriodSelection.current(
        ReportPeriod.day,
      ).withRangeStart(DateTime(2026, 7, 1)).withRangeEnd(DateTime(2026, 7, 3));
      expect(startOfDay(selection.rangeStart), DateTime(2026, 7, 3));
      expect(selection.rangeEnd.day, 3);
      expect(selection.displayRangeLabel.contains('–'), isFalse);
    });
  });

  group('buildSaleDateViewFilter', () {
    test('includes date range and branch', () {
      final filter = buildSaleDateViewFilter(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 2, 1),
        branchId: 'branch-1',
      );
      expect(filter, contains("sale_date >= '2026-01-01'"));
      expect(filter, contains("sale_date <= '2026-02-01'"));
      expect(filter, contains('branch = "branch-1"'));
    });

    test('month filter uses YYYY-MM', () {
      final filter = buildViewDateRangeFilter(
        field: 'sale_month',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 12, 31),
        asMonth: true,
      );
      expect(filter, contains("sale_month >= '2026-01'"));
      expect(filter, contains("sale_month <= '2026-12'"));
    });

    test('year filter uses unquoted YYYY (JSON number field)', () {
      final filter = buildViewDateRangeFilter(
        field: 'sale_year',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2026, 12, 31),
        asYear: true,
      );
      // Yearly views store sale_year as a number; quoted strings return 0 rows.
      expect(filter, contains('sale_year >= 2024'));
      expect(filter, contains('sale_year <= 2026'));
      expect(filter, isNot(contains("'2024'")));
      expect(filter, isNot(contains("'2026'")));
    });
  });

  group('zeroFillBuckets', () {
    test('week returns 7 day buckets', () {
      final monday = DateTime(2026, 7, 13);
      final sunday = DateTime(2026, 7, 19);
      final buckets = zeroFillBuckets(
        values: {monday: 10},
        rangeStart: monday,
        rangeEnd: sunday,
        grain: TrendGranularity.day,
      );
      expect(buckets.length, 7);
      expect(buckets.first.value, 10);
      expect(buckets[1].value, 0);
      expect(buckets.first.label, isNotEmpty);
    });

    test('year returns 12 month buckets', () {
      final buckets = zeroFillBuckets(
        values: {DateTime(2026, 3): 5},
        rangeStart: DateTime(2026, 1, 1),
        rangeEnd: DateTime(2026, 12, 31),
        grain: TrendGranularity.month,
      );
      expect(buckets.length, 12);
      expect(buckets[2].value, 5); // March
      expect(buckets[0].value, 0);
      expect(buckets[0].label, 'Jan');
    });

    test('all time returns year buckets', () {
      final buckets = zeroFillBuckets(
        values: {DateTime(2025): 100},
        rangeStart: DateTime(2024),
        rangeEnd: DateTime(2026),
        grain: TrendGranularity.year,
      );
      expect(buckets.length, 3);
      expect(buckets[1].value, 100);
      expect(buckets[1].label, '2025');
    });
  });

  group('parseBucketStart', () {
    test('parses day and month keys', () {
      expect(
        parseBucketStart('2026-07-14', TrendGranularity.day),
        DateTime(2026, 7, 14),
      );
      expect(
        parseBucketStart('2026-07', TrendGranularity.month),
        DateTime(2026, 7),
      );
      expect(parseBucketStart('2026', TrendGranularity.year), DateTime(2026));
    });
  });

  group('view selectors', () {
    test('salesSummaryViewFor maps periods', () {
      expect(
        salesSummaryViewFor(ReportPeriod.day).collection,
        'vw_sales_daily_summary',
      );
      expect(
        salesSummaryViewFor(ReportPeriod.monthly).collection,
        'vw_sales_weekly_summary',
      );
      expect(
        salesSummaryViewFor(ReportPeriod.yearly).collection,
        'vw_sales_monthly_summary',
      );
      expect(
        salesSummaryViewFor(ReportPeriod.allTime).collection,
        'vw_sales_yearly_summary',
      );
    });

    test('yearly charts use yearly views not monthly', () {
      expect(
        revenueByItemTypeViewFor(ReportPeriod.yearly).collection,
        'vw_revenue_by_item_type_yearly',
      );
      expect(revenueByItemTypeViewFor(ReportPeriod.yearly).asYear, isTrue);
      expect(
        topSellingViewFor(ReportPeriod.yearly).collection,
        'vw_top_selling_products_yearly',
      );
      expect(topSellingViewFor(ReportPeriod.yearly).asYear, isTrue);
    });
  });

  group('aggregateRevenueByItemType', () {
    test('groups product membership addon and defaults empty to product', () {
      final result = aggregateRevenueByItemType([
        (itemType: 'product', subtotal: 100),
        (itemType: 'membership', subtotal: 500),
        (itemType: 'addon', subtotal: 50),
        (itemType: null, subtotal: 25),
        (itemType: '', subtotal: 10),
      ]);
      expect(result['product'], 135);
      expect(result['membership'], 500);
      expect(result['addon'], 50);
    });
  });

  group('itemTypeLabel', () {
    test('maps known types', () {
      expect(itemTypeLabel('product'), 'Product');
      expect(itemTypeLabel('membership'), 'Membership');
      expect(itemTypeLabel('addon'), 'Add-on');
      expect(itemTypeLabel('walkIn'), 'Walk-in');
    });
  });

  group('primarySalesItemTypeTotals', () {
    test('sums product, membership, and walkIn; ignores addon', () {
      final totals = primarySalesItemTypeTotals({
        'product': 400,
        'membership': 900,
        'walkIn': 200,
        'addon': 50,
        '': 25,
      });
      expect(totals.productTotal, 425);
      expect(totals.membershipTotal, 900);
      expect(totals.walkInTotal, 200);
      expect(totals.productCount, 0);
      expect(totals.membershipCount, 0);
      expect(totals.walkInCount, 0);
    });

    test('sums transaction counts with revenue; ignores addon counts', () {
      final totals = primarySalesItemTypeTotals(
        {
          'product': 400,
          'membership': 900,
          'walkIn': 200,
          'addon': 50,
        },
        transactionCountByItemType: {
          'product': 4,
          'membership': 2,
          'walkIn': 5,
          'addon': 9,
          '': 1,
        },
      );
      expect(totals.productCount, 5);
      expect(totals.membershipCount, 2);
      expect(totals.walkInCount, 5);
    });

    test('returns zeros for empty map', () {
      final totals = primarySalesItemTypeTotals(const {});
      expect(totals.productTotal, 0);
      expect(totals.membershipTotal, 0);
      expect(totals.walkInTotal, 0);
      expect(totals.productCount, 0);
      expect(totals.membershipCount, 0);
      expect(totals.walkInCount, 0);
    });

    test('treats null transaction counts as empty', () {
      final totals = primarySalesItemTypeTotals(
        {'membership': 100},
        transactionCountByItemType: null,
      );
      expect(totals.membershipTotal, 100);
      expect(totals.membershipCount, 0);
    });
  });

  group('aggregateScopedTransactionCountByItemType', () {
    test('counts distinct sales per type within reportable set', () {
      final counts = aggregateScopedTransactionCountByItemType(
        [
          (saleId: 's1', itemType: 'membership'),
          (saleId: 's1', itemType: 'membership'),
          (saleId: 's2', itemType: 'walkIn'),
          (saleId: 's3', itemType: 'product'),
          (saleId: 's4', itemType: 'product'), // excluded
          (saleId: 's5', itemType: 'addon'),
        ],
        {'s1', 's2', 's3', 's5'},
      );
      expect(counts['membership'], 1);
      expect(counts['walkIn'], 1);
      expect(counts['product'], 1);
      expect(counts['addon'], 1);
    });
  });

  group('aggregateScopedItemTypeMetrics', () {
    test('returns matching revenue and distinct sale counts together', () {
      final metrics = aggregateScopedItemTypeMetrics(
        [
          (saleId: 's1', itemType: 'membership', subtotal: 500),
          (saleId: 's1', itemType: 'membership', subtotal: 100),
          (saleId: 's2', itemType: 'walkIn', subtotal: 150),
          (saleId: 's3', itemType: 'product', subtotal: 40),
          (saleId: 's3', itemType: '', subtotal: 10),
          (saleId: 's4', itemType: 'product', subtotal: 99), // excluded
        ],
        {'s1', 's2', 's3'},
      );
      expect(metrics.revenueByItemType['membership'], 600);
      expect(metrics.revenueByItemType['walkIn'], 150);
      expect(metrics.revenueByItemType['product'], 50);
      expect(metrics.transactionCountByItemType['membership'], 1);
      expect(metrics.transactionCountByItemType['walkIn'], 1);
      expect(metrics.transactionCountByItemType['product'], 1);
    });
  });

  group('salesCountLabel', () {
    test('singular and plural', () {
      expect(salesCountLabel(1), '1 sale');
      expect(salesCountLabel(0), '0 sales');
      expect(salesCountLabel(12), '12 sales');
    });
  });

  group('usesPeriodScopedSalesFetch', () {
    test('is true for day, week, and month', () {
      expect(usesPeriodScopedSalesFetch(ReportPeriod.day), isTrue);
      expect(usesPeriodScopedSalesFetch(ReportPeriod.weekly), isTrue);
      expect(usesPeriodScopedSalesFetch(ReportPeriod.monthly), isTrue);
      expect(usesPeriodScopedSalesFetch(ReportPeriod.yearly), isFalse);
      expect(usesPeriodScopedSalesFetch(ReportPeriod.allTime), isFalse);
    });
  });

  group('netPaymentAmount', () {
    test('subtracts refunds', () {
      expect(netPaymentAmount(type: 'payment', amount: 100), 100);
      expect(netPaymentAmount(type: 'deposit', amount: 50), 50);
      expect(netPaymentAmount(type: 'refund', amount: 25), -25);
      expect(netPaymentAmount(type: 'Refund', amount: 10), -10);
    });
  });

  group('isReportableSaleStatus', () {
    test('includes completed and paid only', () {
      expect(isReportableSaleStatus('completed'), isTrue);
      expect(isReportableSaleStatus('paid'), isTrue);
      expect(isReportableSaleStatus('pending'), isFalse);
      expect(isReportableSaleStatus('awaitingPayment'), isFalse);
      expect(isReportableSaleStatus('voided'), isFalse);
    });
  });

  group('aggregateScopedSalesPayments', () {
    test('sums payments for completed sales and buckets by day', () {
      final day = DateTime(2026, 8, 1, 10);
      final result = aggregateScopedSalesPayments(
        sales: [
          (saleId: 's1', status: 'completed', created: day),
          (saleId: 's2', status: 'completed', created: day),
          (saleId: 's3', status: 'pending', created: day),
          (saleId: 's4', status: 'completed', created: null),
        ],
        payments: [
          (saleId: 's1', paymentMethod: 'cash', type: 'payment', amount: 100),
          (saleId: 's1', paymentMethod: 'card', type: 'payment', amount: 50),
          (saleId: 's2', paymentMethod: 'cash', type: 'refund', amount: 20),
          (saleId: 's3', paymentMethod: 'cash', type: 'payment', amount: 999),
        ],
        grain: TrendGranularity.day,
      );

      expect(result.transactionCount, 2); // s1 + s2 (s4 missing created)
      expect(result.totalRevenue, 130); // 100+50-20
      expect(result.revenueByPaymentMethod['cash'], 80);
      expect(result.revenueByPaymentMethod['card'], 50);
      expect(result.revenueByBucket[DateTime(2026, 8, 1)], 130);
    });

    test('includes paid status sales from checkout', () {
      final day = DateTime(2026, 8, 1, 3, 56);
      final result = aggregateScopedSalesPayments(
        sales: [
          (saleId: 's1', status: 'paid', created: day),
          (saleId: 's2', status: 'awaitingPayment', created: day),
        ],
        payments: [
          (saleId: 's1', paymentMethod: 'cash', type: 'payment', amount: 800),
          (saleId: 's2', paymentMethod: 'cash', type: 'payment', amount: 100),
        ],
        grain: TrendGranularity.day,
      );

      expect(result.transactionCount, 1);
      expect(result.totalRevenue, 800);
      expect(result.revenueByPaymentMethod['cash'], 800);
    });

    test('counts completed sales with no payments', () {
      final result = aggregateScopedSalesPayments(
        sales: [
          (saleId: 's1', status: 'completed', created: DateTime(2026, 8, 1)),
        ],
        payments: const [],
        grain: TrendGranularity.day,
      );
      expect(result.transactionCount, 1);
      expect(result.totalRevenue, 0);
    });
  });

  group('aggregateScopedRevenueByItemType', () {
    test('only includes completed sale lines', () {
      final result = aggregateScopedRevenueByItemType(
        [
          (saleId: 's1', itemType: 'product', subtotal: 100),
          (saleId: 's2', itemType: 'membership', subtotal: 500),
          (saleId: 's3', itemType: 'product', subtotal: 50),
        ],
        {'s1', 's2'},
      );
      expect(result['product'], 100);
      expect(result['membership'], 500);
      expect(result['product'], isNot(150));
    });
  });

  group('daySalesKpisFromSales', () {
    test('counts paid completed sales and skips voided', () {
      final result = daySalesKpisFromSales([
        (status: 'paid', isPaid: true, totalAmount: 100),
        (status: 'completed', isPaid: true, totalAmount: 50),
        (status: 'paid', isPaid: false, totalAmount: 80),
        (status: 'voided', isPaid: true, totalAmount: 999),
        (status: 'awaitingPayment', isPaid: false, totalAmount: 40),
      ]);
      expect(result.transactionCount, 3);
      expect(result.totalRevenue, 150);
    });

    test('returns zeros for empty input', () {
      final result = daySalesKpisFromSales(const []);
      expect(result.transactionCount, 0);
      expect(result.totalRevenue, 0);
    });
  });

  group('aggregateUnpaidSales', () {
    test('sums unpaid balance and skips voided', () {
      final result = aggregateUnpaidSales([
        (status: 'completed', isPaid: false, totalAmount: 100),
        (status: 'pending', isPaid: false, totalAmount: 50),
        (status: 'paid', isPaid: true, totalAmount: 200),
        (status: 'voided', isPaid: false, totalAmount: 999),
        (status: 'refunded', isPaid: false, totalAmount: 888),
        (status: 'completed', isPaid: false, totalAmount: 0),
      ]);
      expect(result.unpaidCount, 2);
      expect(result.unpaidBalance, 150);
    });
  });

  group('aggregateStaffPerformance', () {
    test('groups by cashier and ranks by revenue', () {
      final result = aggregateStaffPerformance(
        [
          (status: 'completed', cashierId: 'c1', totalAmount: 100),
          (status: 'paid', cashierId: 'c1', totalAmount: 50),
          (status: 'completed', cashierId: 'c2', totalAmount: 300),
          (status: 'voided', cashierId: 'c2', totalAmount: 999),
          (status: 'refunded', cashierId: 'c2', totalAmount: 888),
          (status: 'completed', cashierId: '', totalAmount: 40),
        ],
        staffNames: {'c1': 'Alice', 'c2': 'Bob'},
      );
      expect(result.length, 2);
      expect(result.first.staffId, 'c2');
      expect(result.first.staffName, 'Bob');
      expect(result.first.revenue, 300);
      expect(result.first.transactionCount, 1);
      expect(result.last.staffName, 'Alice');
      expect(result.last.transactionCount, 2);
      expect(result.last.revenue, 150);
    });

    test('uses Unknown when name missing', () {
      final result = aggregateStaffPerformance([
        (status: 'completed', cashierId: 'c9', totalAmount: 10),
      ]);
      expect(result.single.staffName, 'Unknown');
    });
  });

  group('aggregateTopSellingItems', () {
    test('includes every item type ranked by revenue', () {
      final result = aggregateTopSellingItems([
        (name: 'Protein Shake', itemType: 'product', quantity: 3, revenue: 300),
        (
          name: 'Monthly Plan',
          itemType: 'membership',
          quantity: 2,
          revenue: 2000,
        ),
        (name: 'Day Pass', itemType: 'walkIn', quantity: 5, revenue: 500),
        (name: 'Locker', itemType: 'addon', quantity: 1, revenue: 50),
        (name: 'Custom Line', itemType: 'other', quantity: 10, revenue: 900),
      ]);

      expect(result.map((e) => e.name).toList(), [
        'Monthly Plan',
        'Custom Line',
        'Day Pass',
        'Protein Shake',
        'Locker',
      ]);
      expect(result.first.itemType, 'membership');
    });

    test('keeps same name product and membership separate', () {
      final result = aggregateTopSellingItems([
        (name: 'Day Pass', itemType: 'product', quantity: 1, revenue: 100),
        (name: 'Day Pass', itemType: 'membership', quantity: 2, revenue: 200),
        (name: 'Day Pass', itemType: 'product', quantity: 1, revenue: 50),
      ]);

      expect(result.length, 2);
      expect(result.firstWhere((e) => e.itemType == 'membership').revenue, 200);
      expect(result.firstWhere((e) => e.itemType == 'product').revenue, 150);
    });
  });

  group('salesItemTypeBucket', () {
    test('maps guest membership lines to walkIn', () {
      expect(
        salesItemTypeBucket(itemType: 'membership', hasLinkedMember: false),
        'walkIn',
      );
      expect(
        salesItemTypeBucket(itemType: 'addon', hasLinkedMember: false),
        'walkIn',
      );
      expect(
        salesItemTypeBucket(itemType: 'membership', hasLinkedMember: true),
        'membership',
      );
      expect(
        salesItemTypeBucket(itemType: 'product', hasLinkedMember: false),
        'product',
      );
    });
  });

  group('includeInMembershipReport', () {
    test('excludes walk-in sales and memberNotRequired plans', () {
      expect(includeInMembershipReport(saleHasLinkedMember: false), isFalse);
      expect(
        includeInMembershipReport(
          saleHasLinkedMember: true,
          planMemberNotRequired: true,
        ),
        isFalse,
      );
      expect(includeInMembershipReport(saleHasLinkedMember: true), isTrue);
    });
  });

  group('sumMembershipReportSaleRevenue', () {
    test('skips walk-in lines and sums membership vs addon', () {
      final result = sumMembershipReportSaleRevenue([
        (itemType: 'membership', subtotal: 500, hasLinkedMember: true),
        (itemType: 'addon', subtotal: 50, hasLinkedMember: true),
        (itemType: 'membership', subtotal: 100, hasLinkedMember: false),
        (itemType: 'addon', subtotal: 25, hasLinkedMember: false),
        (itemType: 'product', subtotal: 80, hasLinkedMember: true),
      ]);
      expect(result.membershipRevenue, 500);
      expect(result.addOnRevenue, 50);
    });
  });

  group('classifyNewVsRenewals', () {
    test('counts first-time vs renewals', () {
      final period = [
        (id: 'mm1', memberId: 'm1', created: DateTime(2026, 6, 1)),
        (id: 'mm2', memberId: 'm2', created: DateTime(2026, 6, 2)),
      ];
      final priors = {
        'm1': [DateTime(2025, 1, 1)],
        'm2': <DateTime>[],
      };
      final result = classifyNewVsRenewals(period, priors);
      expect(result.renewals, 1);
      expect(result.newSubscriptions, 1);
    });
  });

  group('buildIdOrFilters', () {
    test('chunks ids', () {
      final ids = List.generate(3, (i) => 'id$i');
      final filters = buildIdOrFilters('member', ids, chunkSize: 2);
      expect(filters.length, 2);
    });
  });

  group('saleItemMatchesPrimaryType', () {
    test('membership and walkIn match exact type', () {
      expect(saleItemMatchesPrimaryType('membership', 'membership'), isTrue);
      expect(saleItemMatchesPrimaryType('walkIn', 'walkIn'), isTrue);
      expect(saleItemMatchesPrimaryType('product', 'membership'), isFalse);
      expect(saleItemMatchesPrimaryType('addon', 'membership'), isFalse);
    });

    test('empty/null item type matches product only', () {
      expect(saleItemMatchesPrimaryType(null, 'product'), isTrue);
      expect(saleItemMatchesPrimaryType('', 'product'), isTrue);
      expect(saleItemMatchesPrimaryType('product', 'product'), isTrue);
      expect(saleItemMatchesPrimaryType('addon', 'product'), isFalse);
      expect(saleItemMatchesPrimaryType(null, 'membership'), isFalse);
    });
  });

  group('saleItemsRawFilterForPrimaryType', () {
    test('builds expected filters', () {
      expect(
        saleItemsRawFilterForPrimaryType('membership'),
        "itemType = 'membership'",
      );
      expect(
        saleItemsRawFilterForPrimaryType('walkIn'),
        "itemType = 'walkIn'",
      );
      expect(
        saleItemsRawFilterForPrimaryType('product'),
        "(itemType = 'product' || itemType = '')",
      );
    });
  });

  group('distinctSaleIdsForPrimaryItemType', () {
    test('returns distinct matching sale ids', () {
      final items = [
        (saleId: 's1', itemType: 'membership'),
        (saleId: 's1', itemType: 'addon'),
        (saleId: 's2', itemType: 'product'),
        (saleId: 's3', itemType: ''),
        (saleId: 's4', itemType: 'walkIn'),
        (saleId: '', itemType: 'membership'),
      ];
      expect(
        distinctSaleIdsForPrimaryItemType(items, 'membership'),
        ['s1'],
      );
      expect(
        distinctSaleIdsForPrimaryItemType(items, 'product'),
        ['s2', 's3'],
      );
      expect(
        distinctSaleIdsForPrimaryItemType(items, 'walkIn'),
        ['s4'],
      );
    });
  });

  group('descriptorDetailAfterCustomerName', () {
    test('returns plan fragment after name', () {
      expect(
        descriptorDetailAfterCustomerName('Juan Dela Cruz · Monthly Plan'),
        'Monthly Plan',
      );
      expect(
        descriptorDetailAfterCustomerName('Juan · Plan · Extra'),
        'Plan · Extra',
      );
      expect(descriptorDetailAfterCustomerName('WATER'), isNull);
      expect(descriptorDetailAfterCustomerName(null), isNull);
      expect(descriptorDetailAfterCustomerName(' · Plan'), isNull);
    });
  });

  group('shouldCapSalesByItemType', () {
    test('caps year and allTime only', () {
      expect(shouldCapSalesByItemType(ReportPeriod.day), isFalse);
      expect(shouldCapSalesByItemType(ReportPeriod.weekly), isFalse);
      expect(shouldCapSalesByItemType(ReportPeriod.monthly), isFalse);
      expect(shouldCapSalesByItemType(ReportPeriod.yearly), isTrue);
      expect(shouldCapSalesByItemType(ReportPeriod.allTime), isTrue);
    });
  });

  group('aggregateCheckInsByHour', () {
    test('buckets by hour', () {
      final result = aggregateCheckInsByHour([
        DateTime(2026, 1, 1, 9),
        DateTime(2026, 1, 1, 9, 30),
        DateTime(2026, 1, 1, 18),
      ]);
      expect(result['09'], 2);
      expect(result['18'], 1);
    });
  });
}
