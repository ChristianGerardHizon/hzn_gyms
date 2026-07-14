import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../products/data/repositories/product_category_repository.dart';
import '../../../products/domain/product_category.dart';

part 'product_categories_controller.g.dart';

/// Controller for managing product category list state.
///
/// Provides methods for fetching and CRUD operations on product categories.
@Riverpod(keepAlive: true)
class ProductCategoriesController extends _$ProductCategoriesController {
  ProductCategoryRepository get _repository =>
      ref.read(productCategoryRepositoryProvider);

  @override
  Future<List<ProductCategory>> build() async {
    final result = await _repository.fetchAll();
    return result.fold(
      (failure) => throw failure,
      (categories) => categories,
    );
  }

  /// Refreshes the category list.
  Future<void> refresh() async {
    // Avoid wiping previous data so list UIs (and search inputs) stay mounted.
    if (!state.hasValue) {
      state = const AsyncLoading();
    }

    final result = await _repository.fetchAll();

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (categories) => AsyncData(categories),
    );
  }

  /// Creates a new category.
  Future<bool> createCategory(ProductCategory category) async {
    final result = await _repository.create(category);

    return result.fold(
      (failure) => false,
      (newCategory) {
        final currentList = state.value ?? [];
        state = AsyncData([newCategory, ...currentList]);
        return true;
      },
    );
  }

  /// Updates an existing category.
  Future<bool> updateCategory(ProductCategory category) async {
    final result = await _repository.update(category);

    return result.fold(
      (failure) => false,
      (updatedCategory) {
        final currentList = state.value ?? [];
        final updatedList = currentList.map((c) {
          return c.id == updatedCategory.id ? updatedCategory : c;
        }).toList();
        state = AsyncData(updatedList);
        return true;
      },
    );
  }

  /// Deletes a category (soft delete).
  Future<bool> deleteCategory(String id) async {
    final result = await _repository.delete(id);

    return result.fold(
      (failure) => false,
      (_) {
        final currentList = state.value ?? [];
        final updatedList = currentList.where((c) => c.id != id).toList();
        state = AsyncData(updatedList);
        return true;
      },
    );
  }
}
