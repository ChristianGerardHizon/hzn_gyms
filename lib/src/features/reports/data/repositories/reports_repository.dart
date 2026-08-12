import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../pos/data/dto/sale_dto.dart';
import '../../../pos/domain/sale.dart';
import '../../domain/attendance_report.dart';
import '../../domain/inventory_report.dart';
import '../../domain/membership_report.dart';
import '../../domain/period_bucket.dart';
import '../../domain/report_aggregations.dart';
import '../../domain/report_period.dart';
import '../../domain/sales_report.dart';

part 'reports_repository.g.dart';

/// Repository for fetching and aggregating report data.
abstract class ReportsRepository {
  /// View-based sales KPIs and charts (Month / Year / All Time).
  FutureEither<SalesReport> getSalesReport({
    required ReportPeriodSelection period,
    String? branchId,
  });

  /// Lean unpaid / staff / Day transaction list (Month / Year / All Time).
  FutureEither<SalesReportExtras> getSalesReportExtras({
    required ReportPeriodSelection period,
    String? branchId,
  });

  /// Period-scoped Day/Week sales (one fetch for KPIs + extras).
  FutureEither<ScopedSalesReportBundle> getScopedSalesReportBundle({
    required ReportPeriodSelection period,
    String? branchId,
  });

  /// Sales that include at least one line of [itemType] in [period].
  ///
  /// [itemType] is `membership` / `walkIn` / `product`. Year / All Time are
  /// capped at [kSalesByItemTypeYearCap] (newest first).
  FutureEither<List<Sale>> getSalesByItemType({
    required ReportPeriodSelection period,
    required String itemType,
    String? branchId,
  });

  FutureEither<InventoryReport> getInventoryReport({String? branchId});

  FutureEither<MembershipReport> getMembershipReport({
    required ReportPeriodSelection period,
    String? branchId,
  });

  FutureEither<AttendanceReport> getAttendanceReport({
    required ReportPeriodSelection period,
    String? branchId,
  });
}

@Riverpod(keepAlive: true)
ReportsRepository reportsRepository(Ref ref) {
  return ReportsRepositoryImpl(ref.watch(pocketbaseProvider));
}

class ReportsRepositoryImpl implements ReportsRepository {
  final PocketBase _pb;

  ReportsRepositoryImpl(this._pb);

  RecordService get _members => _pb.collection(PocketBaseCollections.members);
  RecordService get _memberMemberships =>
      _pb.collection(PocketBaseCollections.memberMemberships);
  RecordService get _memberMembershipAddOns =>
      _pb.collection(PocketBaseCollections.memberMembershipAddOns);
  RecordService get _saleItems =>
      _pb.collection(PocketBaseCollections.saleItems);
  RecordService get _sales => _pb.collection(PocketBaseCollections.sales);
  RecordService get _payments => _pb.collection(PocketBaseCollections.payments);
  RecordService get _checkIns => _pb.collection(PocketBaseCollections.checkIns);

  String? _viewFilter(
    ReportPeriodSelection period, {
    required String dateField,
    required bool asMonth,
    required bool asYear,
    String? branchId,
  }) {
    return buildViewDateRangeFilter(
      field: dateField,
      startDate: period.startDate,
      endDate: period.endDate,
      branchId: branchId,
      asMonth: asMonth,
      asYear: asYear,
    );
  }

  /// PocketBase `fields` for Day transaction list (no expand).
  static const _daySaleListFields =
      'id,receiptNumber,branch,cashier,totalAmount,status,isPaid,'
      'member,customerName,descriptor,notes,voidedBy,created,updated';

  /// Minimal fields for unpaid + staff aggregation on longer periods.
  static const _leanSaleAggFields = 'id,cashier,totalAmount,status,isPaid';

  /// Week scoped path needs `created` for day trend buckets.
  static const _scopedWeekSaleFields =
      'id,cashier,totalAmount,status,isPaid,created';

  static const _paymentAggFields = 'id,sale,amount,paymentMethod,type';

  static const _saleItemAggFields =
      'id,sale,productName,quantity,subtotal,itemType';

