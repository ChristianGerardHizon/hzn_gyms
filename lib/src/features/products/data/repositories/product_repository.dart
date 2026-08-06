import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/product.dart';
import '../dto/product_dto.dart';

part 'product_repository.g.dart';

/// Repository interface for product operations.
abstract class ProductRepository {
  /// Fetches all products.
  FutureEither<List<Product>> fetchAll({String? filter, String? sort});

  /// Fetches products with pagination.
  FutureEitherPaginated<Product> fetchPaginated({
    int page = 1,
    int perPage = Pagination.defaultPageSize,
    String? filter,
    String? sort,
  });

  /// Fetches a single product by ID.
  FutureEither<Product> fetchOne(String id);

  /// Creates a new product.
  FutureEither<Product> create(Product product);

  /// Updates an existing product.
  FutureEither<Product> update(Product product);

  /// Soft deletes a product (sets isDeleted = true).
  FutureEither<void> delete(String id);

  /// Searches products by the specified fields.
  FutureEither<List<Product>> search(String query, {List<String>? fields});

  /// Searches products with pagination.
  FutureEitherPaginated<Product> searchPaginated(
    String query, {
    List<String>? fields,
    int page = 1,
    int perPage = Pagination.defaultPageSize,
    String? sort,
    String? filter,
  });

  /// Updates a product's image.
  FutureEither<Product> updateImage(String id, http.MultipartFile file);

  /// Invalidates the product list cache.
  void invalidateCache();

  /// Updates only the quantity field for a product.
  /// Used for syncing product quantity from lots.
  FutureEither<Product> updateQuantity(String productId, num quantity);

  /// Decrements a product's quantity by [amount], clamped at 0.
  /// Used for non-lot stock-tracked products sold via POS.
  FutureEither<Product> decrementQuantity(String productId, num amount);

  /// Increments a product's quantity by [amount].
  /// Used when voiding sales of non-lot stock-tracked products.
  FutureEither<Product> incrementQuantity(String productId, num amount);
}

/// Provides the ProductRepository instance.
@Riverpod(keepAlive: true)
ProductRepository productRepository(Ref ref) {
  return ProductRepositoryImpl(ref.watch(pocketbaseProvider));
}

/// Implementation of [ProductRepository] using PocketBase.
class ProductRepositoryImpl implements ProductRepository {
  final PocketBase _pb;

  ProductRepositoryImpl(this._pb);

  RecordService get _collection =>
      _pb.collection(PocketBaseCollections.products);
  String get _expand => 'category,quantityUnit';

  // Cache for product list
  List<Product>? _cachedProducts;
  DateTime? _cacheTimestamp;
  String? _cachedFilter;
  String? _cachedSort;

  // Cache TTL (5 minutes)
  static const _cacheTtl = Duration(minutes: 5);

  /// Checks if the cache is valid.
  bool _isCacheValid(String? filter, String? sort) {
    if (_cachedProducts == null || _cacheTimestamp == null) return false;
    if (_cachedFilter != filter || _cachedSort != sort) return false;
    return DateTime.now().difference(_cacheTimestamp!) < _cacheTtl;
  }

  /// Invalidates the cache.
  @override
  void invalidateCache() {
    _cachedProducts = null;
    _cacheTimestamp = null;
    _cachedFilter = null;
    _cachedSort = null;
  }

  Product _toEntity(RecordModel record) {
    final dto = ProductDto.fromRecord(record);
    return dto.toEntity(baseUrl: _pb.baseURL);
  }

