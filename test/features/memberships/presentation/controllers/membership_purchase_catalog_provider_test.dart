import 'dart:async';

import 'package:hzn_gyms/src/core/foundation/failure.dart';
import 'package:hzn_gyms/src/features/memberships/data/repositories/membership_repository.dart';
import 'package:hzn_gyms/src/features/memberships/presentation/controllers/membership_purchase_catalog_provider.dart';
import 'package:hzn_gyms/src/features/settings/presentation/controllers/current_branch_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockMembershipRepository repo;

  setUp(() {
    repo = MockMembershipRepository();
  });

  ProviderContainer createContainer({String? currentBranchId = 'branch-1'}) {
    return ProviderContainer(
      overrides: [
        membershipRepositoryProvider.overrideWithValue(repo),
        currentBranchIdProvider.overrideWithValue(currentBranchId),
      ],
    );
  }

  test('allBranches false fetches plans for current branch', () async {
    final branchPlans = [
      buildMembership(id: 'local-1', name: 'Bacolod Monthly'),
    ];
    when(
      () => repo.fetchAll(branchId: 'branch-1'),
    ).thenAnswer((_) async => right(branchPlans));

    final container = createContainer();
    addTearDown(container.dispose);

    final result = await container.read(
      membershipPurchaseCatalogProvider(false).future,
    );

    expect(result, branchPlans);
    verify(() => repo.fetchAll(branchId: 'branch-1')).called(1);
    verifyNever(() => repo.fetchAll(branchId: null));
  });

  test('allBranches true fetches unfiltered plans', () async {
    final allPlans = [
      buildMembership(id: 'local-1', name: 'Bacolod Monthly'),
      buildMembership(
        id: 'remote-1',
        name: 'Talisay Monthly',
        branchId: 'branch-2',
        validBranches: const ['branch-2'],
      ),
    ];
    when(
      () => repo.fetchAll(branchId: null),
    ).thenAnswer((_) async => right(allPlans));

    final container = createContainer();
    addTearDown(container.dispose);

    final result = await container.read(
      membershipPurchaseCatalogProvider(true).future,
    );

    expect(result, allPlans);
    verify(() => repo.fetchAll(branchId: null)).called(1);
    verifyNever(() => repo.fetchAll(branchId: 'branch-1'));
  });

  test('propagates repository failure', () async {
    when(
      () => repo.fetchAll(branchId: 'branch-1'),
    ).thenAnswer(
      (_) async => left(const GenericFailure('unavailable')),
    );

    final container = createContainer();
    addTearDown(container.dispose);

    final completer = Completer<Object?>();
    final sub = container.listen(
      membershipPurchaseCatalogProvider(false),
      (_, next) {
        if (next.hasError && !completer.isCompleted) {
          completer.complete(next.error);
        }
      },
      fireImmediately: true,
    );
    addTearDown(sub.close);

    final error = await completer.future.timeout(const Duration(seconds: 2));
    expect(error, isA<Failure>());
  });
}
