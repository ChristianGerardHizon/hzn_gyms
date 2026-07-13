import 'package:flutter_test/flutter_test.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:ebe_gym/src/core/database/app_database.dart';
import 'package:ebe_gym/src/core/foundation/failure.dart';
import 'package:ebe_gym/src/core/sync/outbox_service.dart';
import 'package:ebe_gym/src/features/memberships/data/membership_purchase_orchestrator.dart';
import 'package:ebe_gym/src/features/memberships/domain/membership_add_on.dart';

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
      plan: buildMembership(price: 1000, durationDays: 30),
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
    expect(purchase.memberMembership.membershipName, 'Monthly');
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
    expect(purchase.memberMembership.saleId, isNull);
    expect(purchase.totalPrice, 500);
  });

  test('stacks start date after active membership end', () async {
    final orchestrator = buildOrchestrator(isOnline: false, hasAuth: true);
    final activeEnd = DateTime.now().add(const Duration(days: 10));

    final result = await orchestrator.purchase(
      memberId: 'member-1',
      memberName: 'Jane',
      plan: buildMembership(durationDays: 30),
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
        purchase.memberMembership.startDate.year,
        purchase.memberMembership.startDate.month,
        purchase.memberMembership.startDate.day,
      ),
      expectedStart,
    );
  });
}