  @override
  FutureEither<ScopedSalesReportBundle> getScopedSalesReportBundle({
    required ReportPeriodSelection period,
    String? branchId,
  }) async {
    return TaskEither.tryCatch(() async {
      final includeSalesList = period.period == ReportPeriod.day;
      final grain = period.trendGranularity;

      final salePeriodFilter = PBFilter()
          .between('created', period.startDate, period.endDate)
          .raw(
            "(status = 'completed' || status = 'paid' || "
            "status = 'awaitingPayment' || status = 'pending')",
          );
      if (branchId != null) {
        salePeriodFilter.relation('branch', branchId);
      }

      final saleRecords = await _sales.getFullList(
        filter: salePeriodFilter.build(),
        fields: includeSalesList ? _daySaleListFields : _scopedWeekSaleFields,
        sort: includeSalesList ? '-created' : null,
      );

      if (saleRecords.isEmpty) {
        return ScopedSalesReportBundle.empty;
      }

      final saleIds = saleRecords.map((r) => r.id).toList(growable: false);
      final paymentFilters = buildIdOrFilters('sale', saleIds);
      final itemFilters = buildIdOrFilters('sale', saleIds);

      final leanRows = saleRecords
          .map(
            (sale) => (
              status: sale.getStringValue('status'),
              isPaid: sale.getBoolValue('isPaid'),
              totalAmount: sale.getDoubleValue('totalAmount'),
              cashierId: sale.getStringValue('cashier'),
              created: DateTime.tryParse(
                sale.getStringValue('created'),
              )?.toLocal(),
              saleId: sale.id,
            ),
          )
          .toList(growable: false);

      final cashierIds = leanRows
          .map((r) => r.cashierId)
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      final paymentChunksFuture = Future.wait(
        paymentFilters.map(
          (f) => _payments.getFullList(filter: f, fields: _paymentAggFields),
        ),
      );
      final itemChunksFuture = Future.wait(
        itemFilters.map(
          (f) => _saleItems.getFullList(filter: f, fields: _saleItemAggFields),
        ),
      );
      final staffNamesFuture = _fetchUserDisplayNames(cashierIds);
      final paymentChunks = await paymentChunksFuture;
      final itemChunks = await itemChunksFuture;
      final staffNames = await staffNamesFuture;
      final paymentRecords = paymentChunks.expand((e) => e).toList();
      final itemRecords = itemChunks.expand((e) => e).toList();

      final paymentRows = paymentRecords.map(
        (p) => (
          saleId: p.getStringValue('sale'),
          paymentMethod: p.getStringValue('paymentMethod'),
          type: p.getStringValue('type'),
          amount: p.getDoubleValue('amount'),
        ),
      );

      final kpis = aggregateScopedSalesPayments(
        sales: leanRows.map(
          (r) => (saleId: r.saleId, status: r.status, created: r.created),
        ),
        payments: paymentRows,
        grain: grain,
      );

      final reportableSaleIds = leanRows
          .where((r) => isReportableSaleStatus(r.status))
          .map((r) => r.saleId)
          .toSet();

      final itemRows = itemRecords
          .map(
            (item) => (
              saleId: item.getStringValue('sale'),
              name: item.getStringValue('productName'),
              itemType: item.getStringValue('itemType'),
              quantity: item.getDoubleValue('quantity'),
              subtotal: item.getDoubleValue('subtotal'),
            ),
          )
          .toList(growable: false);

      final topProducts =
          aggregateTopSellingItems(
                itemRows
                    .where((i) => reportableSaleIds.contains(i.saleId))
                    .map(
                      (i) => (
                        name: i.name,
                        itemType: i.itemType,
                        quantity: i.quantity,
                        revenue: i.subtotal,
                      ),
                    ),
              )
              .map(
                (e) => ProductSalesSummary(
                  productName: e.name,
                  quantity: e.quantity,
                  revenue: e.revenue,
                  itemType: e.itemType,
                ),
              )
              .take(10)
              .toList();

      final itemTypeMetrics = aggregateScopedItemTypeMetrics(
        itemRows.map(
          (i) => (
            saleId: i.saleId,
            itemType: i.itemType,
            subtotal: i.subtotal,
          ),
        ),
        reportableSaleIds,
      );
      final revenueByItemType = itemTypeMetrics.revenueByItemType;
      final transactionCountByItemType =
          itemTypeMetrics.transactionCountByItemType;

      final avgValue = kpis.transactionCount > 0
          ? kpis.totalRevenue / kpis.transactionCount
          : 0;

      final report = SalesReport(
        totalRevenue: kpis.totalRevenue,
        transactionCount: kpis.transactionCount,
        averageTransactionValue: avgValue,
        revenueTrend: zeroFillBuckets(
          values: kpis.revenueByBucket,
          rangeStart: period.startDate,
          rangeEnd: period.chartEndDate,
          grain: grain,
        ),
        revenueByPaymentMethod: kpis.revenueByPaymentMethod,
        topSellingProducts: topProducts,
        revenueByItemType: revenueByItemType,
        transactionCountByItemType: transactionCountByItemType,
      );

      final unpaid = aggregateUnpaidSales(
        leanRows.map(
          (r) =>
              (status: r.status, isPaid: r.isPaid, totalAmount: r.totalAmount),
        ),
      );

      final staff = aggregateStaffPerformance(
        leanRows.map(
          (r) => (
            status: r.status,
            cashierId: r.cashierId,
            totalAmount: r.totalAmount,
          ),
        ),
        staffNames: staffNames,
      );

      final periodSales = includeSalesList
          ? saleRecords
                .map((record) => SaleDto.fromRecord(record).toEntity())
                .toList()
          : const <Sale>[];

      final extras = SalesReportExtras(
        unpaidSalesCount: unpaid.unpaidCount,
        unpaidBalance: unpaid.unpaidBalance,
        staffPerformance: staff
            .map(
              (e) => StaffSalesSummary(
                staffId: e.staffId,
                staffName: e.staffName,
                transactionCount: e.transactionCount,
                revenue: e.revenue,
              ),
            )
            .toList(),
        sales: periodSales,
      );

      return ScopedSalesReportBundle(report: report, extras: extras);
    }, Failure.handle).run();
  }

