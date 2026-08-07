import 'package:fpdart/fpdart.dart';

import '../../../core/foundation/failure.dart';
import '../../../core/foundation/type_defs.dart';
import '../domain/product_adjustment.dart';
import '../domain/product_adjustment_type.dart';
import '../domain/stock_quantity_change.dart';
import 'repositories/product_adjustment_repository.dart';
import 'repositories/product_lot_repository.dart';
import 'repositories/product_repository.dart';

/// Voids a manual stock adjustment and restores inventory by the reverse delta.
///
/// - Rejects already-voided, void-of, and sale-linked adjustments
/// - Applies `-delta` to the current product or lot quantity
/// - Refuses when reversing an increase would drive quantity below zero
/// - Writes a reverse [productAdjustments] row linked via `voidsAdjustment`
/// - Marks the original adjustment `isVoided`
FutureEither<ProductAdjustment> voidStockAdjustmentWithSideEffects({
  required ProductAdjustmentRepository adjustmentRepo,
  required ProductRepository productRepo,
  required ProductLotRepository lotRepo,
  required ProductAdjustment adjustment,
  String? voidedById,
  String? reason,
}) async {
  final blockReason = adjustment.voidBlockReason;
  if (blockReason != null) {
    return Left(PresentationFailure(blockReason));
  }

  final productId = adjustment.productId;
  if (productId == null || productId.isEmpty) {
    return const Left(
      PresentationFailure('Adjustment is missing a product reference'),
    );
  }

  final reverseDelta = -adjustment.delta;
  if (reverseDelta == 0) {
    return const Left(
      PresentationFailure('Cannot void an adjustment with no quantity change'),
    );
  }

  final StockQuantityChange change;
  if (adjustment.type == ProductAdjustmentType.productStock) {
    final lotId = adjustment.productLotId;
    if (lotId == null || lotId.isEmpty) {
      return const Left(
        PresentationFailure('Lot adjustment is missing a lot reference'),
      );
    }

    if (reverseDelta < 0) {
      final lotResult = await lotRepo.fetchOne(lotId);
      final currentQty = lotResult.fold<num?>(
        (_) => null,
        (lot) => lot.quantity,
      );
      if (currentQty == null) {
        return lotResult.fold(
          (f) => Left(f),
          (_) => const Left(PresentationFailure('Lot not found')),
        );
      }
      if (currentQty + reverseDelta < 0) {
        return const Left(
          PresentationFailure(
            'Cannot void: reversing this adjustment would make lot stock negative',
          ),
        );
      }
    }

    final lotChangeResult = await lotRepo.incrementQuantity(lotId, reverseDelta);
    final lotChange = lotChangeResult.fold<StockQuantityChange?>(
      (_) => null,
      (c) => c,
    );
    if (lotChange == null) {
      return lotChangeResult.fold(
        (f) => Left(f),
        (_) => const Left(PresentationFailure('Failed to update lot quantity')),
      );
    }
    change = lotChange;

    final totalResult = await lotRepo.calculateTotalQuantity(productId);
    await totalResult.fold(
      (_) async {},
      (total) async {
        await productRepo.updateQuantity(productId, total);
      },
    );
  } else {
    if (reverseDelta < 0) {
      final productResult = await productRepo.fetchOne(productId);
      final currentQty = productResult.fold<num?>(
        (_) => null,
        (p) => p.quantity ?? 0,
      );
      if (currentQty == null) {
        return productResult.fold(
          (f) => Left(f),
          (_) => const Left(PresentationFailure('Product not found')),
        );
      }
      if (currentQty + reverseDelta < 0) {
        return const Left(
          PresentationFailure(
            'Cannot void: reversing this adjustment would make stock negative',
          ),
        );
      }
    }

    final productChangeResult =
        await productRepo.incrementQuantity(productId, reverseDelta);
    final productChange = productChangeResult.fold<StockQuantityChange?>(
      (_) => null,
      (c) => c,
    );
    if (productChange == null) {
      return productChangeResult.fold(
        (f) => Left(f),
        (_) => const Left(
          PresentationFailure('Failed to update product quantity'),
        ),
      );
    }
    change = productChange;
  }

  final voidReason = (reason != null && reason.trim().isNotEmpty)
      ? reason.trim()
      : _defaultVoidReason(adjustment);

  final reverseResult = await adjustmentRepo.create(
    type: adjustment.type,
    oldValue: change.oldValue,
    newValue: change.newValue,
    reason: voidReason,
    productId: productId,
    productStockId: adjustment.productStockId,
    productLotId: adjustment.productLotId,
    voidsAdjustmentId: adjustment.id,
    voidedById: voidedById,
  );

  final reverse = reverseResult.fold<ProductAdjustment?>(
    (_) => null,
    (a) => a,
  );
  if (reverse == null) {
    return reverseResult;
  }

  final marked = await adjustmentRepo.markVoided(
    id: adjustment.id,
    voidedById: voidedById,
  );

  return marked.fold(
    (failure) => Left(failure),
    (_) => Right(reverse),
  );
}

String _defaultVoidReason(ProductAdjustment adjustment) {
  final original = adjustment.reason?.trim();
  if (original != null && original.isNotEmpty) {
    return 'Void: $original';
  }
  return 'Void adjustment ${adjustment.id}';
}
