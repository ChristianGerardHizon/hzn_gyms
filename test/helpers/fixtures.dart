import 'package:hzn_gyms/src/core/utils/date_utils.dart';
import 'package:hzn_gyms/src/features/activity_log/domain/activity_log.dart';
import 'package:hzn_gyms/src/features/activity_log/domain/activity_log_action.dart';
import 'package:hzn_gyms/src/features/activity_log/domain/activity_log_change.dart';
import 'package:hzn_gyms/src/features/auth/domain/auth_state.dart';
import 'package:hzn_gyms/src/features/auth/domain/user.dart';
import 'package:hzn_gyms/src/features/check_in/domain/check_in.dart';
import 'package:hzn_gyms/src/features/member_cards/domain/member_card.dart';
import 'package:hzn_gyms/src/features/members/domain/member.dart';
import 'package:hzn_gyms/src/features/memberships/domain/member_membership.dart';
import 'package:hzn_gyms/src/features/memberships/domain/membership.dart';
import 'package:hzn_gyms/src/features/memberships/domain/membership_add_on.dart';
import 'package:hzn_gyms/src/features/pos/domain/cart_item.dart';
import 'package:hzn_gyms/src/features/pos/domain/payment.dart';
import 'package:hzn_gyms/src/features/pos/domain/payment_method.dart';
import 'package:hzn_gyms/src/features/pos/domain/payment_type.dart';
import 'package:hzn_gyms/src/features/pos/domain/sale.dart';
import 'package:hzn_gyms/src/features/products/domain/product.dart';
import 'package:hzn_gyms/src/features/products/domain/product_lot.dart';

/// Shared fixture builders for unit tests.
ActivityLog buildActivityLog({
  String id = 'log-1',
  ActivityLogAction action = ActivityLogAction.update,
  String collection = 'members',
  String recordId = 'mem-1',
  String summary = 'Updated Member: Juan Dela Cruz',
  List<ActivityLogChange> changes = const [],
  String? actorName = 'Chris',
  DateTime? created,
}) {
  return ActivityLog(
    id: id,
    action: action,
    collection: collection,
    recordId: recordId,
    summary: summary,
    changes: changes,
    actorName: actorName,
    created: created,
  );
}

AuthState buildAuthState({String userId = 'user-1', String token = 'token'}) {
  return AuthState(
    token: token,
    user: User(
      id: userId,
      name: 'Cashier',
      email: 'cashier@test.com',
      verified: true,
      branch: 'branch-1',
    ),
  );
}

Product buildProduct({
  String id = 'prod-1',
  String name = 'Protein',
  num price = 100,
  num? quantity = 10,
  num? stockThreshold = 5,
  bool trackStock = true,
  bool trackByLot = false,
  DateTime? expiration,
}) {
  return Product(
    id: id,
    name: name,
    price: price,
    quantity: quantity,
    stockThreshold: stockThreshold,
    trackStock: trackStock,
    trackByLot: trackByLot,
    expiration: expiration,
  );
}

ProductLot buildProductLot({
  String id = 'lot-1',
  String productId = 'prod-1',
  String lotNumber = 'L1',
  num quantity = 5,
  DateTime? expiration,
}) {
  return ProductLot(
    id: id,
    productId: productId,
    lotNumber: lotNumber,
    quantity: quantity,
    expiration: expiration,
  );
}

CartItem buildCartItem({
  String id = 'ci-1',
  String productId = 'prod-1',
  Product? product,
  num quantity = 1,
  num? customPrice,
  String? productLotId,
  String? lotNumber,
}) {
  return CartItem(
    id: id,
    productId: productId,
    product: product ?? buildProduct(id: productId),
    quantity: quantity,
    customPrice: customPrice,
    productLotId: productLotId,
    lotNumber: lotNumber,
  );
}

Membership buildMembership({
  String id = 'plan-1',
  String name = 'Monthly',
  int durationValue = 1,
  MembershipDurationUnit durationUnit = MembershipDurationUnit.months,
  num price = 1000,
  String branchId = 'branch-1',
  List<String> validBranches = const [],
  bool isActive = true,
  bool isFavorite = false,
  bool memberNotRequired = false,
}) {
  return Membership(
    id: id,
    name: name,
    durationValue: durationValue,
    durationUnit: durationUnit,
    price: price,
    branchId: branchId,
    validBranches: validBranches,
    isActive: isActive,
    isFavorite: isFavorite,
    memberNotRequired: memberNotRequired,
  );
}