  @override
  FutureEither<List<Sale>> getSalesByItemType({
    required ReportPeriodSelection period,
    required String itemType,
    String? branchId,
  }) async {
    return TaskEither.tryCatch(() async {
      final cap = shouldCapSalesByItemType(period.period)
          ? kSalesByItemTypeYearCap
          : null;
      final saleIds = await _collectSaleIdsByItemType(
        period: period,
        itemType: itemType,
        branchId: branchId,
        maxSales: cap,
      );
      if (saleIds.isEmpty) return const <Sale>[];

      final saleFilters = buildIdOrFilters('id', saleIds);
      final saleChunks = await Future.wait(
        saleFilters.map(
          (f) => _sales.getFullList(
            filter: f,
            fields: _daySaleListFields,
            sort: '-created',
          ),
        ),
      );
      final sales = saleChunks
          .expand((e) => e)
          .map((record) => SaleDto.fromRecord(record).toEntity())
          .toList();
      sales.sort((a, b) {
        final aCreated = a.created ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bCreated = b.created ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bCreated.compareTo(aCreated);
      });
      if (cap != null && sales.length > cap) {
        return sales.sublist(0, cap);
      }
      return sales;
    }, Failure.handle).run();
  }

  /// Collects distinct sale IDs with a matching primary item type in [period].
  Future<List<String>> _collectSaleIdsByItemType({
    required ReportPeriodSelection period,
    required String itemType,
    String? branchId,
    int? maxSales,
  }) async {
    final filter = PBFilter()
        .between('sale.created', period.startDate, period.endDate)
        .raw(saleItemsRawFilterForPrimaryType(itemType))
        .raw("(sale.status = 'completed' || sale.status = 'paid')");
    if (branchId != null) {
      filter.raw('sale.branch = "$branchId"');
    }
    final filterString = filter.build();

    if (maxSales == null) {
      final records = await _saleItems.getFullList(
        filter: filterString,
        fields: 'id,sale,itemType',
      );
      return distinctSaleIdsForPrimaryItemType(
        records.map(
          (r) => (
            saleId: r.getStringValue('sale'),
            itemType: r.getStringValue('itemType'),
          ),
        ),
        itemType,
      );
    }

    // Paginate newest-first until we have [maxSales] distinct sale IDs.
    final ids = <String>[];
    final seen = <String>{};
    const pageSize = 100;
    var page = 1;
    while (ids.length < maxSales) {
      final result = await _saleItems.getList(
        page: page,
        perPage: pageSize,
        filter: filterString,
        sort: '-sale.created',
        fields: 'id,sale,itemType',
      );
      if (result.items.isEmpty) break;
      for (final record in result.items) {
        final saleId = record.getStringValue('sale');
        if (saleId.isEmpty || seen.contains(saleId)) continue;
        if (!saleItemMatchesPrimaryType(
          record.getStringValue('itemType'),
          itemType,
        )) {
          continue;
        }
        seen.add(saleId);
        ids.add(saleId);
        if (ids.length >= maxSales) break;
      }
      if (result.items.length < pageSize) break;
      page++;
    }
    return ids;
  }

