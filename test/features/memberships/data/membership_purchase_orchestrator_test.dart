import 'package:flutter_test/flutter_test.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:hzn_gyms/src/core/database/app_database.dart';
import 'package:hzn_gyms/src/core/foundation/failure.dart';
import 'package:hzn_gyms/src/core/sync/outbox_service.dart';
import 'package:hzn_gyms/src/features/memberships/data/membership_purchase_orchestrator.dart';
import 'package:hzn_gyms/src/features/memberships/domain/membership_add_on.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  late AppDatabase db;
  late OutboxService outbox;
  late PocketBase pb;

  /// Far-future JWT so [AuthStore.isValid] is true.
  const validToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
      'eyJleHAiOjQ4MzgzODQwMDB9.'
      'signature';

  setUp(() {
    db = createTestDatabase();
    outbox = OutboxService(db);
    pb = PocketBase('http://127.0.0.1');
    pb.authStore.save(validToken, null);
  });

  tearDown(() async {
    await db.close();
  });

  MembershipPurchaseOrchestrator buildOrchestrator({
    required bool isOnline,
    required bool hasAuth,
  }) {
    return MembershipPurchaseOrchestrator(
      db: db,
      outboxService: outbox,
      isOnline: () => isOnline,
      hasAuth: () => hasAuth,
      pb: pb,
    );
  }

  test('rejects when online (should use repository)', () async {
    final orchestrator = buildOrchestrator(isOnline: true, hasAuth: true);
    final result = await orchestrator.purchase(
      memberId: 'member-1',
      memberName: 'Jane',
      plan: buildMembership(price: 1000),
      addOns: {},
      branchId: 'branch-1',
    );

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<GenericFailure>()),
      (_) => fail('expected failure'),
    );
  });

  test('rejects offline when offline writes not allowed', () async {
    final orchestrator = buildOrchestrator(isOnline: false, hasAuth: false);
    final result = await orchestrator.purchase(
      memberId: 'member-1',
      memberName: 'Jane',
      plan: buildMembership(),
      addOns: {},
      branchId: 'branch-1',
    );
    expect(result.isLeft(), isTrue);
  });

  test('queues offline purchase with plan + add-on total', () async {
    final orchestrator = buildOrchestrator(isOnline: false, hasAuth: true);
    final addOn = buildAddOn(price: 150);

    final result = await orchestrator.purchase(
      memberId: 'member-1',
      memberName: 'Jane',
      plan: buildMembership(price: 1000),
      addOns: {addOn},
      branchId: 'branch-1',
      soldBy: 'user-1',
    );

    expect(result.isRight(), isTrue);
    final purchase = result.getOrElse((_) => throw StateError('left'));
    expect(purchase.queuedOffline, isTrue);
    expect(purchase.excludedFromSales, isFalse);
    expect(purchase.totalPrice, 1150);
    expect(purchase.sale, isNotNull);
    expect(purchase.sale!.totalAmount, 1150);
    expect(purchase.memberMembership!.membershipName, 'Monthly');
    expect(await outbox.countPending(), greaterThan(0));
  });

  test('excludeFromSales skips sale and still queues membership', () async {
    final orchestrator = buildOrchestrator(isOnline: false, hasAuth: true);
    final result = await orchestrator.purchase(
      memberId: 'member-1',
      memberName: 'Jane',
      plan: buildMembership(price: 500),
      addOns: <MembershipAddOn>{},
      branchId: 'branch-1',
      excludeFromSales: true,
    );

    final purchase = result.getOrElse((_) => throw StateError('left'));
    expect(purchase.excludedFromSales, isTrue);
    expect(purchase.sale, isNull);
    expect(purchase.memberMembership!.saleId, isNull);
    expect(purchase.totalPrice, 500);
  });

  test('stacks start date after active membership end', () async {
    final orchestrator = buildOrchestrator(isOnline: false, hasAuth: true);
    final activeEnd = DateTime.now().add(const Duration(days: 10));

    final result = await orchestrator.purchase(
      memberId: 'member-1',
      memberName: 'Jane',
      plan: buildMembership(),
      addOns: {},
      branchId: 'branch-1',
      latestActiveEndDate: activeEnd,
    );

    final purchase = result.getOrElse((_) => throw StateError('left'));
    final expectedStart = DateTime(
      activeEnd.year,
      activeEnd.month,
      activeEnd.day,
    ).add(const Duration(days: 1));
    expect(
      DateTime(
        purchase.memberMembership!.startDate.year,
        purchase.memberMembership!.startDate.month,
        purchase.memberMembership!.startDate.day,
      ),
      expectedStart,
    );
  });

  test('customStartDate overrides stacking default', () async {
    final orchestrator = buildOrchestrator(isOnline: false, hasAuth: true);
    final activeEnd = DateTime.now().add(const Duration(days: 10));
    final customStart = DateTime(2026, 8, 1);

    final result = await orchestrator.purchase(
      memberId: 'member-1',
      memberName: 'Jane',
      plan: buildMembership(),
      addOns: {},
      branchId: 'branch-1',
      latestActiveEndDate: activeEnd,
      customStartDate: customStart,
    );

    final purchase = result.getOrElse((_) => throw StateError('left'));
    expect(
      DateTime(
        purchase.memberMembership!.startDate.year,
        purchase.memberMembership!.startDate.month,
        purchase.memberMembership!.startDate.day,
      ),
      DateTime(2026, 8, 1),
    );
    // Default plan is 1 calendar month: Aug 1 -> Sep 1, not Aug 1 + 30 days.
    expect(
      DateTime(
        purchase.memberMembership!.endDate.year,
        purchase.memberMembership!.endDate.month,
        purchase.memberMembership!.endDate.day,
      ),
      DateTime(2026, 9, 1),
    );
  });

  test('add-on durationDays extends membership end date', () async {
    final orchestrator = buildOrchestrator(isOnline: false, hasAuth: true);
    final promo = buildAddOn(
      id: 'promo-3mo',
      name: 'Promo 3 months',
      price: 0,
      durationDays: 90,
    );
    final locker = buildAddOn(id: 'locker', name: 'Locker', price: 100);

    final result = await orchestrator.purchase(
      memberId: 'member-1',
      memberName: 'Jane',
      plan: buildMembership(),
      addOns: {promo, locker},
      branchId: 'branch-1',
      customStartDate: DateTime(2026, 1, 1),
    );

    final purchase = result.getOrElse((_) => throw StateError('left'));
    expect(purchase.totalPrice, 1100);
    expect(
      DateTime(
        purchase.memberMembership!.endDate.year,
        purchase.memberMembership!.endDate.month,
        purchase.memberMembership!.endDate.day,
      ),
      // Default plan is 1 calendar month: Jan 1 -> Feb 1, then +90 flat
      // promo days: Feb 1 -> Mar 1 (28) -> Apr 1 (31) -> May 1 (30) -> May 2 (1).
      DateTime(2026, 5, 2),
    );
  });

  test('guestMode queues sale + items only without membership', () async {
    final orchestrator = buildOrchestrator(isOnline: false, hasAuth: true);
    final addOn = buildAddOn(price: 50);

    final result = await orchestrator.purchase(
      memberName: 'Walk In Guest',
      plan: buildMembership(
        name: 'Day Pass',
        price: 100,
        memberNotRequired: true,
      ),
      addOns: {addOn},
      branchId: 'branch-1',
      soldBy: 'user-1',
      guestMode: true,
    );

    expect(result.isRight(), isTrue);
    final purchase = result.getOrElse((_) => throw StateError('left'));
    expect(purchase.queuedOffline, isTrue);
    expect(purchase.memberMembership, isNull);
    expect(purchase.sale, isNotNull);
    expect(purchase.sale!.customerName, 'Walk In Guest');
    expect(purchase.sale!.customerId, isNull);
    expect(
      purchase.sale!.descriptor,
      'Walk-in · Walk In Guest · Day Pass +1 add-on',
    );
    expect(purchase.totalPrice, 150);

    final entries = await db.select(db.outboxEntries).get();
    final entityTypes = entries.map((e) => e.entityType).toSet();
    expect(entityTypes.contains('sale'), isTrue);
    expect(entityTypes.contains('saleItem'), isTrue);
    expect(entityTypes.contains('memberMembership'), isFalse);
    final saleEntry = entries.firstWhere((e) => e.entityType == 'sale');
    expect(saleEntry.payload.contains('Walk-in'), isTrue);
    expect(saleEntry.payload.contains('descriptor'), isTrue);
    final itemPayloads = entries
        .where((e) => e.entityType == 'saleItem')
        .map((e) => e.payload)
        .toList();
    expect(itemPayloads, isNotEmpty);
    for (final payload in itemPayloads) {
      expect(payload.contains('"itemType":"walkIn"'), isTrue);
      expect(payload.contains('"itemType":"membership"'), isFalse);
      expect(payload.contains('"itemType":"product"'), isFalse);
    }
  });

  test('guestMode requires customer name', () async {
    final orchestrator = buildOrchestrator(isOnline: false, hasAuth: true);
    final result = await orchestrator.purchase(
      memberName: '   ',
      plan: buildMembership(memberNotRequired: true),
      addOns: {},
      branchId: 'branch-1',
      guestMode: true,
    );
    expect(result.isLeft(), isTrue);
  });
}
