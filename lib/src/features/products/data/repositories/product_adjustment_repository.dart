import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/product_adjustment.dart';
import '../../domain/product_adjustment_type.dart';
import '../dto/product_adjustment_dto.dart';

part 'product_adjustment_repository.g.dart';

/// Repository interface for product adjustment operations.
abstract class ProductAdjustmentRepository {
  /// Fetches all adjustments for a product.
  FutureEither<List<ProductAdjustment>> fetchByProduct(String productId);

  /// Fetches all adjustments for a specific lot.
  FutureEither<List<ProductAdjustment>> fetchByLot(String lotId);

  /// Creates a new adjustment record.
  FutureEither<ProductAdjustment> create({
    required ProductAdjustmentType type,
    required num oldValue,
    required num newValue,
    String? reason,
    String? productId,
    String? productStockId,
    String? productLotId,
    String? saleId,
  });
}

/// Provides the ProductAdjustmentRepository instance.
@Riverpod(keepAlive: true)
ProductAdjustmentRepository productAdjustmentRepository(Ref ref) {
  return ProductAdjustmentRepositoryImpl(ref.watch(pocketbaseProvider));
}

/// Implementation of [ProductAdjustmentRepository] using PocketBase.
class ProductAdjustmentRepositoryImpl implements ProductAdjustmentRepository {
  final PocketBase _pb;

  ProductAdjustmentRepositoryImpl(this._pb);

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.productAdjustments);

  ProductAdjustment _toEntity(RecordModel record) {
    final dto = ProductAdjustmentDto.fromRecord(record);
    return dto.toEntity();
  }

  @override
  FutureEither<List<ProductAdjustment>> fetchByProduct(
      String productId) async {
    return TaskEither.tryCatch(
      () async {
        // Get adjustments directly on the product OR on any of its lots
        final filter = PBFilter()
            .notDeleted()
            .equals('product', productId)
            .build();

        final records = await _collection.getFullList(
          filter: filter,
          sort: '-created',
        );

        return records.map(_toEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<ProductAdjustment>> fetchByLot(String lotId) async {
    return TaskEither.tryCatch(
      () async {
        final filter = PBFilter()
            .notDeleted()
            .equals('productLot', lotId)
            .build();

        final records = await _collection.getFullList(
          filter: filter,
          sort: '-created',
        );

        return records.map(_toEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<ProductAdjustment> create({
    required ProductAdjustmentType type,
    required num oldValue,
    required num newValue,
    String? reason,
    String? productId,
    String? productStockId,
    String? productLotId,
    String? saleId,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final body = ProductAdjustmentDto.toCreateBody(
          type: type,
          oldValue: oldValue,
          newValue: newValue,
          reason: reason,
          productId: productId,
          productStockId: productStockId,
          productLotId: productLotId,
          saleId: saleId,
        );

        final record = await _collection.create(body: body);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }
}