  @override
  FutureEither<SalesReport> getSalesReport({
    required ReportPeriodSelection period,
    String? branchId,
  }) async {
    return TaskEither.tryCatch(() async {
      final grain = period.trendGranularity;

      final salesView = salesSummaryViewFor(period.period);
      final itemView = revenueByItemTypeViewFor(period.period);
      final topView = topSellingViewFor(period.period);

      final salesFilter = _viewFilter(
        period,
        dateField: salesView.dateField,
        asMonth: salesView.asMonth,
        asYear: salesView.asYear,
        branchId: branchId,
      );
      final itemFilter = _viewFilter(
        period,
        dateField: itemView.dateField,
        asMonth: itemView.asMonth,
        asYear: itemView.asYear,
        branchId: branchId,
      );
      final topFilter = _viewFilter(
        period,
        dateField: topView.dateField,
        asMonth: topView.asMonth,
        asYear: topView.asYear,
        branchId: branchId,
      );

      final results = await Future.wait([
        _pb.collection(salesView.collection).getFullList(filter: salesFilter),
        _pb.collection(topView.collection).getFullList(filter: topFilter),
        _pb.collection(itemView.collection).getFullList(filter: itemFilter),
      ]);

      final summaryRecords = results[0];
      final topProductsRecords = results[1];
      final itemTypeRecords = results[2];

      if (summaryRecords.isEmpty && itemTypeRecords.isEmpty) {
        return SalesReport.empty;
      }

      num totalRevenue = 0;
      int transactionCount = 0;
      final revenueByBucket = <DateTime, num>{};
      final revenueByPaymentMethod = <String, num>{};

      for (final record in summaryRecords) {
        final dateStr = record.getStringValue(salesView.dateField);
        final revenue = record.getDoubleValue('total_revenue');
        final count = record.getIntValue('transaction_count');
        final paymentMethod = record.getStringValue('paymentMethod');

        totalRevenue += revenue;
        transactionCount += count;

        final bucket = parseBucketStart(dateStr, grain);
        if (bucket != null) {
          revenueByBucket[bucket] = (revenueByBucket[bucket] ?? 0) + revenue;
        }

        if (paymentMethod.isNotEmpty) {
          revenueByPaymentMethod[paymentMethod] =
              (revenueByPaymentMethod[paymentMethod] ?? 0) + revenue;
        }
      }

      final avgValue = transactionCount > 0
          ? totalRevenue / transactionCount
          : 0;

      // Include every sale line type (product, membership, walk-in, add-on, …).
      final topProducts =
          aggregateTopSellingItems(
                topProductsRecords.map(
                  (record) => (
                    name: record.getStringValue('productName'),
                    itemType: record.getStringValue('itemType'),
                    quantity: record.getDoubleValue('total_quantity_sold'),
                    revenue: record.getDoubleValue('total_revenue'),
                  ),
                ),
              )
              .map(
                (e) => ProductSalesSummary(
                  productName: e.name,
                  quantity: e.quantity,
                  revenue: e.revenue,
                  itemType: e.itemType,
                ),
              )
              .toList();

      final revenueByItemType = <String, num>{};
      final transactionCountByItemType = <String, int>{};
      for (final record in itemTypeRecords) {
        final type = record.getStringValue('itemType');
        // Historical walk-in rows may still be typed as membership/addon with
        // no linked member; views only expose itemType, so keep raw keys and
        // map empty → product. New guest sales use itemType `walkIn`.
        final key = normalizeSalesItemType(type);
        revenueByItemType[key] =
            (revenueByItemType[key] ?? 0) +
            record.getDoubleValue('total_revenue');
        transactionCountByItemType[key] =
            (transactionCountByItemType[key] ?? 0) +
            _transactionCountFromViewRecord(record);
      }

      final revenueTrend = zeroFillBuckets(
        values: revenueByBucket,
        rangeStart: period.startDate,
        rangeEnd: period.chartEndDate,
        grain: grain,
      );

      return SalesReport(
        totalRevenue: totalRevenue,
        transactionCount: transactionCount,
        averageTransactionValue: avgValue,
        revenueTrend: revenueTrend,
        revenueByPaymentMethod: revenueByPaymentMethod,
        topSellingProducts: topProducts.take(10).toList(),
        revenueByItemType: revenueByItemType,
        transactionCountByItemType: transactionCountByItemType,
      );
    }, Failure.handle).run();
  }

  @override
  FutureEither<SalesReportExtras> getSalesReportExtras({
    required ReportPeriodSelection period,
    String? branchId,
  }) async {
    return TaskEither.tryCatch(() async {
      // Year / All Time only reach here (Day/Week/Month use the scoped bundle).
      // Never getFullList every sale in the range — that pages 10k–100k rows and
      // saturates the API while the summary views are also running.
      final unpaidFilter = PBFilter()
          .between('created', period.startDate, period.endDate)
          .isFalse('isPaid')
          .raw(
            "(status = 'completed' || status = 'paid' || "
            "status = 'awaitingPayment' || status = 'pending')",
          );
      if (branchId != null) {
        unpaidFilter.relation('branch', branchId);
      }

      final unpaidRecords = await _sales.getFullList(
        filter: unpaidFilter.build(),
        fields: _leanSaleAggFields,
      );

      final unpaid = aggregateUnpaidSales(
        unpaidRecords.map(
          (sale) => (
            status: sale.getStringValue('status'),
            isPaid: sale.getBoolValue('isPaid'),
            totalAmount: sale.getDoubleValue('totalAmount'),
          ),
        ),
      );

      return SalesReportExtras(
        unpaidSalesCount: unpaid.unpaidCount,
        unpaidBalance: unpaid.unpaidBalance,
        // Staff needs every sale in range; skip on Year/All Time for speed.
        // Day/Week/Month staff comes from [getScopedSalesReportBundle].
        staffPerformance: const [],
      );
    }, Failure.handle).run();
  }

