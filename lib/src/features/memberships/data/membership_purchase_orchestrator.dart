import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/foundation/failure.dart';
import '../../../core/packages/pocketbase/pb_connectivity_provider.dart';
import '../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../core/sync/outbox_service.dart';
import '../../../core/sync/sync_status.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/receipt_utils.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../pos/domain/sale.dart';
import '../../pos/domain/sale_item.dart';
import '../domain/member_membership.dart';
import '../domain/membership.dart';
import '../domain/membership_add_on.dart';

part 'membership_purchase_orchestrator.g.dart';

/// Result of a membership purchase (online or queued offline).
class MembershipPurchaseResult {
  const MembershipPurchaseResult({
    this.sale,
    required this.memberMembership,
    required this.totalPrice,
    required this.queuedOffline,
    this.excludedFromSales = false,
  });

  /// Null when [excludedFromSales] is true (no sale/receipt created).
  final Sale? sale;
  final MemberMembership memberMembership;
  final num totalPrice;
  final bool queuedOffline;
  final bool excludedFromSales;
}

/// Orchestrates membership purchase/renew with offline outbox support.
class MembershipPurchaseOrchestrator {
  MembershipPurchaseOrchestrator({
    required AppDatabase db,
    required OutboxService outboxService,
    required bool Function() isOnline,
    required bool Function() hasAuth,
    required PocketBase pb,
  }) : _db = db,
       _outbox = outboxService,
       _isOnline = isOnline,
       _hasAuth = hasAuth,
       _pb = pb;

  final AppDatabase _db;
  final OutboxService _outbox;
  final bool Function() _isOnline;
  final bool Function() _hasAuth;
  final PocketBase _pb;

  bool get shouldQueueOffline =>
      !_isOnline() && canWriteOffline(_pb, hasAuth: _hasAuth());

  /// Queues or returns failure if offline purchase not allowed.
  ///
  /// When [latestActiveEndDate] is set and still active, the new period
  /// stacks from the day after that end date.
  Future<Either<Failure, MembershipPurchaseResult>> purchase({
    required String memberId,
    required String memberName,
    required Membership plan,
    required Set<MembershipAddOn> addOns,
    required String branchId,
    String? soldBy,
    bool excludeFromSales = false,
    DateTime? latestActiveEndDate,
  }) async {
    if (!shouldQueueOffline) {
      return left(
        const GenericFailure('Online purchase should use repository directly'),
      );
    }

    return _queueOfflinePurchase(
      memberId: memberId,
      memberName: memberName,
      plan: plan,
      addOns: addOns,
      branchId: branchId,
      soldBy: soldBy,
      excludeFromSales: excludeFromSales,
      latestActiveEndDate: latestActiveEndDate,
    );
  }

