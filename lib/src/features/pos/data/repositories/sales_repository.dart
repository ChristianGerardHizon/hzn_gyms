import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/sale.dart';
import '../../domain/sale_item.dart';
import '../dto/sale_dto.dart';
import '../dto/sale_item_dto.dart';

part 'sales_repository.g.dart';

abstract class SalesRepository {
  FutureEither<Sale> createSale(
    Sale sale,
    List<SaleItem> items,
  );
  FutureEither<Sale> getSale(String id);
  FutureEither<List<Sale>> getSales({
    String? branchId,
    DateTime? date,
    int? limit,
    List<String>? statuses,
  });
  FutureEither<List<SaleItem>> getSaleItems(String saleId);

  /// Updates a sale record.
  FutureEither<Sale> updateSale(String id, Map<String, dynamic> data);

  /// Updates the sale status (completed, refunded, voided).
  FutureEither<Sale> updateSaleStatus(String id, String status);

  /// Fetches all sales for a specific customer.
  FutureEither<List<Sale>> getSalesByCustomer(String customerId);

  /// Fetches sales with pagination.
  FutureEitherPaginated<Sale> fetchPaginated({
    int page = 1,
    int perPage = Pagination.defaultPageSize,
    String? filter,
    String? sort,
  });

  /// Searches sales with pagination.
  FutureEitherPaginated<Sale> searchPaginated(
    String query, {
    List<String>? fields,
    int page = 1,
    int perPage = Pagination.defaultPageSize,
    String? sort,
    String? filter,
  });
}

@Riverpod(keepAlive: true)
SalesRepository salesRepository(Ref ref) {
  return SalesRepositoryImpl(ref.watch(pocketbaseProvider));
}

class SalesRepositoryImpl implements SalesRepository {
  final PocketBase _pb;

  SalesRepositoryImpl(this._pb);

  /// Columns needed for list / history rows (avoids shipping notes, etc.).
  static const _listFields =
      'id,receiptNumber,branch,cashier,totalAmount,status,isPaid,member,customerName,descriptor,created,updated';

  RecordService get _sales => _pb.collection(PocketBaseCollections.sales);
  RecordService get _saleItems =>
      _pb.collection(PocketBaseCollections.saleItems);

  Sale _toSaleEntity(RecordModel record) {
    return SaleDto.fromRecord(record).toEntity();
  }

  SaleItem _toSaleItemEntity(RecordModel record) {
    final productExpanded = record.get<RecordModel?>('expand.product');
    return SaleItemDto.fromRecord(record)
        .toEntity(productExpanded: productExpanded);
  }

