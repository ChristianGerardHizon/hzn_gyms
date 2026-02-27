import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/inventory_report.dart';
import '../../domain/membership_report.dart';
import '../../domain/sales_report.dart';

part 'reports_repository.g.dart';

/// Helper extension for date filtering on view records.
extension _DateFilter on DateTime {
  /// Returns true if this date is within [start, end) range.
  bool isInRange(DateTime start, DateTime end) {
    return !isBefore(start) && isBefore(end);
  }
}

/// Repository for fetching and aggregating report data.
abstract class ReportsRepository {
  FutureEither<SalesReport> getSalesReport({
    required DateTime startDate,
    required DateTime endDate,
    String? branchId,
  });

  FutureEither<InventoryReport> getInventoryReport({String? branchId});

  FutureEither<MembershipReport> getMembershipReport({
    required DateTime startDate,
    required DateTime endDate,
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

  RecordService get _products => _pb.collection(PocketBaseCollections.products);
  RecordService get _members => _pb.collection(PocketBaseCollections.members);
  RecordService get _memberMemberships =>
      _pb.collection(PocketBaseCollections.memberMemberships);
  RecordService get _memberMembershipAddOns =>
      _pb.collection(PocketBaseCollections.memberMembershipAddOns);

  /// Returns a PocketBase filter for branch on view collections.
  static String? _branchViewFilter(String? branchId) {
    if (branchId == null) return null;
    return 'branch = "$branchId"';
  }

  @override
  FutureEither<SalesReport> getSalesReport({
    required DateTime startDate,
    required DateTime endDate,
    String? branchId,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final branchFilter = _branchViewFilter(branchId);

        // Query views in parallel for best performance
        final results = await Future.wait([
          _pb.collection(PocketBaseCollections.vwSalesDailySummary).getFullList(filter: branchFilter),
          _pb.collection(PocketBaseCollections.vwTopSellingProducts).getFullList(filter: branchFilter),
        ]);

        final dailySummaryRecords = results[0];
        final topProductsRecords = results[1];

        // Filter records by date range
        final filteredSummary = dailySummaryRecords.where((r) {
          final dateStr = r.getStringValue('sale_date');
          final date = DateTime.tryParse(dateStr)?.toLocal();
          return date != null && date.isInRange(startDate, endDate);
        }).toList();

        if (filteredSummary.isEmpty) {
          return SalesReport.empty;
        }

        // Calculate totals from daily summary
        num totalRevenue = 0;
        int transactionCount = 0;
        final revenueByDay = <DateTime, num>{};
        final revenueByPaymentMethod = <String, num>{};

        for (final record in filteredSummary) {
          final dateStr = record.getStringValue('sale_date');
          final date = DateTime.tryParse(dateStr)?.toLocal();
          final revenue = record.getDoubleValue('total_revenue');
          final count = record.getIntValue('transaction_count');
          final paymentMethod = record.getStringValue('paymentMethod');

          totalRevenue += revenue;
          transactionCount += count;

          if (date != null) {
            final day = DateTime(date.year, date.month, date.day);
            revenueByDay[day] = (revenueByDay[day] ?? 0) + revenue;
          }

          if (paymentMethod.isNotEmpty) {
            revenueByPaymentMethod[paymentMethod] =
                (revenueByPaymentMethod[paymentMethod] ?? 0) + revenue;
          }
        }

        final avgValue =
            transactionCount > 0 ? totalRevenue / transactionCount : 0;

        // Filter and aggregate top products by date range
        final filteredProducts = topProductsRecords.where((r) {
          final dateStr = r.getStringValue('sale_date');
          final date = DateTime.tryParse(dateStr)?.toLocal();
          return date != null && date.isInRange(startDate, endDate);
        }).toList();

        final productSales = <String, ({num quantity, num revenue})>{};
        for (final record in filteredProducts) {
          final name = record.getStringValue('productName');
          if (name.isEmpty) continue;
          final qty = record.getDoubleValue('total_quantity_sold');
          final revenue = record.getDoubleValue('total_revenue');
          final existing = productSales[name];
          if (existing != null) {
            productSales[name] = (
              quantity: existing.quantity + qty,
              revenue: existing.revenue + revenue,
            );
          } else {
            productSales[name] = (quantity: qty, revenue: revenue);
          }
        }

        final topProducts = productSales.entries
            .map((e) => ProductSalesSummary(
                  productName: e.key,
                  quantity: e.value.quantity,
                  revenue: e.value.revenue,
                ))
            .toList()
          ..sort((a, b) => b.revenue.compareTo(a.revenue));

        return SalesReport(
          totalRevenue: totalRevenue,
          transactionCount: transactionCount,
          averageTransactionValue: avgValue,
          revenueByDay: revenueByDay.entries
              .map((e) => DailyRevenue(date: e.key, amount: e.value))
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date)),
          revenueByPaymentMethod: revenueByPaymentMethod,
          topSellingProducts: topProducts.take(10).toList(),
        );
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<InventoryReport> getInventoryReport({String? branchId}) async {
    return TaskEither.tryCatch(
      () async {
        final filter = branchId != null
            ? PBFilters.forBranch(branchId).build()
            : null;
        final products = await _products.getFullList(
          expand: 'category',
          filter: filter,
        );

        return _aggregateInventoryReport(products);
      },
      Failure.handle,
    ).run();
  }

  InventoryReport _aggregateInventoryReport(List<RecordModel> products) {
    var inStockCount = 0;
    var lowStockCount = 0;
    var outOfStockCount = 0;
    var expiredCount = 0;
    var nearExpirationCount = 0;
    num totalValue = 0;

    final byCategory = <String, int>{};
    final stockStatus = <String, int>{};
    final lowStockItems = <LowStockItem>[];

    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));

    for (final product in products) {
      final quantity = product.getDoubleValue('quantity');
      final threshold = product.getDoubleValue('stockThreshold');
      final price = product.getDoubleValue('price');
      final expirationStr = product.getStringValue('expiration');
      final expiration =
          expirationStr.isNotEmpty ? DateTime.tryParse(expirationStr) : null;

      // Calculate inventory value
      totalValue += quantity * price;

      // Stock status
      if (quantity <= 0) {
        outOfStockCount++;
        stockStatus['Out of Stock'] = (stockStatus['Out of Stock'] ?? 0) + 1;
      } else if (threshold > 0 && quantity <= threshold) {
        lowStockCount++;
        stockStatus['Low Stock'] = (stockStatus['Low Stock'] ?? 0) + 1;

        // Add to low stock items list
        final categoryExpanded = product.get<RecordModel?>('expand.category');
        lowStockItems.add(LowStockItem(
          productName: product.getStringValue('name'),
          categoryName: categoryExpanded?.getStringValue('name') ?? 'Uncategorized',
          currentStock: quantity,
          threshold: threshold,
          expirationDate: expiration?.toLocal(),
        ));
      } else {
        inStockCount++;
        stockStatus['In Stock'] = (stockStatus['In Stock'] ?? 0) + 1;
      }

      // Expiration check
      if (expiration != null) {
        if (expiration.isBefore(now)) {
          expiredCount++;
        } else if (expiration.isBefore(thirtyDaysFromNow)) {
          nearExpirationCount++;
        }
      }

      // By category
      final categoryExpanded = product.get<RecordModel?>('expand.category');
      final categoryName =
          categoryExpanded?.getStringValue('name') ?? 'Uncategorized';
      byCategory[categoryName] = (byCategory[categoryName] ?? 0) + 1;
    }

    return InventoryReport(
      totalProducts: products.length,
      inStockCount: inStockCount,
      lowStockCount: lowStockCount,
      outOfStockCount: outOfStockCount,
      expiredCount: expiredCount,
      nearExpirationCount: nearExpirationCount,
      totalInventoryValue: totalValue,
      productsByCategory: byCategory,
      stockStatusBreakdown: stockStatus,
      lowStockItems: lowStockItems,
    );
  }