  @override
  FutureEither<List<Product>> fetchAll({String? filter, String? sort}) async {
    // Return cached data if valid
    if (_isCacheValid(filter, sort)) {
      return Right(_cachedProducts!);
    }

    return TaskEither.tryCatch(
      () async {
        final baseFilter = PBFilters.active.build();
        final filterString =
            filter != null ? '$baseFilter && $filter' : baseFilter;

        final records = await _collection.getFullList(
          expand: _expand,
          filter: filterString,
          sort: sort ?? '-created',
        );

        final products = records.map(_toEntity).toList();

        // Update cache
        _cachedProducts = products;
        _cacheTimestamp = DateTime.now();
        _cachedFilter = filter;
        _cachedSort = sort;

        return products;
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEitherPaginated<Product> fetchPaginated({
    int page = 1,
    int perPage = Pagination.defaultPageSize,
    String? filter,
    String? sort,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final baseFilter = PBFilters.active.build();
        final filterString =
            filter != null ? '$baseFilter && $filter' : baseFilter;

        final result = await _collection.getList(
          page: page,
          perPage: perPage,
          expand: _expand,
          filter: filterString,
          sort: sort ?? '-created',
        );

        return PaginatedResult<Product>(
          items: result.items.map(_toEntity).toList(),
          page: result.page,
          totalItems: result.totalItems,
          totalPages: result.totalPages,
        );
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Product> fetchOne(String id) async {
    return TaskEither.tryCatch(
      () async {
        if (id.isEmpty) {
          throw const DataFailure(
            'Product ID cannot be empty',
            null,
            'invalid_product_id',
          );
        }

        final record = await _collection.getOne(id, expand: _expand);
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Product> create(Product product) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'name': product.name,
          'description': product.description,
          'category': product.categoryId,
          'branch': product.branch,
          'stockThreshold': product.stockThreshold,
          'price': product.price,
          'forSale': product.forSale,
          'trackStock': product.trackStock,
          'requireStock': product.requireStock,
          'quantity': product.quantity,
          'expiration': product.expiration.toUtcIso8601OrNull(),
          'trackByLot': product.trackByLot,
          'quantityUnit': product.quantityUnitId,
          'isDeleted': false,
        };

        final record = await _collection.create(body: body, expand: _expand);
        invalidateCache(); // Invalidate cache on create
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Product> update(Product product) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'name': product.name,
          'description': product.description,
          'category': product.categoryId,
          'branch': product.branch,
          'stockThreshold': product.stockThreshold,
          'price': product.price,
          'forSale': product.forSale,
          'trackStock': product.trackStock,
          'requireStock': product.requireStock,
          'quantity': product.quantity,
          'expiration': product.expiration.toUtcIso8601OrNull(),
          'trackByLot': product.trackByLot,
          'quantityUnit': product.quantityUnitId,
        };

        final record =
            await _collection.update(product.id, body: body, expand: _expand);
        invalidateCache(); // Invalidate cache on update
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<void> delete(String id) async {
    return TaskEither.tryCatch(
      () async {
        await _collection.update(id, body: {'isDeleted': true});
        invalidateCache(); // Invalidate cache on delete
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<Product>> search(
    String query, {
    List<String>? fields,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final searchFields = fields ?? ['name'];
        final filter = PBFilter()
            .notDeleted()
            .searchFields(query, searchFields)
            .build();

        final records = await _collection.getFullList(
          expand: _expand,
          filter: filter,
          sort: 'name',
        );

        return records.map(_toEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEitherPaginated<Product> searchPaginated(
    String query, {
    List<String>? fields,
    int page = 1,
    int perPage = Pagination.defaultPageSize,
    String? sort,
    String? filter,
  }) async {
    return TaskEither.tryCatch(
      () async {
        final searchFields = fields ?? ['name'];
        final searchFilter = PBFilter()
            .notDeleted()
            .searchFields(query, searchFields)
            .build();

        // Combine search filter with optional branch filter
        final combinedFilter =
            filter != null ? '$searchFilter && $filter' : searchFilter;

        final result = await _collection.getList(
          page: page,
          perPage: perPage,
          expand: _expand,
          filter: combinedFilter,
          sort: sort ?? 'name',
        );

        return PaginatedResult<Product>(
          items: result.items.map(_toEntity).toList(),
          page: result.page,
          totalItems: result.totalItems,
          totalPages: result.totalPages,
        );
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Product> updateImage(String id, http.MultipartFile file) async {
    return TaskEither.tryCatch(
      () async {
        final record = await _collection.update(
          id,
          files: [file],
          expand: _expand,
        );
        invalidateCache();
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Product> updateQuantity(String productId, num quantity) async {
    return TaskEither.tryCatch(
      () async {
        final record = await _collection.update(
          productId,
          body: {'quantity': quantity},
          expand: _expand,
        );
        invalidateCache();
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Product> decrementQuantity(String productId, num amount) async {
    return TaskEither.tryCatch(
      () async {
        final current = _toEntity(await _collection.getOne(productId));
        final currentQty = current.quantity ?? 0;
        final newQuantity = (currentQty - amount).clamp(0, double.infinity);
        final record = await _collection.update(
          productId,
          body: {'quantity': newQuantity},
          expand: _expand,
        );
        invalidateCache();
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Product> incrementQuantity(String productId, num amount) async {
    return TaskEither.tryCatch(
      () async {
        final current = _toEntity(await _collection.getOne(productId));
        final currentQty = current.quantity ?? 0;
        final newQuantity = currentQty + amount;
        final record = await _collection.update(
          productId,
          body: {'quantity': newQuantity},
          expand: _expand,
        );
        invalidateCache();
        return _toEntity(record);
      },
      Failure.handle,
    ).run();
  }
}