  @override
  FutureEither<Sale> createSale(
    Sale sale,
    List<SaleItem> items,
  ) async {
    return TaskEither.tryCatch(
      () async {
        final memberId = sale.customerId?.trim();
        final customerName = Sale.resolveCustomerName(
          customerId: sale.customerId,
          customerName: sale.customerName,
        );
        final descriptor = () {
          final existing = sale.descriptor?.trim();
          if (existing != null && existing.isNotEmpty) return existing;
          return Sale.buildDescriptor(
            items: items,
            customerName: customerName,
            isWalkIn: sale.isWalkIn,
          );
        }();
        final saleBody = <String, dynamic>{
          'receiptNumber': sale.receiptNumber,
          'branch': sale.branchId,
          'cashier': sale.cashierId,
          'totalAmount': sale.totalAmount,
          'status': sale.status,
          'isPaid': sale.isPaid,
          if (memberId != null && memberId.isNotEmpty) 'member': memberId,
          if (customerName != null) 'customerName': customerName,
          'descriptor': descriptor,
          'notes': sale.notes,
        };
        final saleRecord = await _sales.create(body: saleBody);

        // 2. Create Sale Items (products)
        for (final item in items) {
          final itemBody = <String, dynamic>{
            'sale': saleRecord.id,
            'productName': item.productName,
            'quantity': item.quantity,
            'unitPrice': item.unitPrice,
            'subtotal': item.subtotal,
          };
          if (item.productId.isNotEmpty) {
            itemBody['product'] = item.productId;
          }
          if (item.productLotId != null && item.productLotId!.isNotEmpty) {
            itemBody['productLot'] = item.productLotId;
            itemBody['lotNumber'] = item.lotNumber;
          }
          if (item.itemType != null && item.itemType!.isNotEmpty) {
            itemBody['itemType'] = item.itemType;
          }
          await _saleItems.create(body: itemBody);
        }

        final createdSale = _toSaleEntity(saleRecord);

        return createdSale;
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Sale> getSale(String id) async {
    return TaskEither.tryCatch(
      () async {
        final record = await _sales.getOne(id);
        return _toSaleEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Sale> updateSale(String id, Map<String, dynamic> data) async {
    return TaskEither.tryCatch(
      () async {
        final record = await _sales.update(id, body: data);
        return _toSaleEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Sale> updateSaleStatus(String id, String status) async {
    return TaskEither.tryCatch(
      () async {
        final record = await _sales.update(id, body: {'status': status});
        return _toSaleEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<Sale>> getSales({
    String? branchId,
    DateTime? date,
    int? limit,
    List<String>? statuses,
  }) async {
    return TaskEither.tryCatch(
      () async {
        var filter = '';
        if (branchId != null) {
          filter = 'branch = "$branchId"';
        }

        if (date != null) {
          // Get start and end of day in local time, then convert to UTC for filter
          final localStart = DateTime(date.year, date.month, date.day);
          final localEnd = localStart.add(const Duration(days: 1));
          final dateFilter =
              'created >= "${localStart.toPocketBaseUtc()}" && created < "${localEnd.toPocketBaseUtc()}"';

          if (filter.isNotEmpty) {
            filter = '$filter && $dateFilter';
          } else {
            filter = dateFilter;
          }
        }

        if (statuses != null && statuses.isNotEmpty) {
          final statusFilter = statuses.length == 1
              ? 'status = "${statuses.first}"'
              : '(${statuses.map((s) => 'status = "$s"').join(' || ')})';
          filter = filter.isEmpty ? statusFilter : '$filter && $statusFilter';
        }

        final filterOrNull = filter.isEmpty ? null : filter;

        if (limit != null) {
          final page = await _sales.getList(
            page: 1,
            perPage: limit,
            filter: filterOrNull,
            sort: '-created',
            fields: _listFields,
          );
          return page.items.map(_toSaleEntity).toList();
        }

        final records = await _sales.getFullList(
          filter: filterOrNull,
          sort: '-created',
          fields: _listFields,
        );
        return records.map(_toSaleEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<SaleItem>> getSaleItems(String saleId) async {
    return TaskEither.tryCatch(
      () async {
        final records = await _saleItems.getFullList(
          filter: 'sale = "$saleId"',
          expand: 'product',
        );
        return records.map(_toSaleItemEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEitherPaginated<Sale> fetchPaginated({
    int page = 1,
    int perPage = Pagination.defaultPageSize,
    String? filter,
    String? sort,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final result = await _sales.getList(
          page: page,
          perPage: perPage,
          filter: filter,
          sort: sort ?? '-created',
          fields: _listFields,
        );

        return PaginatedResult<Sale>(
          items: result.items.map(_toSaleEntity).toList(),
          page: result.page,
          totalItems: result.totalItems,
          totalPages: result.totalPages,
        );
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEitherPaginated<Sale> searchPaginated(
    String query, {
    List<String>? fields,
    int page = 1,
    int perPage = Pagination.defaultPageSize,
    String? sort,
    String? filter,
  }) async {
    return TaskEither.tryCatch(
      () async {
        // Use PBFilter for multi-field OR search
        final searchFields = fields ?? ['receiptNumber'];
        final searchFilter = _buildSaleSearchFilter(query, searchFields);

        // Combine search filter with optional branch filter
        final combinedFilter =
            filter != null ? '$searchFilter && $filter' : searchFilter;

        final result = await _sales.getList(
          page: page,
          perPage: perPage,
          filter: combinedFilter,
          sort: sort ?? '-created',
          fields: _listFields,
        );

        return PaginatedResult<Sale>(
          items: result.items.map(_toSaleEntity).toList(),
          page: result.page,
          totalItems: result.totalItems,
          totalPages: result.totalPages,
        );
      },
      Failure.handle,
    ).run();
  }

  /// Builds a PocketBase filter for sales search.
  ///
  /// Queries that match "walk-in" / "walkin" also include sales with no
  /// linked member, since older walk-in rows may not store the label.
  static String _buildSaleSearchFilter(String query, List<String> fields) {
    final normalized =
        query.trim().toLowerCase().replaceAll(RegExp(r'[\s\-_]'), '');
    if (normalized == 'walkin') {
      final label = Sale.walkInLabel;
      return '('
          'customerName ~ "$label" || '
          'descriptor ~ "$label" || '
          'member = "" || '
          'member = null'
          ')';
    }
    return PBFilter().searchFields(query, fields).buildOrEmpty();
  }

  @override
  FutureEither<List<Sale>> getSalesByCustomer(String customerId) async {
    return TaskEither.tryCatch(
      () async {
        final records = await _sales.getFullList(
          filter: 'member = "$customerId"',
          sort: '-created',
          fields: _listFields,
        );
        return records.map(_toSaleEntity).toList();
      },
      Failure.handle,
    ).run();
  }
}
