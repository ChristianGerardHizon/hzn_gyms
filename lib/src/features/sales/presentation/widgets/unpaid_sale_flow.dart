import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/routing/routes/sales_history.routes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../dashboard/presentation/controllers/dashboard_refresh.dart';
import '../../../dashboard/presentation/widgets/unpaid_sales_queue_section.dart';
import '../../../memberships/data/repositories/member_membership_repository.dart';
import '../../../pos/data/repositories/sales_repository.dart';
import '../../../pos/domain/sale.dart';
import '../../../products/data/repositories/product_lot_repository.dart';
import '../../../products/data/repositories/product_repository.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../data/sale_side_effects.dart';
import '../controllers/sale_provider.dart';
import '../controllers/sale_refresh.dart';
import 'open_unpaid_sale_dialog.dart';
import 'payment_disposition_dialog.dart';
import 'record_payment_dialog.dart';

/// Looks up open unpaid sales for [memberId] / [customerName] at the branch.
Future<Sale?> findOpenUnpaidDuplicate(
  WidgetRef ref, {
  String? memberId,
  String? customerName,
}) async {
  final branchId = ref.read(effectiveBranchIdForWriteProvider);
  if (branchId == null) return null;

  final result = await ref.read(salesRepositoryProvider).getOpenUnpaidSales(
        branchId: branchId,
        memberId: memberId,
        customerName: customerName,
      );
  return result.fold((_) => null, (sales) => sales.isEmpty ? null : sales.first);
}

/// Resolves an existing unpaid duplicate before creating another sale.
///
/// Returns `true` when the caller may proceed to create a new sale.
Future<bool> resolveOpenUnpaidBeforeCreate(
  BuildContext context,
  WidgetRef ref, {
  String? memberId,
  String? customerName,
}) async {
  final existing = await findOpenUnpaidDuplicate(
    ref,
    memberId: memberId,
    customerName: customerName,
  );
  if (existing == null) return true;
  if (!context.mounted) return false;

  final action = await showOpenUnpaidSaleDialog(
    context,
    existingSale: existing,
  );

  switch (action) {
    case OpenUnpaidSaleAction.openExisting:
      if (context.mounted) {
        SaleDetailRoute(id: existing.id).go(context);
      }
      return false;
    case OpenUnpaidSaleAction.voidAndRecreate:
      final voided = await voidSaleWithSideEffects(
        salesRepo: ref.read(salesRepositoryProvider),
        memberMembershipRepo: ref.read(memberMembershipRepositoryProvider),
        lotRepo: ref.read(productLotRepositoryProvider),
        productRepo: ref.read(productRepositoryProvider),
        saleId: existing.id,
        voidedById: ref.read(currentAuthProvider)?.user.id,
      );
      final ok = voided.fold((_) => false, (_) => true);
      if (ok) {
        refreshAfterSaleVoided(ref, existing.id);
        ref.invalidate(todayUnpaidSalesProvider);
      }
      return ok;
    case OpenUnpaidSaleAction.cancel:
    case null:
      return false;
  }
}

/// Shows record-payment, and if dismissed, asks how to dispose of the unpaid sale.
///
/// Returns whether the sale ended up paid.
Future<bool> recordPaymentWithDisposition(
  BuildContext context,
  WidgetRef ref, {
  required Sale sale,
  required num balanceDue,
}) async {
  var currentSale = sale;
  var remaining = balanceDue;

  while (context.mounted) {
    final paid = await showRecordPaymentDialog(
      context,
      sale: currentSale,
      balanceDue: remaining,
    );

    ref.invalidate(saleProvider(currentSale.id));
    refreshSalesData(ref);
    ref.invalidate(todayUnpaidSalesProvider);

    Sale? refreshed;
    try {
      refreshed = await ref.read(saleProvider(currentSale.id).future);
    } catch (_) {}

    if (refreshed != null) currentSale = refreshed;

    if (paid == true || currentSale.isPaid) {
      return true;
    }

    if (!context.mounted) return false;

    final disposition = await showPaymentDispositionDialog(
      context,
      sale: currentSale,
    );

    switch (disposition) {
      case PaymentDisposition.recordPayment:
        remaining = currentSale.totalAmount;
        continue;
      case PaymentDisposition.voidSale:
        await voidSaleWithSideEffects(
          salesRepo: ref.read(salesRepositoryProvider),
          memberMembershipRepo: ref.read(memberMembershipRepositoryProvider),
          lotRepo: ref.read(productLotRepositoryProvider),
          productRepo: ref.read(productRepositoryProvider),
          saleId: currentSale.id,
          voidedById: ref.read(currentAuthProvider)?.user.id,
        );
        refreshAfterSaleVoided(ref, currentSale.id);
        ref.invalidate(todayUnpaidSalesProvider);
        return false;
      case PaymentDisposition.keepUnpaid:
      case null:
        return false;
    }
  }
  return false;
}
