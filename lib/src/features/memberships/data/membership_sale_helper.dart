import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/foundation/failure.dart';
import '../../../core/utils/receipt_utils.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../pos/data/repositories/sales_repository.dart';
import '../../pos/domain/sale.dart';
import '../../pos/domain/sale_item.dart';
import '../domain/membership.dart';
import '../domain/membership_add_on.dart';

/// Creates a Sale record for a membership purchase.
///
/// Builds a Sale with line items for the membership plan and each selected
/// add-on, then persists it via [SalesRepository]. The returned [Sale] can
/// be linked to the [MemberMembership] record via its `saleId` field.
///
/// When [memberId] is null/empty (walk-in / day pass), the sale stores only
/// [customerName] with no linked member.
///
/// Pass [idempotencyKey] so retries reuse the same sale instead of creating
/// a duplicate.
Future<Either<Failure, Sale>> createMembershipSale({
  required WidgetRef ref,
  String? memberId,
  required String customerName,
  required Membership plan,
  required Set<MembershipAddOn> addOns,
  required String branchId,
  String? idempotencyKey,
}) async {
  final auth = ref.read(currentAuthProvider);
  if (auth == null) {
    return left(const GenericFailure('Not authenticated'));
  }

  final cashierId = auth.user.id;
  final receiptNumber = generateReceiptNumber();

  // Compute total
  final addOnTotal = addOns.fold<num>(0, (sum, a) => sum + a.price);
  final totalAmount = plan.price + addOnTotal;

  final linkedMemberId = memberId?.trim();
  final hasMember = linkedMemberId != null && linkedMemberId.isNotEmpty;
  final resolvedCustomerName = Sale.resolveCustomerName(
    customerId: linkedMemberId,
    customerName: customerName,
  )!;

  // Build sale
  final sale = Sale(
    id: '',
    receiptNumber: receiptNumber,
    branchId: branchId,
    cashierId: cashierId,
    totalAmount: totalAmount,
    status: 'awaitingPayment',
    isPaid: false,
    customerId: hasMember ? linkedMemberId : null,
    customerName: resolvedCustomerName,
    idempotencyKey: idempotencyKey,
  );

  // Build sale items
  // Guest / walk-in day-pass lines use itemType `walkIn` so Sales reports them
  // separately from standard memberships (and Memberships report ignores them).
  final planItemType = hasMember ? 'membership' : 'walkIn';
  final addOnItemType = hasMember ? 'addon' : 'walkIn';
  final saleItems = <SaleItem>[
    // Membership plan line item
    SaleItem(
      id: '',
      saleId: '',
      productId: '',
      productName: plan.name,
      quantity: 1,
      unitPrice: plan.price,
      subtotal: plan.price,
      itemType: planItemType,
    ),
    // Add-on line items
    ...addOns.map(
      (addOn) => SaleItem(
        id: '',
        saleId: '',
        productId: '',
        productName: addOn.name,
        quantity: 1,
        unitPrice: addOn.price,
        subtotal: addOn.price,
        itemType: addOnItemType,
      ),
    ),
  ];

  final salesRepo = ref.read(salesRepositoryProvider);
  return salesRepo.createSale(sale, saleItems);
}