MembershipAddOn buildAddOn({
  String id = 'addon-1',
  String membershipId = 'plan-1',
  String name = 'Locker',
  num price = 100,
  int durationDays = 0,
}) {
  return MembershipAddOn(
    id: id,
    membershipId: membershipId,
    name: name,
    price: price,
    durationDays: durationDays,
  );
}

MemberMembership buildMemberMembership({
  String id = 'mm-1',
  String memberId = 'member-1',
  String membershipId = 'plan-1',
  DateTime? startDate,
  DateTime? endDate,
  MemberMembershipStatus status = MemberMembershipStatus.active,
  String branchId = 'branch-1',
  List<String> membershipValidBranches = const [],
  String? memberName = 'Jane Doe',
  String? membershipName = 'Monthly Plan',
  String? saleId,
}) {
  final start = startDate ?? DateTime.now().subtract(const Duration(days: 1));
  final end = endDate ?? DateTime.now().add(const Duration(days: 29));
  return MemberMembership(
    id: id,
    memberId: memberId,
    membershipId: membershipId,
    startDate: start,
    endDate: end,
    status: status,
    branchId: branchId,
    membershipValidBranches: membershipValidBranches,
    memberName: memberName,
    membershipName: membershipName,
    saleId: saleId,
  );
}

Member buildMember({
  String id = 'member-1',
  String name = 'Jane Doe',
  String? rfidCardId,
  String? mobileNumber,
  String? addedBy,
}) {
  return Member(
    id: id,
    name: name,
    rfidCardId: rfidCardId,
    mobileNumber: mobileNumber,
    addedBy: addedBy,
  );
}

MemberCard buildMemberCard({
  String id = 'card-1',
  String memberId = 'member-1',
  String cardValue = 'RFID123',
  String? memberName = 'Jane Doe',
  String? memberPhoto,
  MemberCardStatus status = MemberCardStatus.active,
}) {
  return MemberCard(
    id: id,
    memberId: memberId,
    cardValue: cardValue,
    status: status,
    memberName: memberName,
    memberPhoto: memberPhoto,
  );
}

CheckIn buildCheckIn({
  String id = 'ci-1',
  String memberId = 'member-1',
  String branchId = 'branch-1',
  String? memberMembershipId,
  String? memberName,
  DateTime? checkInTime,
  CheckInMethod method = CheckInMethod.rfid,
  bool isVoided = false,
}) {
  return CheckIn(
    id: id,
    memberId: memberId,
    branchId: branchId,
    checkInTime: checkInTime ?? DateTime.now(),
    method: method,
    memberMembershipId: memberMembershipId,
    memberName: memberName,
    isVoided: isVoided,
  );
}

Sale buildSale({
  String id = 'sale-1',
  String receiptNumber = 'S-250101-ABCD',
  String branchId = 'branch-1',
  String cashierId = 'user-1',
  num totalAmount = 100,
  String status = 'pending',
  bool isPaid = false,
  String? customerId,
  String? customerName,
  String? descriptor,
  String? idempotencyKey,
  DateTime? created,
}) {
  return Sale(
    id: id,
    receiptNumber: receiptNumber,
    branchId: branchId,
    cashierId: cashierId,
    totalAmount: totalAmount,
    status: status,
    isPaid: isPaid,
    customerId: customerId,
    customerName: customerName,
    descriptor: descriptor,
    idempotencyKey: idempotencyKey,
    created: created,
  );
}

Payment buildPayment({
  String id = 'pay-1',
  String saleId = 'sale-1',
  num amount = 100,
  PaymentMethod paymentMethod = PaymentMethod.cash,
  PaymentType type = PaymentType.payment,
  String? paymentRef,
  String? notes,
}) {
  return Payment(
    id: id,
    saleId: saleId,
    amount: amount,
    paymentMethod: paymentMethod,
    type: type,
    paymentRef: paymentRef,
    notes: notes,
  );
}