  Future<Map<String, String>> _fetchUserDisplayNames(
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) return const {};
    final filters = buildIdOrFilters('id', userIds);
    final chunks = await Future.wait(
      filters.map(
        (f) => _pb
            .collection(PocketBaseCollections.users)
            .getFullList(filter: f, fields: 'id,name,username'),
      ),
    );
    final names = <String, String>{};
    for (final record in chunks.expand((e) => e)) {
      final name = record.getStringValue('name');
      final username = record.getStringValue('username');
      names[record.id] = name.isNotEmpty
          ? name
          : (username.isNotEmpty ? username : 'Unknown');
    }
    return names;
  }

  @override
  FutureEither<InventoryReport> getInventoryReport({String? branchId}) async {
    return TaskEither.tryCatch(() async {
      final branchFilter = branchId != null ? 'branch = "$branchId"' : null;

      final results = await Future.wait([
        _pb
            .collection(PocketBaseCollections.vwInventoryStatus)
            .getFullList(filter: branchFilter),
        _pb
            .collection(PocketBaseCollections.vwLowStockProducts)
            .getFullList(filter: branchFilter),
        _pb
            .collection(PocketBaseCollections.vwLowStockLotProducts)
            .getFullList(filter: branchFilter),
        _pb
            .collection(PocketBaseCollections.vwExpiredLots)
            .getFullList(filter: branchFilter),
        _pb
            .collection(PocketBaseCollections.vwNearExpirationLots)
            .getFullList(filter: branchFilter),
      ]);

      return _aggregateInventoryFromViews(
        inventoryRecords: results[0],
        lowStockRecords: results[1],
        lowStockLotRecords: results[2],
        expiredLotCount: results[3].length,
        nearExpirationLotCount: results[4].length,
      );
    }, Failure.handle).run();
  }

  InventoryReport _aggregateInventoryFromViews({
    required List<RecordModel> inventoryRecords,
    required List<RecordModel> lowStockRecords,
    required List<RecordModel> lowStockLotRecords,
    required int expiredLotCount,
    required int nearExpirationLotCount,
  }) {
    var inStockCount = 0;
    var lowStockCount = 0;
    var outOfStockCount = 0;
    num totalValue = 0;
    final byCategory = <String, int>{};
    final stockStatus = <String, int>{};
    final lowStockItems = <LowStockItem>[];

    for (final product in inventoryRecords) {
      final trackByLot = product.getBoolValue('trackByLot');
      final quantity = product.getDoubleValue('quantity');
      final lotTotal = product.getDoubleValue('lot_total_quantity');
      final threshold = product.getDoubleValue('stockThreshold');
      final price = product.getDoubleValue('price');
      final qty = effectiveStockQuantity(
        trackByLot: trackByLot,
        quantity: quantity,
        lotTotalQuantity: lotTotal,
      );

      totalValue += qty * price;

      final label = stockStatusLabel(qty: qty, threshold: threshold);
      stockStatus[label] = (stockStatus[label] ?? 0) + 1;
      switch (label) {
        case 'Out of Stock':
          outOfStockCount++;
        case 'Low Stock':
          lowStockCount++;
        default:
          inStockCount++;
      }

      final categoryId = product.getStringValue('category');
      final categoryName = categoryId.isEmpty ? 'Uncategorized' : categoryId;
      final categoryExpand = product.get<RecordModel?>('expand.category');
      final resolvedCategory =
          categoryExpand?.getStringValue('name') ?? categoryName;
      byCategory[resolvedCategory] = (byCategory[resolvedCategory] ?? 0) + 1;
    }

    for (final record in lowStockRecords) {
      lowStockItems.add(
        LowStockItem(
          productName: record.getStringValue('name'),
          categoryName: '—',
          currentStock: record.getDoubleValue('quantity'),
          threshold: record.getDoubleValue('stockThreshold'),
          expirationDate: null,
        ),
      );
    }
    for (final record in lowStockLotRecords) {
      lowStockItems.add(
        LowStockItem(
          productName: record.getStringValue('name'),
          categoryName: '—',
          currentStock: record.getDoubleValue('total_quantity'),
          threshold: record.getDoubleValue('stockThreshold'),
          expirationDate: null,
        ),
      );
    }

    if (inventoryRecords.isEmpty) {
      lowStockCount = lowStockItems.length;
    }

    return InventoryReport(
      totalProducts: inventoryRecords.length,
      inStockCount: inStockCount,
      lowStockCount: lowStockCount,
      outOfStockCount: outOfStockCount,
      expiredCount: expiredLotCount,
      nearExpirationCount: nearExpirationLotCount,
      totalInventoryValue: totalValue,
      productsByCategory: byCategory,
      stockStatusBreakdown: stockStatus,
      lowStockItems: lowStockItems,
    );
  }

  @override
  FutureEither<MembershipReport> getMembershipReport({
    required ReportPeriodSelection period,
    String? branchId,
  }) async {
    return TaskEither.tryCatch(() async {
      final startDate = period.startDate;
      final endDate = period.endDate;
      final grain = period.trendGranularity;

      final branchFilter = branchId != null
          ? PBFilter().relation('branch', branchId)
          : PBFilter();

      final periodFilter = PBFilter().between('created', startDate, endDate);
      final mmPeriodFilter = PBFilter().and(branchFilter).and(periodFilter);

      final now = DateTime.now();
      final activeFilter = PBFilter()
          .equals('status', 'active')
          .lessOrEqual('startDate', now)
          .greaterOrEqual('endDate', DateTime(now.year, now.month, now.day));
      if (branchId != null) {
        activeFilter.relation('branch', branchId);
      }

      final sevenDays = now.add(const Duration(days: 7));
      final expiringFilter = PBFilter()
          .equals('status', 'active')
          .greaterOrEqual('endDate', DateTime(now.year, now.month, now.day))
          .lessOrEqual(
            'endDate',
            DateTime(
              sevenDays.year,
              sevenDays.month,
              sevenDays.day,
              23,
              59,
              59,
            ),
          );
      if (branchId != null) {
        expiringFilter.relation('branch', branchId);
      }

      final endedInPeriodFilter = PBFilter()
          .between('endDate', startDate, endDate)
          .raw(
            "(status = 'expired' || status = 'cancelled' || status = 'active')",
          );
      if (branchId != null) {
        endedInPeriodFilter.relation('branch', branchId);
      }

      final results = await Future.wait([
        _members.getFullList(
          filter: PBFilter().between('created', startDate, endDate).build(),
          sort: 'created',
        ),
        _memberMemberships.getFullList(
          filter: mmPeriodFilter.build(),
          expand: 'member,membership',
          sort: 'created',
        ),
        _memberMemberships.getFullList(filter: activeFilter.build()),
        _memberMemberships.getFullList(filter: expiringFilter.build()),
        _memberMemberships.getFullList(
          filter: endedInPeriodFilter.build(),
          fields: 'id,member,endDate,created',
        ),
        _saleItems.getFullList(
          filter: () {
            final f = PBFilter()
                .between('sale.created', startDate, endDate)
                .raw("(itemType = 'membership' || itemType = 'addon')")
                .raw("(sale.status = 'completed' || sale.status = 'paid')");
            if (branchId != null) {
              f.raw('sale.branch = "$branchId"');
            }
            return f.build();
          }(),
          expand: 'sale',
        ),
      ]);

      final memberRecords = results[0];
      final periodMemberMemberships = results[1];
      final activeMemberMemberships = results[2];
      final expiringRecords = results[3];
      final endedRecords = results[4];
      final membershipSaleItems = results[5];

      final periodMmIds = periodMemberMemberships
          .map((r) => r.id)
          .toList(growable: false);
      final addOnRecords = await _fetchAddOnsForMemberships(periodMmIds);

      final memberIds = periodMemberMemberships
          .map((r) => r.getStringValue('member'))
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();
      final priorByMember = await _fetchPriorMembershipDates(memberIds);

      final createdTimes = <DateTime>[];
      for (final member in memberRecords) {
        final created = DateTime.tryParse(
          member.getStringValue('created'),
        )?.toLocal();
        if (created != null) createdTimes.add(created);
      }
      final registrationsTrend = zeroFillBuckets(
        values: bucketTimestamps(createdTimes, grain),
        rangeStart: period.startDate,
        rangeEnd: period.chartEndDate,
        grain: grain,
      );

      return _aggregateMembershipReport(
        memberRecords: memberRecords,
        periodMemberMemberships: periodMemberMemberships,
        activeMemberMemberships: activeMemberMemberships,
        addOns: addOnRecords,
        membershipSaleItems: membershipSaleItems,
        expiringSoonCount: expiringRecords.length,
        endedRecords: endedRecords,
        priorByMember: priorByMember,
        registrationsTrend: registrationsTrend,
      );
    }, Failure.handle).run();
  }

  Future<List<RecordModel>> _fetchAddOnsForMemberships(
    List<String> membershipIds,
  ) async {
    if (membershipIds.isEmpty) return const [];
    final filters = buildIdOrFilters('memberMembership', membershipIds);
    final chunks = await Future.wait(
      filters.map((f) => _memberMembershipAddOns.getFullList(filter: f)),
    );
    return chunks.expand((e) => e).toList();
  }

  Future<Map<String, List<DateTime>>> _fetchPriorMembershipDates(
    List<String> memberIds,
  ) async {
    if (memberIds.isEmpty) return {};
    final filters = buildIdOrFilters('member', memberIds);
    final chunks = await Future.wait(
      filters.map(
        (f) => _memberMemberships.getFullList(
          filter: '($f) && status != "voided"',
          fields: 'id,member,created',
        ),
      ),
    );
    final map = <String, List<DateTime>>{};
    for (final record in chunks.expand((e) => e)) {
      final memberId = record.getStringValue('member');
      final created = DateTime.tryParse(
        record.getStringValue('created'),
      )?.toLocal();
      if (memberId.isEmpty || created == null) continue;
      map.putIfAbsent(memberId, () => []).add(created);
    }
    return map;
  }

  MembershipReport _aggregateMembershipReport({
    required List<RecordModel> memberRecords,
    required List<RecordModel> periodMemberMemberships,
    required List<RecordModel> activeMemberMemberships,
    required List<RecordModel> addOns,
    required List<RecordModel> membershipSaleItems,
    required int expiringSoonCount,
    required List<RecordModel> endedRecords,
    required Map<String, List<DateTime>> priorByMember,
    required List<PeriodBucket> registrationsTrend,
  }) {
    final planDistribution = <String, num>{};
    final revenueByPlan = <String, num>{};
    var expiredCancelledCount = 0;

    final periodForClassify =
        <({String id, String memberId, DateTime created})>[];

    for (final record in periodMemberMemberships) {
      final status = record.getStringValue('status');
      final membershipExpand = record.get<RecordModel?>('expand.membership');
      final planMemberNotRequired =
          membershipExpand?.getBoolValue('memberNotRequired') ?? false;
      // Walk-in / guest plans belong in Sales, not membership lifecycle.
      if (!includeInMembershipReport(
        saleHasLinkedMember: true,
        planMemberNotRequired: planMemberNotRequired,
      )) {
        continue;
      }

      final planName = membershipExpand?.getStringValue('name') ?? 'Unknown';
      final planPrice = membershipExpand?.getDoubleValue('price') ?? 0;

      planDistribution[planName] = (planDistribution[planName] ?? 0) + 1;
      revenueByPlan[planName] = (revenueByPlan[planName] ?? 0) + planPrice;

      if (status == 'expired' || status == 'cancelled') {
        expiredCancelledCount++;
      }

      final memberId = record.getStringValue('member');
      final created = DateTime.tryParse(
        record.getStringValue('created'),
      )?.toLocal();
      if (memberId.isNotEmpty && created != null) {
        periodForClassify.add((
          id: record.id,
          memberId: memberId,
          created: created,
        ));
      }
    }

    final saleRevenue = sumMembershipReportSaleRevenue(
      membershipSaleItems.map((item) {
        final saleExpand = item.get<RecordModel?>('expand.sale');
        final memberId = saleExpand?.getStringValue('member') ?? '';
        return (
          itemType: item.getStringValue('itemType'),
          subtotal: item.getDoubleValue('subtotal'),
          hasLinkedMember: memberId.isNotEmpty,
        );
      }),
    );
    var membershipRevenue = saleRevenue.membershipRevenue;
    var addOnRevenue = saleRevenue.addOnRevenue;

    if (membershipRevenue == 0 && addOnRevenue == 0) {
      for (final record in periodMemberMemberships) {
        final membershipExpand = record.get<RecordModel?>('expand.membership');
        final planMemberNotRequired =
            membershipExpand?.getBoolValue('memberNotRequired') ?? false;
        if (planMemberNotRequired) continue;
        membershipRevenue += membershipExpand?.getDoubleValue('price') ?? 0;
      }
      for (final addOn in addOns) {
        addOnRevenue += addOn.getDoubleValue('price');
      }
    }

    final classified = classifyNewVsRenewals(periodForClassify, priorByMember);

    final laterStarts = <String, List<DateTime>>{};
    for (final entry in priorByMember.entries) {
      laterStarts[entry.key] = entry.value;
    }
    for (final mm in periodMemberMemberships) {
      final memberId = mm.getStringValue('member');
      final start = DateTime.tryParse(
        mm.getStringValue('startDate'),
      )?.toLocal();
      if (memberId.isEmpty || start == null) continue;
      laterStarts.putIfAbsent(memberId, () => []).add(start);
    }

    final endedForLapse = endedRecords
        .map((r) {
          final memberId = r.getStringValue('member');
          final end = DateTime.tryParse(r.getStringValue('endDate'))?.toLocal();
          if (memberId.isEmpty || end == null) return null;
          return (memberId: memberId, endDate: end);
        })
        .whereType<({String memberId, DateTime endDate})>()
        .toList();

    final lapsedCount = countLapsedMemberships(
      endedInPeriod: endedForLapse,
      laterStartsByMember: laterStarts,
    );

    return MembershipReport(
      totalNewMembers: memberRecords.length,
      activeMemberships: activeMemberMemberships.length,
      expiredCancelledMemberships: expiredCancelledCount,
      membershipRevenue: membershipRevenue,
      addOnRevenue: addOnRevenue,
      registrationsTrend: registrationsTrend,
      membershipPlanDistribution: planDistribution,
      revenueByPlan: revenueByPlan,
      newSubscriptions: classified.newSubscriptions,
      renewals: classified.renewals,
      expiringSoonCount: expiringSoonCount,
      lapsedCount: lapsedCount,
    );
  }

  @override
  FutureEither<AttendanceReport> getAttendanceReport({
    required ReportPeriodSelection period,
    String? branchId,
  }) async {
    return TaskEither.tryCatch(() async {
      // Day: single raw checkIns range query (avoids all-history daily view).
      if (period.period == ReportPeriod.day) {
        return _attendanceFromRawCheckIns(period: period, branchId: branchId);
      }

      final grain = period.trendGranularity;
      final view = checkinsViewFor(period.period);
      final filter = _viewFilter(
        period,
        dateField: view.dateField,
        asMonth: view.asMonth,
        asYear: view.asYear,
        branchId: branchId,
      );

      final records = await _pb
          .collection(view.collection)
          .getFullList(filter: filter);

      if (records.isEmpty) {
        return AttendanceReport.empty;
      }

      var totalCheckIns = 0;
      final byMethod = <String, num>{};
      final byBucket = <DateTime, num>{};
      // unique_members from views are per-row; sum is an upper bound when
      // methods split. Prefer sum of checkin_count for totals.
      final uniqueEstimate = <int>[];

      for (final record in records) {
        final count = record.getIntValue('checkin_count');
        totalCheckIns += count;
        uniqueEstimate.add(record.getIntValue('unique_members'));

        final method = record.getStringValue('method');
        final methodLabel = method.isEmpty ? 'unknown' : method;
        byMethod[methodLabel] = (byMethod[methodLabel] ?? 0) + count;

        final dateStr = record.getStringValue(view.dateField);
        final bucket = parseBucketStart(dateStr, grain);
        if (bucket != null) {
          byBucket[bucket] = (byBucket[bucket] ?? 0) + count;
        }
      }

      final checkInsTrend = zeroFillBuckets(
        values: byBucket,
        rangeStart: period.startDate,
        rangeEnd: period.chartEndDate,
        grain: grain,
      );

      final uniqueMembers = uniqueEstimate.fold<int>(0, (a, b) => a + b);

      if (totalCheckIns == 0) {
        return AttendanceReport.empty;
      }

      return AttendanceReport(
        totalCheckIns: totalCheckIns,
        uniqueMembers: uniqueMembers,
        checkInsTrend: checkInsTrend,
        checkInsByMethod: byMethod,
        checkInsByHour: const {},
        withoutActiveMembershipCount: 0,
      );
    }, Failure.handle).run();
  }

  Future<AttendanceReport> _attendanceFromRawCheckIns({
    required ReportPeriodSelection period,
    String? branchId,
  }) async {
    final dayFilter = PBFilter().between(
      'checkInTime',
      period.startDate,
      period.endDate,
    );
    if (branchId != null) {
      dayFilter.relation('branch', branchId);
    }

    final raw = await _checkIns.getFullList(
      filter: dayFilter.build(),
      fields: 'id,member,memberMembership,method,checkInTime,branch',
    );

    if (raw.isEmpty) {
      return AttendanceReport.empty;
    }

    final times = <DateTime>[];
    final memberIds = <String>{};
    final byMethod = <String, num>{};
    var withoutMembership = 0;

    for (final record in raw) {
      final time = DateTime.tryParse(
        record.getStringValue('checkInTime'),
      )?.toLocal();
      if (time != null) times.add(time);

      final memberId = record.getStringValue('member');
      if (memberId.isNotEmpty) memberIds.add(memberId);

      if (record.getStringValue('memberMembership').isEmpty) {
        withoutMembership++;
      }

      final method = record.getStringValue('method');
      final methodLabel = method.isEmpty ? 'unknown' : method;
      byMethod[methodLabel] = (byMethod[methodLabel] ?? 0) + 1;
    }

    final byBucket = <DateTime, num>{};
    for (final time in times) {
      final bucket = startOfDay(time);
      byBucket[bucket] = (byBucket[bucket] ?? 0) + 1;
    }

    return AttendanceReport(
      totalCheckIns: raw.length,
      uniqueMembers: memberIds.length,
      checkInsTrend: zeroFillBuckets(
        values: byBucket,
        rangeStart: period.startDate,
        rangeEnd: period.chartEndDate,
        grain: TrendGranularity.day,
      ),
      checkInsByMethod: byMethod,
      checkInsByHour: aggregateCheckInsByHour(times),
      withoutActiveMembershipCount: withoutMembership,
    );
  }

  /// Reads `transaction_count` from a revenue-by-item-type view row.
  ///
  /// Prefers int, then falls back to double (SQLite/JSON may surface either).
  static int _transactionCountFromViewRecord(RecordModel record) {
    final asInt = record.getIntValue('transaction_count');
    if (asInt != 0) return asInt;
    return record.getDoubleValue('transaction_count').round();
  }
}
