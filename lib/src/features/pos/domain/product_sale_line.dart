/// A product line from a sale, for product sales-history UI.
///
/// Built from a `saleItems` record with an expanded parent `sale`.
/// Kept separate from [SaleItem]/[Sale] to avoid circular imports.
class ProductSaleLine {
  const ProductSaleLine({
    required this.saleItemId,
    required this.saleId,
    required this.receiptNumber,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.isPaid,
    required this.status,
    this.customerName,
    this.lotNumber,
    this.created,
  });

  /// Sale item record ID.
  final String saleItemId;

  /// Parent sale ID (for navigating to sale detail).
  final String saleId;

  /// Human-readable receipt number from the parent sale.
  final String receiptNumber;

  /// Quantity sold on this line.
  final num quantity;

  /// Unit price at time of sale.
  final num unitPrice;

  /// Line subtotal (quantity * unitPrice).
  final num subtotal;

  /// Whether the parent sale is fully paid.
  final bool isPaid;

  /// Parent sale status (e.g. completed, voided, pending).
  final String status;

  /// Customer display name from the parent sale, if any.
  final String? customerName;

  /// Lot number snapshot when sold from a lot.
  final String? lotNumber;

  /// When this line was created (sale item timestamp).
  final DateTime? created;

  /// Whether this line was sold from a specific lot.
  bool get hasLot => lotNumber != null && lotNumber!.isNotEmpty;
}
