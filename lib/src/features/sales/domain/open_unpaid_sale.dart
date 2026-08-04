import '../../pos/domain/sale.dart';

/// Sale statuses that still need payment and are not closed.
const openUnpaidSaleStatuses = ['awaitingPayment', 'pending'];

/// Whether [status] is an open unpaid sale (not voided/paid/refunded).
bool isOpenUnpaidSaleStatus(String? status) {
  if (status == null || status.isEmpty) return false;
  final normalized = status.trim();
  return openUnpaidSaleStatuses.any(
    (s) => s.toLowerCase() == normalized.toLowerCase(),
  );
}

/// Normalizes a customer / walk-in name for duplicate matching.
///
/// Trims, lowercases, collapses whitespace, and strips trailing periods.
String normalizeCustomerName(String? name) {
  if (name == null) return '';
  return name
      .trim()
      .toLowerCase()
      .replaceAll('.', '')
      .replaceAll(RegExp(r'\s+'), ' ');
}

/// True when [sale] is an open unpaid sale at [branchId] (when provided).
bool isOpenUnpaidSale(Sale sale, {String? branchId}) {
  if (sale.isPaid) return false;
  if (!isOpenUnpaidSaleStatus(sale.status)) return false;
  if (branchId != null &&
      branchId.isNotEmpty &&
      sale.branchId.isNotEmpty &&
      sale.branchId != branchId) {
    return false;
  }
  return true;
}

/// Strips a trailing " <digits>" suffix from a normalized name, e.g.
/// `"jeff 10"` -> `"jeff"`. Used to catch near-duplicate walk-in entries
/// where a cashier appended a number to an otherwise identical guest name
/// (typo or retry) instead of it matching an existing unpaid sale exactly.
String _withoutTrailingNumber(String normalized) {
  final match = RegExp(r'^(.*\S)\s+\d+$').firstMatch(normalized);
  return match?.group(1) ?? normalized;
}

/// Finds open unpaid sales for the same member and/or walk-in name.
///
/// [memberId] match takes priority when both are provided.
/// Guest walk-ins match on normalized [customerName] (ignores generic
/// "Walk-in"), or on the name with a trailing number stripped (so "Jeff"
/// and "Jeff 10" are still flagged as a likely duplicate).
List<Sale> findMatchingOpenUnpaidSales({
  required Iterable<Sale> sales,
  String? memberId,
  String? customerName,
  String? branchId,
}) {
  final member = memberId?.trim();
  final hasMember = member != null && member.isNotEmpty;
  final normalizedName = normalizeCustomerName(customerName);
  final ignoreName = normalizedName.isEmpty ||
      normalizedName == normalizeCustomerName(Sale.walkInLabel);
  final baseName = _withoutTrailingNumber(normalizedName);

  return sales.where((sale) {
    if (!isOpenUnpaidSale(sale, branchId: branchId)) return false;

    if (hasMember) {
      final saleMember = sale.customerId?.trim();
      return saleMember != null && saleMember == member;
    }

    if (ignoreName) return false;
    final saleName = normalizeCustomerName(sale.customerName);
    if (saleName == normalizedName) return true;
    return baseName.isNotEmpty && baseName == _withoutTrailingNumber(saleName);
  }).toList();
}
