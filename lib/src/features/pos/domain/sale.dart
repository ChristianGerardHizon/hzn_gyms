import 'package:dart_mappable/dart_mappable.dart';

import 'sale_item.dart';

part 'sale.mapper.dart';

/// Sale domain model.
///
/// Represents a finalized transaction/receipt.
@MappableClass()
class Sale with SaleMappable {
  const Sale({
    required this.id,
    required this.receiptNumber,
    required this.branchId,
    required this.cashierId,
    required this.totalAmount,
    required this.status,
    this.isPaid = false,
    this.customerId,
    this.customerName,
    this.descriptor,
    this.notes,
    this.voidedById,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Human-readable receipt number.
  final String receiptNumber;

  /// Branch ID where sale occurred.
  final String branchId;

  /// Cashier User ID.
  final String cashierId;

  /// Total amount charged.
  final num totalAmount;

  /// Transaction status (completed, refunded, voided).
  final String status;

  /// Whether the customer has fully paid (auto-calculated from payments).
  final bool isPaid;

  /// Linked customer ID (optional).
  final String? customerId;

  /// Customer name (for display).
  final String? customerName;

  /// Human-readable summary of what was sold (item or membership).
  ///
  /// Product sale example: `WATER` or `WATER +2 more`
  /// Membership sale example: `Juan Dela Cruz · Monthly Plan`
  final String? descriptor;

  /// Internal notes.
  final String? notes;

  /// User ID of whoever voided this sale (null if not voided).
  final String? voidedById;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// Returns display name for customer.
  String? get customerDisplay => customerName;

  /// Last 4 characters of the receipt number for compact list display.
  String get shortReceiptNumber {
    if (receiptNumber.length <= 4) return '#$receiptNumber';
    return '#${receiptNumber.substring(receiptNumber.length - 4)}';
  }

  /// Primary label for list/dashboard rows.
  ///
  /// Prefers [descriptor]; falls back to [shortReceiptNumber].
  String get listTitle {
    final value = descriptor?.trim();
    if (value != null && value.isNotEmpty) return value;
    return shortReceiptNumber;
  }

  /// Builds a list descriptor from sale line items.
  static String buildDescriptor({
    required List<SaleItem> items,
    String? customerName,
  }) {
    if (items.isEmpty) {
      final name = customerName?.trim();
      if (name != null && name.isNotEmpty) return name;
      return 'Sale';
    }

    final membershipItems =
        items.where((item) => item.itemType == 'membership');
    if (membershipItems.isNotEmpty) {
      final membershipItem = membershipItems.first;
      final planName = membershipItem.productName.trim();
      final name = customerName?.trim();
      final addOnCount =
          items.where((item) => item.itemType == 'addon').length;
      final base = (name != null && name.isNotEmpty && planName.isNotEmpty)
          ? '$name · $planName'
          : (planName.isNotEmpty
              ? planName
              : (name ?? 'Membership'));
      if (addOnCount <= 0) return base;
      return '$base +$addOnCount add-on${addOnCount == 1 ? '' : 's'}';
    }

    final productItems = items
        .where(
          (item) =>
              item.itemType == null ||
              item.itemType == 'product' ||
              item.itemType!.isEmpty,
        )
        .toList();
    final namedItems =
        productItems.isNotEmpty ? productItems : items;
    final firstName = namedItems.first.productName.trim();
    if (namedItems.length == 1) {
      return firstName.isNotEmpty ? firstName : 'Sale';
    }
    final label = firstName.isNotEmpty ? firstName : 'Item';
    return '$label +${namedItems.length - 1} more';
  }
}
