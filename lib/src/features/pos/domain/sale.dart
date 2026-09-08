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
    this.voidReason,
    this.idempotencyKey,
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

  /// Transaction status (completed, voided).
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

  /// Optional reason entered when the sale was voided.
  final String? voidReason;

  /// Client-generated key so retries reuse this sale instead of duplicating.
  final String? idempotencyKey;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// Stored / display label for sales with no linked member.
  static const walkInLabel = 'Walk-in';

  /// Whether this sale has no linked member (day pass / product walk-in).
  bool get isWalkIn {
    final id = customerId?.trim();
    return id == null || id.isEmpty;
  }

  /// Whether this sale is linked to a named customer / member.
  bool get hasCustomer {
    final name = customerName?.trim();
    final hasRealName =
        name != null && name.isNotEmpty && name != walkInLabel;
    return !isWalkIn || hasRealName;
  }

  /// Display label for customer; [walkInLabel] when none is linked.
  String get customerDisplay {
    final name = customerName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return walkInLabel;
  }

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

  /// Primary headline for the sale detail page.
  ///
  /// Prefers [descriptor], then [customerName], then the full [receiptNumber].
  String get detailTitle {
    final value = descriptor?.trim();
    if (value != null && value.isNotEmpty) return value;
    final name = customerName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return receiptNumber;
  }

  /// Builds a list descriptor from sale line items.
  ///
  /// When [isWalkIn] is true (no linked member), descriptors are prefixed with
  /// [walkInLabel] so day-pass / guest sales are searchable/identifiable.
  static String buildDescriptor({
    required List<SaleItem> items,
    String? customerName,
    bool isWalkIn = false,
  }) {
    if (items.isEmpty) {
      final name = customerName?.trim();
      if (name != null && name.isNotEmpty) return name;
      return isWalkIn ? walkInLabel : 'Sale';
    }

    if (isWalkIn) {
      final primary = items.first;
      final planName = primary.productName.trim();
      final name = customerName?.trim();
      final parts = <String>[walkInLabel];
      if (name != null && name.isNotEmpty && name != walkInLabel) {
        parts.add(name);
      }
      if (planName.isNotEmpty) parts.add(planName);
      final base = parts.join(' · ');
      final extras = items.length - 1;
      if (extras <= 0) return base;
      return '$base +$extras add-on${extras == 1 ? '' : 's'}';
    }

    final membershipItems =
        items.where((item) => item.itemType == 'membership');
    if (membershipItems.isNotEmpty) {
      final membershipItem = membershipItems.first;
      final planName = membershipItem.productName.trim();
      final name = customerName?.trim();
      final addOnCount =
          items.where((item) => item.itemType == 'addon').length;
      final String base;
      if (name != null && name.isNotEmpty && planName.isNotEmpty) {
        base = '$name · $planName';
      } else if (planName.isNotEmpty) {
        base = planName;
      } else {
        base = name ?? 'Membership';
      }
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

  /// Resolves the customer name to persist for a sale.
  ///
  /// Walk-in / day-pass sales (no linked member) always store a non-empty
  /// [customerName] so they remain searchable — either the provided name or
  /// [walkInLabel].
  static String? resolveCustomerName({
    String? customerId,
    String? customerName,
  }) {
    final linkedId = customerId?.trim();
    final hasMember = linkedId != null && linkedId.isNotEmpty;
    final name = customerName?.trim();
    if (hasMember) {
      return (name != null && name.isNotEmpty) ? name : null;
    }
    if (name != null && name.isNotEmpty) return name;
    return walkInLabel;
  }
}
