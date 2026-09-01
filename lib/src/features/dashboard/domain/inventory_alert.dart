import 'package:dart_mappable/dart_mappable.dart';

part 'inventory_alert.mapper.dart';

/// Types of inventory alerts.
enum InventoryAlertType {
  lowStock,
  outOfStock,
  nearExpiration,
  expired,
}

/// Classifies quantity from low-stock views into low vs out of stock.
///
/// Those views already filter to `quantity <= stockThreshold`. Zero (or
/// negative) stock is [InventoryAlertType.outOfStock]; remaining items are
/// [InventoryAlertType.lowStock].
InventoryAlertType stockAlertTypeForQuantity(num quantity) {
  if (quantity <= 0) return InventoryAlertType.outOfStock;
  return InventoryAlertType.lowStock;
}

/// Represents a unified inventory alert that can be either:
/// - Product-level (for non-lot-tracked products)
/// - Lot-level (for lot-tracked products with specific lot info)
@MappableClass()
class InventoryAlert with InventoryAlertMappable {
  const InventoryAlert({
    required this.productId,
    required this.productName,
    required this.alertType,
    required this.isLotTracked,
    this.lotId,
    this.lotNumber,
    this.currentQuantity,
    this.threshold,
    this.expirationDate,
    this.daysUntilExpiration,
  });

  /// Product ID.
  final String productId;

  /// Product name for display.
  final String productName;

  /// Type of alert.
  final InventoryAlertType alertType;

  /// Whether this product uses lot tracking.
  final bool isLotTracked;

  /// Lot ID (only for lot-tracked products).
  final String? lotId;

  /// Lot number (only for lot-tracked products).
  final String? lotNumber;

  /// Current stock quantity (total for lot-tracked, direct for non-lot).
  final num? currentQuantity;

  /// Stock threshold for low stock alerts.
  final num? threshold;

  /// Expiration date.
  final DateTime? expirationDate;

  /// Days until expiration (negative if expired).
  final int? daysUntilExpiration;

  /// Display label for the alert item.
  String get displayLabel {
    if (isLotTracked && lotNumber != null) {
      return '$productName (Lot: $lotNumber)';
    }
    return productName;
  }

  /// Formatted quantity display.
  String get quantityDisplay {
    if (currentQuantity == null) return 'N/A';
    return currentQuantity!.toStringAsFixed(0);
  }
}

/// Summary of inventory alerts grouped by type.
@MappableClass()
class InventoryAlertsSummary with InventoryAlertsSummaryMappable {
  const InventoryAlertsSummary({
    this.lowStockAlerts = const [],
    this.outOfStockAlerts = const [],
    this.nearExpirationAlerts = const [],
    this.expiredAlerts = const [],
  });

  final List<InventoryAlert> lowStockAlerts;
  final List<InventoryAlert> outOfStockAlerts;
  final List<InventoryAlert> nearExpirationAlerts;
  final List<InventoryAlert> expiredAlerts;

  int get lowStockCount => lowStockAlerts.length;
  int get outOfStockCount => outOfStockAlerts.length;
  int get nearExpirationCount => nearExpirationAlerts.length;
  int get expiredCount => expiredAlerts.length;

  bool get hasAlerts =>
      lowStockAlerts.isNotEmpty ||
      outOfStockAlerts.isNotEmpty ||
      nearExpirationAlerts.isNotEmpty ||
      expiredAlerts.isNotEmpty;
}
