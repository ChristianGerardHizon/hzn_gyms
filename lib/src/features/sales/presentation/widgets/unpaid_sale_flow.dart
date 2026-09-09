import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/routing/org_scoped_navigation.dart';
import '../../../../core/routing/routes/sales_history.routes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../dashboard/presentation/controllers/dashboard_refresh.dart';
import '../../../dashboard/presentation/controllers/todays_sales_controller.dart';
import '../../../memberships/data/repositories/member_membership_repository.dart';
import '../../../pos/data/repositories/sales_repository.dart';
import '../../../pos/domain/sale.dart';
import '../../../products/data/repositories/product_adjustment_repository.dart';
import '../../../products/data/repositories/product_lot_repository.dart';
import '../../../products/data/repositories/product_repository.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../data/sale_side_effects.dart';
import '../controllers/sale_provider.dart';
import '../controllers/sale_refresh.dart';
import 'open_unpaid_sale_dialog.dart';
import 'payment_disposition_dialog.dart';
import 'record_payment_dialog.dart';
import 'void_sale_dialog.dart';

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
  if (!context.mounted) return false;

  switch (action) {
    case OpenUnpaidSaleAction.openExisting:
      SaleDetailRoute(id: existing.id).goScoped(context);
      return false;
    case OpenUnpaidSaleAction.voidAndRecreate:
      // Capture deps before the async void so we never touch [ref] after dispose.
      final salesRepo = ref.read(salesRepositoryProvider);
      final memberMembershipRepo = ref.read(memberMembershipRepositoryProvider);
      final lotRepo = ref.read(productLotRepositoryProvider);
      final productRepo = ref.read(productRepositoryProvider);
      final adjustmentRepo = ref.read(productAdjustmentRepositoryProvider);
      final voidedById = ref.read(currentAuthProvider)?.user.id;
      final container = ProviderScope.containerOf(context);

      final reason = await showVoidSaleDialog(context);
      if (reason == null || !context.mounted) return false;

      final voided = await voidSaleWithSideEffects(
        salesRepo: salesRepo,
        memberMembershipRepo: memberMembershipRepo,
        lotRepo: lotRepo,
        productRepo: productRepo,
        adjustmentRepo: adjustmentRepo,
        saleId: existing.id,
        voidedById: voidedById,
        voidReason: reason,
      );
      final ok = voided.fold((_) => false, (_) => true);
      if (ok && context.mounted) {
        refreshAfterSaleVoidedOnContainer(container, existing.id);
        container.invalidate(todayUnpaidSalesProvider);
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
  BuildContext context, {
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

    // Caller may have been disposed while the dialog was open.
    if (!context.mounted) return paid == true;

    final container = ProviderScope.containerOf(context);
    container.invalidate(saleProvider(currentSale.id));
    refreshSalesDataOnContainer(container);
    container.invalidate(todayUnpaidSalesProvider);

    Sale? refreshed;
    try {
      refreshed = await container.read(saleProvider(currentSale.id).future);
    } catch (_) {}

    if (!context.mounted) {
      return paid == true || (refreshed?.isPaid ?? false);
    }

    if (refreshed != null) currentSale = refreshed;

    if (paid == true || currentSale.isPaid) {
      return true;
    }

    final disposition = await showPaymentDispositionDialog(
      context,
      sale: currentSale,
    );
    if (!context.mounted) return false;

    switch (disposition) {
      case PaymentDisposition.recordPayment:
        remaining = currentSale.totalAmount;
        continue;
      case PaymentDisposition.voidSale:
        // Use container from [context] so this stays safe when a parent dialog
        // was already popped (renew / quick-view flows).
        final reason = await showVoidSaleDialog(context);
        if (reason == null || !context.mounted) return false;

        final voidContainer = ProviderScope.containerOf(context);
        final salesRepo = voidContainer.read(salesRepositoryProvider);
        final memberMembershipRepo =
            voidContainer.read(memberMembershipRepositoryProvider);
        final lotRepo = voidContainer.read(productLotRepositoryProvider);
        final productRepo = voidContainer.read(productRepositoryProvider);
        final adjustmentRepo =
            voidContainer.read(productAdjustmentRepositoryProvider);
        final voidedById = voidContainer.read(currentAuthProvider)?.user.id;

        await voidSaleWithSideEffects(
          salesRepo: salesRepo,
          memberMembershipRepo: memberMembershipRepo,
          lotRepo: lotRepo,
          productRepo: productRepo,
          adjustmentRepo: adjustmentRepo,
          saleId: currentSale.id,
          voidedById: voidedById,
          voidReason: reason,
        );
        if (context.mounted) {
          refreshAfterSaleVoidedOnContainer(voidContainer, currentSale.id);
          voidContainer.invalidate(todayUnpaidSalesProvider);
        }
        return false;
      case PaymentDisposition.keepUnpaid:
      case null:
        return false;
    }
  }
  return false;
}
