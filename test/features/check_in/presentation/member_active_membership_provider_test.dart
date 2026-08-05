import 'dart:async';

import 'package:ebe_gym/src/core/foundation/failure.dart';
import 'package:ebe_gym/src/features/check_in/presentation/widgets/last_check_in_panel.dart';
import 'package:ebe_gym/src/features/memberships/data/repositories/member_membership_repository.dart';
import 'package:ebe_gym/src/features/memberships/domain/member_membership.dart';
import 'package:ebe_gym/src/features/pos/data/repositories/sales_repository.dart';
import 'package:ebe_gym/src/features/settings/presentation/controllers/current_branch_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockMemberMembershipRepository mmRepo;
  late MockSalesRepository salesRepo;

  ProviderContainer createContainer({
    required Completer<Either<Failure, List<MemberMembership>>> fetchCompleter,
  }) {
    mmRepo = MockMemberMembershipRepository();
    salesRepo = MockSalesRepository();

    when(
      () => mmRepo.fetchActive(
        any(),
        validAtBranchId: any(named: 'validAtBranchId'),
      ),
    ).thenAnswer((_) => fetchCompleter.future);

    return ProviderContainer(
      overrides: [
        memberMembershipRepositoryProvider.overrideWithValue(mmRepo),
        salesRepositoryProvider.overrideWithValue(salesRepo),
        effectiveBranchIdForWriteProvider.overrideWithValue('branch-1'),
      ],
    );
  }

  test(
    'does not use Ref after dispose when fetchActive is still pending',
    () async {
      final completer =
          Completer<Either<Failure, List<MemberMembership>>>();
      final container = createContainer(fetchCompleter: completer);
      addTearDown(container.dispose);
      Object? providerError;

      final subscription = container.listen(
        memberActiveMembershipProvider('member-1'),
        (_, __) {},
        onError: (error, _) => providerError = error,
      );

      // Let the provider start and hit the pending fetchActive await.
      await Future<void>.value();
      expect(completer.isCompleted, isFalse);

      // Drop the only listener so autoDispose disposes the provider mid-fetch.
      // Do not retain .future here — that would keep the provider alive.
      subscription.close();
      await Future<void>.value();

      completer.complete(right([buildMemberMembership()]));
      await Future<void>.value();
      await Future<void>.value();

      expect(
        providerError?.toString() ?? '',
        isNot(contains('after it has been disposed')),
      );
      expect(
        providerError,
        anyOf(isNull, isA<MemberActiveMembershipCancelled>()),
      );
    },
  );

  test('returns first eligible membership when still mounted', () async {
    final completer = Completer<Either<Failure, List<MemberMembership>>>();
    final container = createContainer(fetchCompleter: completer);
    addTearDown(container.dispose);

    final subscription = container.listen(
      memberActiveMembershipProvider('member-1'),
      (_, __) {},
    );
    addTearDown(subscription.close);

    final future = container.read(
      memberActiveMembershipProvider('member-1').future,
    );

    completer.complete(right([buildMemberMembership(id: 'mm-active')]));

    final membership = await future;
    expect(membership?.id, 'mm-active');
    verifyNever(() => salesRepo.getSale(any()));
  });
}
