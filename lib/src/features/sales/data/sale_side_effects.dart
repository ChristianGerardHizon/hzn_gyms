import 'package:fpdart/fpdart.dart';

import '../../../core/foundation/type_defs.dart';
import '../../memberships/data/repositories/member_membership_repository.dart';
import '../../memberships/domain/member_membership.dart';
import '../../memberships/domain/membership_payment_lifecycle.dart';
import '../../pos/data/repositories/sales_repository.dart';
import '../../pos/domain/sale.dart';
import '../../products/data/repositories/product_lot_repository.dart';
import '../../products/data/repositories/product_repository.dart';

/// Voids a sale and cascades membership + stock side effects.
///
/// - Sets sale `status` to `voided` (and optional `voidedBy`)
/// - Voids linked [MemberMembership] records
/// - Restores lot quantities for product line items and syncs product totals
FutureEither<Sale> voidSaleWithSideEffects({
  required SalesRepository salesRepo,
  required MemberMembershipRepository memberMembershipRepo,
  required ProductLotRepository lotRepo,
  required ProductRepository productRepo,
  required String saleId,
  String? voidedById,
}) async {
  final body = <String, dynamic>{
    'status': 'voided',
    if (voidedById != null && voidedById.isNotEmpty) 'voidedBy': voidedById,
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

  final itemsResult = await salesRepo.getSaleItems(saleId);
  await itemsResult.fold(
    (_) async {},
    (items) async {
      final productIdsToSync = <String>{};

      for (final item in items) {
        final lotId = item.productLotId;
        if (lotId == null || lotId.isEmpty) continue;
        await lotRepo.incrementQuantity(lotId, item.quantity);
        if (item.productId.isNotEmpty) {
          productIdsToSync.add(item.productId);
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
