import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:ebe_gym/src/core/foundation/failure.dart';
import 'package:ebe_gym/src/features/check_in/data/repositories/check_in_repository.dart';
import 'package:ebe_gym/src/features/check_in/domain/card_check_in_result.dart';
import 'package:ebe_gym/src/features/check_in/domain/check_in.dart';
import 'package:ebe_gym/src/features/check_in/presentation/controllers/check_in_controller.dart';
import 'package:ebe_gym/src/features/member_cards/data/repositories/member_card_repository.dart';
import 'package:ebe_gym/src/features/members/data/repositories/member_repository.dart';
import 'package:ebe_gym/src/features/memberships/data/repositories/member_membership_repository.dart';
import 'package:ebe_gym/src/features/pos/data/repositories/sales_repository.dart';
import 'package:ebe_gym/src/features/settings/presentation/controllers/current_branch_controller.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

class _FakeCheckIn extends Fake implements CheckIn {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeCheckIn());
    registerFallbackValue(CheckInMethod.rfid);
  });

  late MockCheckInRepository checkInRepo;
  late MockMemberCardRepository cardRepo;
  late MockMemberRepository memberRepo;
  late MockMemberMembershipRepository mmRepo;
  late MockSalesRepository salesRepo;
  void Function(RecordSubscriptionEvent event)? onRealtimeEvent;
  var unsubscribeCalls = 0;

  ProviderContainer createContainer({
    bool viewingAll = false,
    String? branchId = 'branch-1',
  }) {
    checkInRepo = MockCheckInRepository();
    cardRepo = MockMemberCardRepository();
    memberRepo = MockMemberRepository();
    mmRepo = MockMemberMembershipRepository();
    salesRepo = MockSalesRepository();
    onRealtimeEvent = null;
    unsubscribeCalls = 0;

    when(() => checkInRepo.fetchTodaysCheckIns(any()))
        .thenAnswer((_) async => right(<CheckIn>[]));
    when(() => checkInRepo.invalidateCache()).thenReturn(null);
    when(
      () => checkInRepo.subscribeCheckIns(
        branchId: any(named: 'branchId'),
        onEvent: any(named: 'onEvent'),
      ),
    ).thenAnswer((invocation) async {
      onRealtimeEvent =
          invocation.namedArguments[#onEvent]
              as void Function(RecordSubscriptionEvent event);
      return () async {
        unsubscribeCalls++;
      };
    });

    return ProviderContainer(
      overrides: [
        checkInRepositoryProvider.overrideWithValue(checkInRepo),
        memberCardRepositoryProvider.overrideWithValue(cardRepo),
        memberRepositoryProvider.overrideWithValue(memberRepo),
        memberMembershipRepositoryProvider.overrideWithValue(mmRepo),
        salesRepositoryProvider.overrideWithValue(salesRepo),
        viewingAllBranchesProvider.overrideWithValue(viewingAll),
        effectiveBranchIdForWriteProvider.overrideWithValue(branchId),
        currentBranchIdProvider.overrideWithValue(branchId),
      ],
    );
  }

  test('returns no branch when viewing all branches', () async {
    final container = createContainer(viewingAll: true, branchId: null);
    addTearDown(container.dispose);

    final result = await container
        .read(checkInControllerProvider.notifier)
        .cardCheckIn(cardValue: 'RFID');

    expect(result, isA<CardCheckInNoBranch>());
  });

  test('returns card not found when card and legacy RFID miss', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    when(() => cardRepo.findByCardValue(any()))
        .thenAnswer((_) async => right(null));
    when(
      () => memberRepo.search(any(), fields: any(named: 'fields')),
    ).thenAnswer((_) async => right([]));

    final result = await container
        .read(checkInControllerProvider.notifier)
        .cardCheckIn(cardValue: 'MISSING');

    expect(result, isA<CardCheckInCardNotFound>());
  });

  test('returns no active membership when member has none', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    when(() => cardRepo.findByCardValue('RFID123')).thenAnswer(
      (_) async => right(buildMemberCard()),
    );
    when(() => mmRepo.fetchActive('member-1')).thenAnswer(
      (_) async => right([]),
    );

    final result = await container
        .read(checkInControllerProvider.notifier)
        .cardCheckIn(cardValue: 'RFID123');

    expect(result, isA<CardCheckInNoActiveMembership>());
  });

  test('returns unpaid membership when linked sale is unpaid', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    when(() => cardRepo.findByCardValue('RFID123')).thenAnswer(
      (_) async => right(buildMemberCard()),
    );
    when(() => mmRepo.fetchActive('member-1')).thenAnswer(
      (_) async => right([
        buildMemberMembership(saleId: 'sale-unpaid'),
      ]),
    );
    when(() => salesRepo.getSale('sale-unpaid')).thenAnswer(
      (_) async => right(
        buildSale(id: 'sale-unpaid', status: 'awaitingPayment', isPaid: false),
      ),
    );

    final result = await container
        .read(checkInControllerProvider.notifier)
        .cardCheckIn(cardValue: 'RFID123');

    expect(result, isA<CardCheckInUnpaidMembership>());
  });

  test('returns wrong branch when membership not valid here', () async {
    final container = createContainer(branchId: 'branch-2');
    addTearDown(container.dispose);

    when(() => cardRepo.findByCardValue(any())).thenAnswer(
      (_) async => right(buildMemberCard()),
    );
    when(() => mmRepo.fetchActive('member-1')).thenAnswer(
      (_) async => right([
        buildMemberMembership(
          membershipValidBranches: const ['branch-1'],
        ),
      ]),
    );

    final result = await container
        .read(checkInControllerProvider.notifier)
        .cardCheckIn(cardValue: 'RFID123');

    expect(result, isA<CardCheckInMembershipNotValidAtBranch>());
  });

  test('success path creates check-in', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    final checkIn = buildCheckIn(memberMembershipId: 'mm-1');

    when(() => cardRepo.findByCardValue(any())).thenAnswer(
      (_) async => right(
        buildMemberCard(memberPhoto: 'https://pb.example/jane.jpg'),
      ),
    );
    when(() => mmRepo.fetchActive('member-1')).thenAnswer(
      (_) async => right([buildMemberMembership()]),
    );
    when(
      () => checkInRepo.checkIn(
        memberId: any(named: 'memberId'),
        branchId: any(named: 'branchId'),
        method: any(named: 'method'),
        memberMembershipId: any(named: 'memberMembershipId'),
      ),
    ).thenAnswer((_) async => right(checkIn));

    final result = await container
        .read(checkInControllerProvider.notifier)
        .cardCheckIn(cardValue: 'RFID123');

    expect(result, isA<CardCheckInSuccess>());
    final success = result as CardCheckInSuccess;
    expect(success.memberName, 'Jane Doe');
    expect(success.checkIn.id, checkIn.id);
    expect(success.membershipName, 'Monthly Plan');
    expect(success.membershipEndDate, isNotNull);
    expect(success.membershipDaysRemaining, isNotNull);
    expect(success.memberPhoto, 'https://pb.example/jane.jpg');
  });

  test('returns failed when check-in repository errors', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    when(() => cardRepo.findByCardValue(any())).thenAnswer(
      (_) async => right(buildMemberCard()),
    );
    when(() => mmRepo.fetchActive('member-1')).thenAnswer(
      (_) async => right([buildMemberMembership()]),
    );
    when(
      () => checkInRepo.checkIn(
        memberId: any(named: 'memberId'),
        branchId: any(named: 'branchId'),
        method: any(named: 'method'),
        memberMembershipId: any(named: 'memberMembershipId'),
      ),
    ).thenAnswer((_) async => left(const GenericFailure('boom')));

    final result = await container
        .read(checkInControllerProvider.notifier)
        .cardCheckIn(cardValue: 'RFID123');

    expect(result, isA<CardCheckInFailed>());
  });

  test('realtime event soft-refreshes today list without loading flash', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    await container.read(checkInControllerProvider.future);
    // Allow async subscribe setup to capture the callback.
    await Future<void>.delayed(Duration.zero);
    expect(onRealtimeEvent, isNotNull);

    final remoteCheckIn = buildCheckIn(id: 'remote-1', memberName: 'Remote');
    when(() => checkInRepo.fetchTodaysCheckIns(any()))
        .thenAnswer((_) async => right([remoteCheckIn]));

    onRealtimeEvent!(
      RecordSubscriptionEvent(
        action: 'create',
        record: RecordModel({
          'id': 'remote-1',
          'checkInTime': DateTime.now().toUtc().toIso8601String(),
        }),
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 300));

    final list = container.read(checkInControllerProvider).value;
    expect(list, isNotNull);
    expect(list!.single.id, 'remote-1');
    expect(list.single.memberName, 'Remote');
    verify(() => checkInRepo.invalidateCache()).called(greaterThan(0));
  });

  test('dispose unsubscribes from realtime', () async {
    final container = createContainer();

    await container.read(checkInControllerProvider.future);
    await Future<void>.delayed(Duration.zero);
    expect(onRealtimeEvent, isNotNull);

    container.dispose();
    await Future<void>.delayed(Duration.zero);

    expect(unsubscribeCalls, 1);
  });
}