  @override
  FutureEither<MembershipReport> getMembershipReport({
    required DateTime startDate,
    required DateTime endDate,
    String? branchId,
  }) async {
    return TaskEither.tryCatch(
      () async {
        // Build filters
        final branchFilter = branchId != null
            ? PBFilter().relation('branch', branchId)
            : PBFilter();

        final periodFilter = PBFilter().between('created', startDate, endDate);

        // Combined filter for memberMemberships created in period + branch
        final mmPeriodFilter = PBFilter()
            .and(branchFilter)
            .and(periodFilter);

        // Fetch data in parallel
        final results = await Future.wait([
          // [0] Members created in period (no branch filter — members are global)
          _members.getFullList(
            filter: PBFilter().between('created', startDate, endDate).build(),
            sort: 'created',
          ),
          // [1] MemberMemberships created in period (with expand)
          _memberMemberships.getFullList(
            filter: mmPeriodFilter.build(),
            expand: 'member,membership',
            sort: 'created',
          ),
          // [2] All active memberMemberships for branch (for active count)
          _memberMemberships.getFullList(
            filter: (branchId != null
                    ? PBFilter().relation('branch', branchId)
                    : PBFilter())
                .equals('status', 'active')
                .build(),
          ),
          // [3] All memberMembershipAddOns (filter in-memory by parent IDs)
          _memberMembershipAddOns.getFullList(),
        ]);

        final memberRecords = results[0];
        final periodMemberMemberships = results[1];
        final activeMemberMemberships = results[2];
        final allAddOns = results[3];

        return _aggregateMembershipReport(
          memberRecords: memberRecords,
          periodMemberMemberships: periodMemberMemberships,
          activeMemberMemberships: activeMemberMemberships,
          allAddOns: allAddOns,
        );
      },
      Failure.handle,
    ).run();
  }

