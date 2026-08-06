import 'package:ebe_gym/src/features/check_in/domain/check_in_block_reason.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockSalesRepository salesRepo;

  setUp(() {
    salesRepo = MockSalesRepository();
  });

  group('checkInBlockMessage', () {
    test('returns concise unpaid explanation', () {
      expect(
        checkInBlockMessage(CheckInBlockReason.unpaidMembership, 'Syron'),
        "Syron's membership is unpaid. Record payment before check-in.",
      );
    });
  });

  group('resolveCheckInMembership', () {
    test('blocks when there are no active memberships', () async {
      final result = await resolveCheckInMembership(
        activeMemberships: const [],
        branchId: 'branch-1',
        salesRepo: salesRepo,
      );

      expect(result.isAllowed, isFalse);
      expect(result.reason, CheckInBlockReason.noActiveMembership);
    });

    test('blocks when membership is only valid at another branch', () async {
      final result = await resolveCheckInMembership(
        activeMemberships: [
          buildMemberMembership(
            membershipValidBranches: const ['branch-other'],
          ),
        ],
        branchId: 'branch-1',
        salesRepo: salesRepo,
      );

      expect(result.isAllowed, isFalse);
      expect(result.reason, CheckInBlockReason.notValidAtBranch);
      verifyNever(() => salesRepo.getSale(any()));
    });

    test('blocks when membership at branch is unpaid', () async {
      when(() => salesRepo.getSale('sale-unpaid')).thenAnswer(
        (_) async => right(
          buildSale(
            id: 'sale-unpaid',
            status: 'awaitingPayment',
            isPaid: false,
          ),
        ),
      );

      final result = await resolveCheckInMembership(
        activeMemberships: [
          buildMemberMembership(
            saleId: 'sale-unpaid',
            membershipValidBranches: const ['branch-1'],
          ),
        ],
        branchId: 'branch-1',
        salesRepo: salesRepo,
      );

      expect(result.isAllowed, isFalse);
      expect(result.reason, CheckInBlockReason.unpaidMembership);
    });

    test('allows paid membership valid at branch', () async {
      final membership = buildMemberMembership(
        saleId: 'sale-paid',
        membershipValidBranches: const ['branch-1'],
      );
      when(() => salesRepo.getSale('sale-paid')).thenAnswer(
        (_) async => right(
          buildSale(id: 'sale-paid', status: 'paid', isPaid: true),
        ),
      );

      final result = await resolveCheckInMembership(
        activeMemberships: [membership],
        branchId: 'branch-1',
        salesRepo: salesRepo,
      );

      expect(result.isAllowed, isTrue);
      expect(result.membership?.id, membership.id);
      expect(result.reason, isNull);
    });
  });
}
