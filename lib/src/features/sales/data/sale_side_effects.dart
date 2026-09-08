import 'package:fpdart/fpdart.dart';

import '../../../core/foundation/type_defs.dart';
import '../../memberships/data/repositories/member_membership_repository.dart';
import '../../memberships/domain/member_membership.dart';
import '../../memberships/domain/membership_payment_lifecycle.dart';
import '../../pos/data/repositories/sales_repository.dart';
import '../../pos/domain/sale.dart';
import '../../products/data/repositories/product_adjustment_repository.dart';
import '../../products/data/repositories/product_lot_repository.dart';
import '../../products/data/repositories/product_repository.dart';
import '../../products/domain/product_adjustment_type.dart';

/// Voids a sale and cascades membership + stock side effects.
///
/// - Sets sale `status` to `voided` (and optional `voidedBy`)
/// - Voids linked [MemberMembership] records
/// - Restores lot quantities for lot-tracked line items and syncs product totals
/// - Restores product quantities for non-lot stock-tracked line items
/// - Writes reverse [productAdjustments] linked to the same sale UUID
FutureEither<Sale> voidSaleWithSideEffects({
  required SalesRepository salesRepo,
  required MemberMembershipRepository memberMembershipRepo,
  required ProductLotRepository lotRepo,
  required ProductRepository productRepo,
  required ProductAdjustmentRepository adjustmentRepo,
  required String saleId,
  String? voidedById,
  String? voidReason,
}) async {
  final trimmedReason = voidReason?.trim();
  final body = <String, dynamic>{
    'status': 'voided',
    if (voidedById != null && voidedById.isNotEmpty) 'voidedBy': voidedById,
    if (trimmedReason != null && trimmedReason.isNotEmpty)
      'voidReason': trimmedReason,
  };

  final voidedResult = await salesRepo.updateSale(saleId, body);
  final voidedSale = voidedResult.fold<Sale?>(
    (_) => null,
    (sale) => sale,
  );
  if (voidedSale == null) {
    return voidedResult;
  }

  await memberMembershipRepo.updateStatusBySaleId(
    saleId,
    MemberMembershipStatus.voided,
  );

  final receiptLabel = voidedSale.receiptNumber.isNotEmpty
      ? voidedSale.receiptNumber
      : saleId;
  final reasonSuffix =
      (trimmedReason != null && trimmedReason.isNotEmpty)
          ? ': $trimmedReason'
          : '';
  final adjustmentReason = 'Void sale $receiptLabel$reasonSuffix';

  final itemsResult = await salesRepo.getSaleItems(saleId);
  await itemsResult.fold(
    (_) async {},
    (items) async {
      final productIdsToSync = <String>{};

      for (final item in items) {
        if (item.productId.isEmpty) continue;

        if (item.hasLot) {
          final lotChange = await lotRepo.incrementQuantity(
            item.productLotId!,
            item.quantity,
          );
          await lotChange.fold(
            (_) async {},
            (change) async {
              await adjustmentRepo.create(
                type: ProductAdjustmentType.productStock,
                oldValue: change.oldValue,
                newValue: change.newValue,
                reason: adjustmentReason,
                productId: item.productId,
                productLotId: item.productLotId,
                saleId: saleId,
              );
            },
          );
          productIdsToSync.add(item.productId);
          continue;
        }

        // Non-lot product lines: restore product.quantity when stock is tracked.
        // Membership/addon/walkIn lines are skipped (no trackStock product).
        final isProductLine =
            item.itemType == null || item.itemType == 'product';
        if (isProductLine && item.product?.trackStock == true) {
          final productChange = await productRepo.incrementQuantity(
            item.productId,
            item.quantity,
          );
          await productChange.fold(
            (_) async {},
            (change) async {
              await adjustmentRepo.create(
                type: ProductAdjustmentType.product,
                oldValue: change.oldValue,
                newValue: change.newValue,
                reason: adjustmentReason,
                productId: item.productId,
                saleId: saleId,
              );
            },
          );
        }
      }

      for (final productId in productIdsToSync) {
        final totalResult = await lotRepo.calculateTotalQuantity(productId);
        await totalResult.fold(
          (_) async {},
          (total) async {
            await productRepo.updateQuantity(productId, total);
          },
        );
      }
    },
  );

  return Right(voidedSale);
}

/// Activates memberships linked to [saleId] when the sale is paid.
///
/// No-op when [resolveMembershipStatusForSaleChange] returns `null`.
FutureEither<void> activateMembershipsForPaidSale({
  required MemberMembershipRepository memberMembershipRepo,
  required String saleId,
  required bool isPaid,
  required String status,
}) async {
  final next = resolveMembershipStatusForSaleChange(
    saleStatus: status,
    saleIsPaid: isPaid,
  );
  if (next == null) {
    return const Right(null);
  }

  return memberMembershipRepo.updateStatusBySaleId(saleId, next);
}
