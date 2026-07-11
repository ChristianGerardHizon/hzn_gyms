import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/foundation/paginated_state.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../data/repositories/product_lot_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../domain/product.dart';
import 'product_sort_controller.dart';

part 'paginated_products_controller.g.dart';

/// Controller for managing paginated products list.
@Riverpod(keepAlive: true)
class PaginatedProductsController extends _$PaginatedProductsController {
  ProductRepository get _repository => ref.read(productRepositoryProvider);
  ProductLotRepository get _lotRepository =>
      ref.read(productLotRepositoryProvider);

  // Track current search state
  String? _currentSearchQuery;
  List<String>? _currentSearchFields;

  /// Gets the current sort string from the sort controller.
  String get _currentSort =>
      ref.read(productSortControllerProvider).toSortString();

  /// Gets the current branch filter.
  String? get _branchFilter => ref.read(currentBranchFilterProvider);

  @override
  Future<PaginatedState<Product>> build() async {
    _currentSearchQuery = null;
    _currentSearchFields = null;

    // Listen to sort changes and refresh
    ref.listen(productSortControllerProvider, (_, __) {
      refresh();
    });

    // Listen to branch changes and refresh
    ref.listen(currentBranchFilterProvider, (_, __) {
      refresh();
    });

    final result = await _repository.fetchPaginated(
      page: 1,
      perPage: Pagination.defaultPageSize,
      sort: _currentSort,
      filter: _branchFilter,
    );

    final paginated = result.fold(
      (failure) => throw failure,
      (paginated) => paginated,
    );

    // Sync lot-tracked products' quantities
    final syncedItems = await _syncLotTrackedProducts(paginated.items);
    return PaginatedState<Product>(
      items: syncedItems,
      currentPage: paginated.page,
      totalItems: paginated.totalItems,
      totalPages: paginated.totalPages,
      hasReachedEnd: !paginated.hasMore,
    );
  }

  /// Syncs quantity for lot-tracked products from their lots.
  Future<List<Product>> _syncLotTrackedProducts(List<Product> products) async {
    final synced = <Product>[];

    for (final product in products) {
      if (product.trackByLot) {
        final totalResult =
            await _lotRepository.calculateTotalQuantity(product.id);
        final total = totalResult.fold(
          (failure) => null,
          (total) => total,
        );

        if (total != null && product.quantity != total) {
          // Update the product's quantity in the database
          final updateResult =
              await _repository.updateQuantity(product.id, total);
          synced.add(updateResult.fold(
            (failure) => product.copyWith(quantity: total),
            (updated) => updated,
          ));
        } else {
          synced.add(product);
        }
      } else {
        synced.add(product);
      }
    }

    return synced;
  }

  /// Whether search is currently active.
  bool get isSearchActive => _currentSearchQuery != null;

  /// The current search query, if any.
  String? get currentSearchQuery => _currentSearchQuery;

  /// Loads the next page.
  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null ||
        currentState.isLoadingMore ||
        currentState.hasReachedEnd) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;

    // Use search or regular fetch based on current state
    final result = _currentSearchQuery != null
        ? await _repository.searchPaginated(
            _currentSearchQuery!,
            fields: _currentSearchFields,
            page: nextPage,
            perPage: Pagination.defaultPageSize,
            sort: _currentSort,
            filter: _branchFilter,
          )
        : await _repository.fetchPaginated(
            page: nextPage,
            perPage: Pagination.defaultPageSize,
            sort: _currentSort,
            filter: _branchFilter,
          );

    await result.fold(
      (failure) async {
        state = AsyncValue.data(currentState.copyWith(isLoadingMore: false));
      },
      (paginated) async {
        // Sync lot-tracked products' quantities
        final syncedItems = await _syncLotTrackedProducts(paginated.items);
        state = AsyncValue.data(
          currentState.appendItems(
            syncedItems,
            page: paginated.page,
            totalItems: paginated.totalItems,
            totalPages: paginated.totalPages,
          ),
        );
      },
    );
  }

  /// Refreshes the list (respects current search, sort, and branch filter).
  Future<void> refresh() async {
    // Avoid wiping previous data so list UIs (and search inputs) stay mounted.
    if (!state.hasValue) {
      state = const AsyncValue.loading();
    }

    final result = _currentSearchQuery != null
        ? await _repository.searchPaginated(
            _currentSearchQuery!,
            fields: _currentSearchFields,
            page: 1,
            perPage: Pagination.defaultPageSize,
            sort: _currentSort,
            filter: _branchFilter,
          )
        : await _repository.fetchPaginated(
            page: 1,
            perPage: Pagination.defaultPageSize,
            sort: _currentSort,
            filter: _branchFilter,
          );

    await result.fold(
      (failure) async {
        state = AsyncError(failure, StackTrace.current);
      },
      (paginated) async {
        // Sync lot-tracked products' quantities
        final syncedItems = await _syncLotTrackedProducts(paginated.items);
        state = AsyncData(PaginatedState<Product>(
          items: syncedItems,
          currentPage: paginated.page,
          totalItems: paginated.totalItems,
          totalPages: paginated.totalPages,
          hasReachedEnd: !paginated.hasMore,
        ));
      },
    );
  }

  /// Searches products (resets to page 1).
  Future<void> search(String query, {List<String>? fields}) async {
    if (query.isEmpty) {
      return clearSearch();
    }

    _currentSearchQuery = query;
    _currentSearchFields = fields;

    // Keep previous data so the list panel (and search input) stay mounted.
    final result = await _repository.searchPaginated(
      query,
      fields: fields,
      page: 1,
      perPage: Pagination.defaultPageSize,
      sort: _currentSort,
      filter: _branchFilter,
    );

    await result.fold(
      (failure) async {
        state = AsyncError(failure, StackTrace.current);
      },
      (paginated) async {
        // Sync lot-tracked products' quantities
        final syncedItems = await _syncLotTrackedProducts(paginated.items);
        state = AsyncData(PaginatedState<Product>(
          items: syncedItems,
          currentPage: paginated.page,
          totalItems: paginated.totalItems,
          totalPages: paginated.totalPages,
          hasReachedEnd: !paginated.hasMore,
        ));
      },
    );
  }

  /// Clears search and reloads all products.
  Future<void> clearSearch() async {
    _currentSearchQuery = null;
    _currentSearchFields = null;
    return refresh();
  }

  /// Creates a new product.
  /// Returns the created product on success, null on failure.
  Future<Product?> createProduct(Product product) async {
    final result = await _repository.create(product);
    return result.fold(
      (failure) => null,
      (newProduct) {
        state.whenData((currentState) {
          state = AsyncValue.data(currentState.prependItem(newProduct));
        });
        return newProduct;
      },
    );
  }

  /// Updates an existing product.
  Future<bool> updateProduct(Product product) async {
    final result = await _repository.update(product);
    return result.fold(
      (failure) => false,
      (updated) {
        state.whenData((currentState) {
          state = AsyncValue.data(
            currentState.updateItem(updated, (p) => p.id == updated.id),
          );
        });
        return true;
      },
    );
  }

  /// Deletes a product.
  Future<bool> deleteProduct(String id) async {
    final result = await _repository.delete(id);
    return result.fold(
      (failure) => false,
      (_) {
        state.whenData((currentState) {
          state = AsyncValue.data(
            currentState.removeItem((p) => p.id == id),
          );
        });
        return true;
      },
    );
  }
}