  Future<Either<Failure, MembershipPurchaseResult>> _queueOfflinePurchase({
    required String memberId,
    required String memberName,
    required Membership plan,
    required Set<MembershipAddOn> addOns,
    required String branchId,
    String? soldBy,
    bool excludeFromSales = false,
    DateTime? latestActiveEndDate,
  }) async {
    try {
      final startDate = computeMembershipStartDate(
        latestActiveEndDate: latestActiveEndDate,
      );
      final endDate = computeMembershipEndDate(
        startDate: startDate,
        durationDays: plan.durationDays,
      );
      final addOnTotal = addOns.fold<num>(0, (sum, a) => sum + a.price);
      final totalPrice = plan.price + addOnTotal;

      final membershipId = generateClientId();

      Sale? syntheticSale;
      MemberMembership? syntheticMembership;

      await _db.transaction(() async {
        final memberCreateOutboxId =
            await _outbox.findPendingMemberCreateId(memberId);

        String? saleId;
        String? saleOutboxId;

        if (!excludeFromSales) {
          saleId = generateClientId();
          final receiptNumber = generateReceiptNumber();

          saleOutboxId = await _outbox.enqueueCreate(
            entityType: OutboxEntityType.sale,
            clientRecordId: saleId,
            dependsOnId: memberCreateOutboxId,
            payload: {
              'receiptNumber': receiptNumber,
              'branch': branchId,
              'cashier': soldBy,
              'totalAmount': totalPrice,
              'status': 'awaitingPayment',
              'isPaid': false,
              'member': memberId,
              'customerName': memberName,
            },
          );

          final saleItems = <SaleItem>[
            SaleItem(
              id: '',
              saleId: saleId,
              productId: '',
              productName: plan.name,
              quantity: 1,
              unitPrice: plan.price,
              subtotal: plan.price,
              itemType: 'membership',
            ),
            ...addOns.map(
              (addOn) => SaleItem(
                id: '',
                saleId: saleId!,
                productId: '',
                productName: addOn.name,
                quantity: 1,
                unitPrice: addOn.price,
                subtotal: addOn.price,
                itemType: 'addon',
              ),
            ),
          ];

          for (final item in saleItems) {
            final itemId = generateClientId();
            await _outbox.enqueueCreate(
              entityType: OutboxEntityType.saleItem,
              clientRecordId: itemId,
              dependsOnId: saleOutboxId,
              payload: {
                'sale': saleId,
                'product': item.productId,
                'productName': item.productName,
                'quantity': item.quantity,
                'unitPrice': item.unitPrice,
                'subtotal': item.subtotal,
                if (item.itemType != null && item.itemType!.isNotEmpty)
                  'itemType': item.itemType,
              },
            );
          }

          syntheticSale = Sale(
            id: saleId,
            receiptNumber: receiptNumber,
            branchId: branchId,
            cashierId: soldBy ?? '',
            totalAmount: totalPrice,
            status: 'awaitingPayment',
            isPaid: false,
            customerId: memberId,
            customerName: memberName,
          );
        }

        final mmOutboxId = await _outbox.enqueueCreate(
          entityType: OutboxEntityType.memberMembership,
          clientRecordId: membershipId,
          dependsOnId: saleOutboxId ?? memberCreateOutboxId,
          payload: {
            'member': memberId,
            'membership': plan.id,
            'startDate': startDate.toUtcIso8601(),
            'endDate': endDate.toUtcIso8601(),
            'status': 'active',
            'branch': branchId,
            if (saleId != null) 'saleId': saleId,
            'soldBy': soldBy,
          },
        );

        for (final addOn in addOns) {
          await _outbox.enqueueCreate(
            entityType: OutboxEntityType.memberMembershipAddOn,
            clientRecordId: generateClientId(),
            dependsOnId: mmOutboxId,
            payload: {
              'memberMembership': membershipId,
              'membershipAddOn': addOn.id,
              'addOnName': addOn.name,
              'price': addOn.price,
            },
          );
        }

        await _db.pendingMemberMembershipsDao.upsert(
          PendingMemberMembershipsCompanion.insert(
            id: membershipId,
            memberId: memberId,
            membershipId: plan.id,
            planName: plan.name,
            startDate: startDate,
            endDate: endDate,
            status: 'active',
            saleId: Value(saleId),
            syncStatus: Value(SyncStatus.pending.name),
            createdAt: DateTime.now(),
          ),
        );

        syntheticMembership = MemberMembership(
          id: membershipId,
          memberId: memberId,
          membershipId: plan.id,
          startDate: startDate,
          endDate: endDate,
          status: MemberMembershipStatus.active,
          branchId: branchId,
          memberName: memberName,
          membershipName: plan.name,
          saleId: saleId,
          soldBy: soldBy,
        );
      });

      return right(
        MembershipPurchaseResult(
          sale: syntheticSale,
          memberMembership: syntheticMembership!,
          totalPrice: totalPrice,
          queuedOffline: true,
          excludedFromSales: excludeFromSales,
        ),
      );
    } catch (e, st) {
      return left(Failure.handle(e, st));
    }
  }
}

@Riverpod(keepAlive: true)
MembershipPurchaseOrchestrator membershipPurchaseOrchestrator(Ref ref) {
  return MembershipPurchaseOrchestrator(
    db: ref.watch(appDatabaseProvider),
    outboxService: OutboxService(ref.watch(appDatabaseProvider)),
    isOnline: () => ref.read(pbConnectivityProvider).value ?? false,
    hasAuth: () => ref.read(currentAuthProvider) != null,
    pb: ref.watch(pocketbaseProvider),
  );
}
