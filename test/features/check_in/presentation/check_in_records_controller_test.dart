import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kylie_gym/src/core/foundation/failure.dart';
import 'package:kylie_gym/src/features/check_in/data/repositories/check_in_repository.dart';
import 'package:kylie_gym/src/features/check_in/domain/check_in.dart';
import 'package:kylie_gym/src/features/check_in/presentation/controllers/check_in_records_controller.dart';
import 'package:kylie_gym/src/features/check_in/presentation/controllers/check_in_records_date_controller.dart';
import 'package:kylie_gym/src/features/settings/presentation/controllers/current_branch_controller.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2024));
  });

  late MockCheckInRepository checkInRepo;

  ProviderContainer createContainer({
    String? branchId = 'branch-1',
    List<CheckIn>? checkIns,
    Failure? failure,
  }) {
    checkInRepo = MockCheckInRepository();

    when(
      () => checkInRepo.fetchByDate(
        date: any(named: 'date'),
        branchId: any(named: 'branchId'),
      ),
    ).thenAnswer((_) async {
      if (failure != null) return left(failure);
      return right(checkIns ?? <CheckIn>[]);
    });

    return ProviderContainer(
      overrides: [
        checkInRepositoryProvider.overrideWithValue(checkInRepo),
        currentBranchIdProvider.overrideWithValue(branchId),
      ],
    );
  }

  test('loads check-ins for selected date and branch', () async {
    final checkIns = [
      buildCheckIn(id: 'ci-1', memberName: 'Ada'),
      buildCheckIn(id: 'ci-2', memberName: 'Bob'),
    ];
    final container = createContainer(checkIns: checkIns);
    addTearDown(container.dispose);

    final selected = DateTime(2024, 6, 15);
    container
        .read(checkInRecordsDateControllerProvider.notifier)
        .setDate(selected);

    final result = await container.read(
      checkInRecordsControllerProvider.future,
    );

    expect(result, checkIns);
    verify(
      () => checkInRepo.fetchByDate(date: selected, branchId: 'branch-1'),
    ).called(1);
  });

  test('exposes error state when repository fails', () async {
    final container = createContainer(failure: const GenericFailure('network'));
    addTearDown(container.dispose);

    final completer = Completer<Object?>();
    final sub = container.listen(checkInRecordsControllerProvider, (
      previous,
      next,
    ) {
      if (next.hasError) completer.complete(next.error);
    }, fireImmediately: true);
    addTearDown(sub.close);

    final error = await completer.future.timeout(const Duration(seconds: 2));
    expect(error, isA<Failure>());
  });

  test('refetches when date changes', () async {
    final container = createContainer(checkIns: [buildCheckIn(id: 'ci-1')]);
    addTearDown(container.dispose);

    await container.read(checkInRecordsControllerProvider.future);

    container
        .read(checkInRecordsDateControllerProvider.notifier)
        .setDate(DateTime(2024, 1, 1));

    await container.read(checkInRecordsControllerProvider.future);

    verify(
      () => checkInRepo.fetchByDate(
        date: any(named: 'date'),
        branchId: any(named: 'branchId'),
      ),
    ).called(greaterThanOrEqualTo(2));
  });
}
