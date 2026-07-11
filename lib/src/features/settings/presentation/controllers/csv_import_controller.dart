import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../products/data/repositories/product_category_repository.dart';
import '../../../products/data/repositories/product_repository.dart';
import '../../../products/data/services/csv_import_service.dart';
import '../../../products/domain/product.dart';
import '../../../products/domain/product_category.dart';
import '../../../products/presentation/controllers/paginated_products_controller.dart';
import 'current_branch_controller.dart';
import 'product_categories_controller.dart';

part 'csv_import_controller.g.dart';

/// Import workflow phase.
enum ImportPhase { idle, parsing, staged, importing, completed }

/// State for the CSV import process.
class ImportState {
  const ImportState({
    this.phase = ImportPhase.idle,
    this.parseResult,
    this.importedCount = 0,
    this.failedCount = 0,
    this.totalToImport = 0,
    this.errors = const [],
  });

  final ImportPhase phase;
  final CsvParseResult? parseResult;
  final int importedCount;
  final int failedCount;
  final int totalToImport;
  final List<String> errors;

  ImportState copyWith({
    ImportPhase? phase,
    CsvParseResult? parseResult,
    int? importedCount,
    int? failedCount,
    int? totalToImport,
    List<String>? errors,
  }) {
    return ImportState(
      phase: phase ?? this.phase,
      parseResult: parseResult ?? this.parseResult,
      importedCount: importedCount ?? this.importedCount,
      failedCount: failedCount ?? this.failedCount,
      totalToImport: totalToImport ?? this.totalToImport,
      errors: errors ?? this.errors,
    );
  }
}

/// Controller for managing CSV product import.
@riverpod
class CsvImportController extends _$CsvImportController {
  @override
  ImportState build() => const ImportState();

  /// Parse CSV content and stage the data for review.
  Future<void> parseAndStage(String csvContent) async {
    state = state.copyWith(phase: ImportPhase.parsing);

    // Fetch existing categories
    final categoriesResult =
        await ref.read(productCategoryRepositoryProvider).fetchAll();

    final existingCategories = categoriesResult.fold(
      (_) => <ProductCategory>[],
      (categories) => categories,
    );

    final service = CsvImportService();
    final result = service.parse(csvContent, existingCategories);

    state = ImportState(
      phase: ImportPhase.staged,
      parseResult: result,
    );
  }

  /// Toggle selection of a single entry.
  void toggleEntry(int index) {
    final result = state.parseResult;
    if (result == null || index >= result.entries.length) return;
    result.entries[index].isSelected = !result.entries[index].isSelected;
    // Force state update
    state = state.copyWith(parseResult: result);
  }

  /// Select or deselect all entries.
  void selectAll(bool selected) {
    final result = state.parseResult;
    if (result == null) return;
    for (final entry in result.entries) {
      entry.isSelected = selected;
    }
    state = state.copyWith(parseResult: result);
  }

  /// Execute the import: create categories first, then products.
  Future<void> executeImport() async {
    final result = state.parseResult;
    if (result == null) return;

    final selectedEntries =
        result.entries.where((e) => e.isSelected).toList();

    state = state.copyWith(
      phase: ImportPhase.importing,
      totalToImport: selectedEntries.length,
      importedCount: 0,
      failedCount: 0,
      errors: [],
    );

    // Step 1: Fetch existing categories for ID lookup
    final categoriesResult =
        await ref.read(productCategoryRepositoryProvider).fetchAll();
    final existingCategories = categoriesResult.fold(
      (_) => <ProductCategory>[],
      (categories) => categories,
    );

    // Build case-insensitive name → ID map
    final categoryMap = <String, String>{
      for (final cat in existingCategories) cat.name.toLowerCase(): cat.id,
    };

    // Step 2: Create new categories
    final categoryRepo = ref.read(productCategoryRepositoryProvider);
    for (final catName in result.newCategoryNames) {
      // Only create if any selected entry uses this category
      final isUsed = selectedEntries.any(
        (e) =>
            e.categoryName?.toLowerCase() == catName.toLowerCase(),
      );
      if (!isUsed) continue;

      final createResult = await categoryRepo.create(
        ProductCategory(id: '', name: catName),
      );
      createResult.fold(
        (failure) {
          state = state.copyWith(
            errors: [...state.errors, 'Failed to create category: $catName'],
          );
        },
        (newCategory) {
          categoryMap[catName.toLowerCase()] = newCategory.id;
        },
      );
    }

    // Step 3: Create products
    final productRepo = ref.read(productRepositoryProvider);
    final branchId = ref.read(effectiveBranchIdForWriteProvider);
    final errors = List<String>.from(state.errors);
    var imported = 0;
    var failed = 0;

    for (final entry in selectedEntries) {
      // Resolve category ID
      String? categoryId;
      if (entry.categoryName != null) {
        categoryId = categoryMap[entry.categoryName!.toLowerCase()];
      }

      final product = Product(
        id: '',
        name: entry.name,
        description: entry.description,
        categoryId: categoryId,
        price: entry.price,
        forSale: entry.forSale,
        trackStock: entry.trackStock,
        quantity: entry.quantity,
        stockThreshold: entry.stockThreshold,
        branch: branchId,
      );

      final createResult = await productRepo.create(product);
      createResult.fold(
        (failure) {
          failed++;
          errors.add('Failed to import: ${entry.name}');
        },
        (_) {
          imported++;
        },
      );

      state = state.copyWith(
        importedCount: imported,
        failedCount: failed,
        errors: errors,
      );
    }

    // Step 4: Invalidate caches
    ref.invalidate(productCategoriesControllerProvider);
    ref.invalidate(paginatedProductsControllerProvider);

    state = state.copyWith(phase: ImportPhase.completed);
  }

  /// Reset the controller to idle state.
  void reset() {
    state = const ImportState();
  }
}
