import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/type_defs.dart';
import '../../data/repositories/product_adjustment_repository.dart';
import '../../data/repositories/product_lot_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/void_stock_adjustment.dart';
import '../../domain/product.dart';
import '../../domain/product_adjustment.dart';
import '../../domain/product_adjustment_type.dart';
import '../../domain/product_lot.dart';
import 'product_adjustments_controller.dart';
import 'product_lots_controller.dart';
import 'product_provider.dart';

part 'stock_adjustment_controller.g.dart';

/// Controller for handling stock adjustment operations.
///
/// Provides methods to adjust product and lot quantities with
/// automatic adjustment record creation for audit trail.
@riverpod
class StockAdjustmentController extends _$StockAdjustmentController {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Adjusts stock for a simple product (non-lot tracked).
  ///
  /// Updates the product quantity and creates an adjustment record.
  /// Returns the created adjustment on success, null on failure.
  Future<ProductAdjustment?> adjustProductStock({
    required Product product,
    required num newQuantity,
    String? reason,
  }) async {
    final productRepo = ref.read(productRepositoryProvider);
    final adjustmentRepo = ref.read(productAdjustmentRepositoryProvider);

    // Update product quantity
    final updatedProduct = product.copyWith(quantity: newQuantity);
    final updateResult = await productRepo.update(updatedProduct);

    if (updateResult.isLeft()) return null;

    // Create adjustment record
    final adjustmentResult = await adjustmentRepo.create(
      type: ProductAdjustmentType.product,
      oldValue: product.quantity ?? 0,
      newValue: newQuantity,
      reason: reason,
      productId: product.id,
    );

    // Invalidate relevant providers (check mounted first)
    if (ref.mounted) {
      ref.invalidate(productProvider(product.id));
      ref.invalidate(productAdjustmentsControllerProvider(product.id));
    }

    return adjustmentResult.fold(
      (failure) => null,
      (adjustment) => adjustment,
    );
  }

  /// Adjusts stock for a product lot.
  ///
  /// Updates the lot quantity and creates an adjustment record.
  /// Also syncs the parent product's quantity with the total of all lots.
  /// Returns the created adjustment on success, null on failure.
  Future<ProductAdjustment?> adjustLotStock({
    required ProductLot lot,
    required num newQuantity,
    String? reason,
  }) async {
    final lotRepo = ref.read(productLotRepositoryProvider);
    final productRepo = ref.read(productRepositoryProvider);
    final adjustmentRepo = ref.read(productAdjustmentRepositoryProvider);

    // Update lot quantity
    final updateResult = await lotRepo.updateQuantity(lot.id, newQuantity);

    if (updateResult.isLeft()) return null;

    // Sync product quantity with total of all lots
    await _syncProductQuantityFromLots(lot.productId, lotRepo, productRepo);

    // Create adjustment record
    final adjustmentResult = await adjustmentRepo.create(
      type: ProductAdjustmentType.productStock,
      oldValue: lot.quantity,
      newValue: newQuantity,
      reason: reason,
      productId: lot.productId,
      productLotId: lot.id,
    );

    // Invalidate relevant providers (check mounted first)
    if (ref.mounted) {
      ref.invalidate(productLotsControllerProvider(lot.productId));
      ref.invalidate(productLotsTotalProvider(lot.productId));
      ref.invalidate(productAdjustmentsControllerProvider(lot.productId));
      ref.invalidate(productProvider(lot.productId));
    }

    return adjustmentResult.fold(
      (failure) => null,
      (adjustment) => adjustment,
    );
  }

  /// Voids a manual stock adjustment (reverses quantity and writes audit row).
  FutureEither<ProductAdjustment> voidAdjustment({
    required ProductAdjustment adjustment,
    String? voidedById,
    String? reason,
  }) async {
    final result = await voidStockAdjustmentWithSideEffects(
      adjustmentRepo: ref.read(productAdjustmentRepositoryProvider),
      productRepo: ref.read(productRepositoryProvider),
      lotRepo: ref.read(productLotRepositoryProvider),
      adjustment: adjustment,
      voidedById: voidedById,
      reason: reason,
    );

    if (ref.mounted && result.isRight()) {
      final productId = adjustment.productId;
      if (productId != null && productId.isNotEmpty) {
        ref.invalidate(productProvider(productId));
        ref.invalidate(productAdjustmentsControllerProvider(productId));
        if (adjustment.type == ProductAdjustmentType.productStock) {
          ref.invalidate(productLotsControllerProvider(productId));
          ref.invalidate(productLotsTotalProvider(productId));
        }
      }
    }

    return result;
  }

  /// Syncs a product's quantity field with the total of all its lots.
  Future<void> _syncProductQuantityFromLots(
    String productId,
    ProductLotRepository lotRepo,
    ProductRepository productRepo,
  ) async {
    final totalResult = await lotRepo.calculateTotalQuantity(productId);
    await totalResult.fold(
      (failure) async {},
      (total) async {
        await productRepo.updateQuantity(productId, total);
      },
    );
  }
}