  MembershipReport _aggregateMembershipReport({
    required List<RecordModel> memberRecords,
    required List<RecordModel> periodMemberMemberships,
    required List<RecordModel> activeMemberMemberships,
    required List<RecordModel> allAddOns,
  }) {
    // --- 1. New member registrations by day ---
    final registrationsByDay = <DateTime, int>{};
    for (final member in memberRecords) {
      final createdStr = member.getStringValue('created');
      final created = DateTime.tryParse(createdStr)?.toLocal();
      if (created != null) {
        final day = DateTime(created.year, created.month, created.day);
        registrationsByDay[day] = (registrationsByDay[day] ?? 0) + 1;
      }
    }

    // --- 2. Period membership stats ---
    num membershipRevenue = 0;
    final planDistribution = <String, num>{};
    final revenueByPlan = <String, num>{};
    var expiredCancelledCount = 0;

    // Collect IDs for add-on filtering
    final periodMmIds = <String>{};

    for (final record in periodMemberMemberships) {
      periodMmIds.add(record.id);

      final status = record.getStringValue('status');
      final membershipExpand = record.get<RecordModel?>('expand.membership');
      final planName = membershipExpand?.getStringValue('name') ?? 'Unknown';
      final planPrice = membershipExpand?.getDoubleValue('price') ?? 0;

      membershipRevenue += planPrice;
      planDistribution[planName] = (planDistribution[planName] ?? 0) + 1;
      revenueByPlan[planName] = (revenueByPlan[planName] ?? 0) + planPrice;

      if (status == 'expired' || status == 'cancelled') {
        expiredCancelledCount++;
      }
    }

    // --- 3. Add-on revenue (filter by parent memberMembership IDs) ---
    num addOnRevenue = 0;
    for (final addOn in allAddOns) {
      final parentId = addOn.getStringValue('memberMembership');
      if (periodMmIds.contains(parentId)) {
        addOnRevenue += addOn.getDoubleValue('price');
      }
    }

    // --- 4. Currently active memberships count ---
    final now = DateTime.now();
    var activeCount = 0;

    for (final record in activeMemberMemberships) {
      final startDateStr = record.getStringValue('startDate');
      final endDateStr = record.getStringValue('endDate');
      final mmStartDate = DateTime.tryParse(startDateStr)?.toLocal();
      final mmEndDate = DateTime.tryParse(endDateStr)?.toLocal();

      if (mmStartDate != null && mmEndDate != null) {
        if (now.isAfter(mmStartDate) && now.isBefore(mmEndDate)) {
          activeCount++;
        }
      }
    }

    return MembershipReport(
      totalNewMembers: memberRecords.length,
      activeMemberships: activeCount,
      expiredCancelledMemberships: expiredCancelledCount,
      membershipRevenue: membershipRevenue,
      addOnRevenue: addOnRevenue,
      registrationsByDay: registrationsByDay.entries
          .map((e) => DailyRegistration(date: e.key, count: e.value))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date)),
      membershipPlanDistribution: planDistribution,
      revenueByPlan: revenueByPlan,
    );
  }
}
