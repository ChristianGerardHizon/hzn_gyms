import 'package:dart_mappable/dart_mappable.dart';

import 'product_adjustment_type.dart';

part 'product_adjustment.mapper.dart';

/// ProductAdjustment domain model.
///
/// Represents a stock adjustment record for audit trail purposes.
/// Tracks changes to product or lot quantities with reason and timestamps.
@MappableClass()
class ProductAdjustment with ProductAdjustmentMappable {
  const ProductAdjustment({
    required this.id,
    required this.type,
    required this.oldValue,
    required this.newValue,
    this.reason,
    this.productId,
    this.productStockId,
    this.productLotId,
    this.saleId,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Type of adjustment (product or productStock/lot).
  final ProductAdjustmentType type;

  /// Previous quantity value before adjustment.
  final num oldValue;

  /// New quantity value after adjustment.
  final num newValue;

  /// Optional reason for the adjustment.
  final String? reason;

  /// Product FK ID (when type is product).
  final String? productId;

  /// ProductStock FK ID (when type is productStock).
  final String? productStockId;

  /// ProductLot FK ID (when type is productStock for lot adjustments).
  final String? productLotId;

  /// Sale FK ID when the adjustment was caused by a POS sale or void.
  final String? saleId;

  /// Soft delete flag.
  final bool isDeleted;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// Returns the change delta (positive for increase, negative for decrease).
  num get delta => newValue - oldValue;

  /// Returns true if this was a stock increase.
  bool get isIncrease => delta > 0;

  /// Returns true if this was a stock decrease.
  bool get isDecrease => delta < 0;

  /// Formatted delta display with +/- prefix.
  String get deltaDisplay {
    final prefix = delta >= 0 ? '+' : '';
    return '$prefix${delta.toStringAsFixed(0)}';
  }

  /// Formatted old value display.
  String get oldValueDisplay => oldValue.toStringAsFixed(0);

  /// Formatted new value display.
  String get newValueDisplay => newValue.toStringAsFixed(0);
}
