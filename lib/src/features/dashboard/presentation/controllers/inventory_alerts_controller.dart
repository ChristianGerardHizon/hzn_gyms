import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/inventory_alert.dart';

part 'inventory_alerts_controller.g.dart';

/// Provides comprehensive inventory alerts using optimized SQL views.
///
/// This provider queries 4 separate views in parallel:
/// - vw_low_stock_products (non-lot-tracked)
/// - vw_low_stock_lot_products (lot-tracked)
/// - vw_expired_lots
/// - vw_near_expiration_lots
///
/// Low-stock view rows are split into low stock (qty > 0, ≤ threshold) and
/// out of stock (qty ≤ 0).
@riverpod
Future<InventoryAlertsSummary> inventoryAlertsSummary(Ref ref) async {
  final branchId = ref.watch(currentBranchIdProvider);
  final pb = ref.read(pocketbaseProvider);
  final branchFilter =
      branchId != null ? 'branch = "$branchId"' : null;

  // Query all 4 views in parallel for best performance
  final results = await Future.wait([
    pb
        .collection(PocketBaseCollections.vwLowStockProducts)
        .getFullList(filter: branchFilter),
    pb
        .collection(PocketBaseCollections.vwLowStockLotProducts)
        .getFullList(filter: branchFilter),
    pb
        .collection(PocketBaseCollections.vwExpiredLots)
        .getFullList(filter: branchFilter),
    pb
        .collection(PocketBaseCollections.vwNearExpirationLots)
        .getFullList(filter: branchFilter),
  ]);

  final lowStockRecords = results[0];
  final lowStockLotRecords = results[1];
  final expiredLotRecords = results[2];
  final nearExpirationLotRecords = results[3];

  final lowStockAlerts = <InventoryAlert>[];
  final outOfStockAlerts = <InventoryAlert>[];
  final nearExpirationAlerts = <InventoryAlert>[];
  final expiredAlerts = <InventoryAlert>[];

  void addStockAlert({
    required String productId,
    required String productName,
    required bool isLotTracked,
    required num quantity,
    required num threshold,
  }) {
    final alertType = stockAlertTypeForQuantity(quantity);
    final alert = InventoryAlert(
      productId: productId,
      productName: productName,
      alertType: alertType,
      isLotTracked: isLotTracked,
      currentQuantity: quantity,
      threshold: threshold,
    );
    if (alertType == InventoryAlertType.outOfStock) {
      outOfStockAlerts.add(alert);
    } else {
      lowStockAlerts.add(alert);
    }
  }

  // Process non-lot-tracked low stock products
  for (final record in lowStockRecords) {
    addStockAlert(
      productId: record.id,
      productName: record.getStringValue('name'),
      isLotTracked: false,
      quantity: record.getDoubleValue('quantity'),
      threshold: record.getDoubleValue('stockThreshold'),
    );
  }

  // Process lot-tracked low stock products
  for (final record in lowStockLotRecords) {
    addStockAlert(
      productId: record.id,
      productName: record.getStringValue('name'),
      isLotTracked: true,
      quantity: record.getDoubleValue('total_quantity'),
      threshold: record.getDoubleValue('stockThreshold'),
    );
  }

  // Process expired lots
  for (final record in expiredLotRecords) {
    final expirationStr = record.getStringValue('expiration');
    final expiration = DateTime.tryParse(expirationStr);
    final daysUntil = expiration != null
        ? expiration.difference(DateTime.now()).inDays
        : null;

    expiredAlerts.add(InventoryAlert(
      productId: record.getStringValue('product_id'),
      productName: record.getStringValue('product_name'),
      alertType: InventoryAlertType.expired,
      isLotTracked: true,
      lotId: record.id,
      lotNumber: record.getStringValue('lotNumber'),
      currentQuantity: record.getDoubleValue('quantity'),
      expirationDate: expiration,
      daysUntilExpiration: daysUntil,
    ));
  }

  // Process near expiration lots
  for (final record in nearExpirationLotRecords) {
    final expirationStr = record.getStringValue('expiration');
    final expiration = DateTime.tryParse(expirationStr);
    final daysUntil = expiration != null
        ? expiration.difference(DateTime.now()).inDays
        : null;

    nearExpirationAlerts.add(InventoryAlert(
      productId: record.getStringValue('product_id'),
      productName: record.getStringValue('product_name'),
      alertType: InventoryAlertType.nearExpiration,
      isLotTracked: true,
      lotId: record.id,
      lotNumber: record.getStringValue('lotNumber'),
      currentQuantity: record.getDoubleValue('quantity'),
      expirationDate: expiration,
      daysUntilExpiration: daysUntil,
    ));
  }

  // Sort alerts by severity/urgency
  outOfStockAlerts.sort(
      (a, b) => (a.currentQuantity ?? 0).compareTo(b.currentQuantity ?? 0));
  lowStockAlerts.sort(
      (a, b) => (a.currentQuantity ?? 0).compareTo(b.currentQuantity ?? 0));
  nearExpirationAlerts.sort((a, b) =>
      (a.daysUntilExpiration ?? 999).compareTo(b.daysUntilExpiration ?? 999));
  expiredAlerts.sort((a, b) =>
      (a.daysUntilExpiration ?? 0).compareTo(b.daysUntilExpiration ?? 0));

  return InventoryAlertsSummary(
    lowStockAlerts: lowStockAlerts,
    outOfStockAlerts: outOfStockAlerts,
    nearExpirationAlerts: nearExpirationAlerts,
    expiredAlerts: expiredAlerts,
  );
}

/// Count of low stock products (qty > 0 and ≤ threshold).
@riverpod
Future<int> lowStockAlertsCount(Ref ref) async {
  final summary = await ref.watch(inventoryAlertsSummaryProvider.future);
  return summary.lowStockCount;
}

/// Count of out-of-stock products (qty ≤ 0).
@riverpod
Future<int> outOfStockAlertsCount(Ref ref) async {
  final summary = await ref.watch(inventoryAlertsSummaryProvider.future);
  return summary.outOfStockCount;
}

/// Count of products/lots near expiration.
@riverpod
Future<int> nearExpirationAlertsCount(Ref ref) async {
  final summary = await ref.watch(inventoryAlertsSummaryProvider.future);
  return summary.nearExpirationCount;
}

/// Count of expired products/lots.
@riverpod
Future<int> expiredAlertsCount(Ref ref) async {
  final summary = await ref.watch(inventoryAlertsSummaryProvider.future);
  return summary.expiredCount;
}

/// List of low stock alerts for display.
@riverpod
Future<List<InventoryAlert>> lowStockAlerts(Ref ref) async {
  final summary = await ref.watch(inventoryAlertsSummaryProvider.future);
  return summary.lowStockAlerts;
}

/// List of out-of-stock alerts for display.
@riverpod
Future<List<InventoryAlert>> outOfStockAlerts(Ref ref) async {
  final summary = await ref.watch(inventoryAlertsSummaryProvider.future);
  return summary.outOfStockAlerts;
}

/// List of near expiration alerts for display.
@riverpod
Future<List<InventoryAlert>> nearExpirationAlerts(Ref ref) async {
  final summary = await ref.watch(inventoryAlertsSummaryProvider.future);
  return summary.nearExpirationAlerts;
}

/// List of expired alerts for display.
@riverpod
Future<List<InventoryAlert>> expiredAlerts(Ref ref) async {
  final summary = await ref.watch(inventoryAlertsSummaryProvider.future);
  return summary.expiredAlerts;
}
