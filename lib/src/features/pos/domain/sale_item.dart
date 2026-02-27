import 'package:dart_mappable/dart_mappable.dart';

import '../../products/domain/product.dart';

part 'sale_item.mapper.dart';

/// Sale Item domain model.
///
/// Represents a line item in a finalized sale.
@MappableClass()
class SaleItem with SaleItemMappable {
  const SaleItem({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.product,
    this.productLotId,
    this.lotNumber,
    this.itemType,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Parent Sale ID.
  final String saleId;

  /// Product ID.
  final String productId;

  /// Snapshot of product name at time of sale.
  final String productName;

  /// Quantity sold.
  final num quantity;

  /// Price per unit at time of sale.
  final num unitPrice;

  /// Line total (quantity * unitPrice).
  final num subtotal;

  /// Expanded Product (optional).
  final Product? product;

  /// Product Lot ID (for lot-tracked products).
  final String? productLotId;

  /// Lot number snapshot at time of sale.
  final String? lotNumber;

  /// Item type: 'product', 'membership', or 'addon'.
  final String? itemType;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// Whether this item was sold from a specific lot.
  bool get hasLot => productLotId != null && productLotId!.isNotEmpty;
}
