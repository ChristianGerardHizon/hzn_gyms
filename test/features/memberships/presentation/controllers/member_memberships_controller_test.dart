import 'package:ebe_gym/src/core/database/app_database.dart';
import 'package:ebe_gym/src/core/database/database_provider.dart';
import 'package:ebe_gym/src/core/foundation/failure.dart';
import 'package:ebe_gym/src/features/memberships/data/repositories/member_membership_repository.dart';
import 'package:ebe_gym/src/features/memberships/domain/member_membership.dart';
import 'package:ebe_gym/src/features/memberships/presentation/controllers/member_memberships_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockMemberMembershipRepository repo;
  late ProviderContainer container;
  late AppDatabase db;

  const memberId = 'member-1';

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    repo = MockMemberMembershipRepository();
    db = createTestDatabase();
    when(() => repo.invalidateCache()).thenReturn(null);
    when(() => repo.fetchByMember(memberId)).thenAnswer(
      (_) async => right(<MemberMembership>[]),
    );

    container = ProviderContainer(
      overrides: [
        memberMembershipRepositoryProvider.overrideWithValue(repo),
        appDatabaseProvider.overrideWithValue(db),
      ],
    );
    // Keep autoDispose provider alive across async refresh.
    container.listen(
      memberMembershipsControllerProvider(memberId),
      (_, __) {},
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<MemberMembershipsController> readyController() async {
    await container.read(memberMembershipsControllerProvider(memberId).future);
    return container.read(
      memberMembershipsControllerProvider(memberId).notifier,
    );
  }

  group('updateMembershipDates', () {
    test('returns null and refreshes on success', () async {
      final updated = buildMemberMembership(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 2, 1),
      );
      when(
        () => repo.update(
          'mm-1',
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => right(updated));
      when(() => repo.fetchByMember(memberId)).thenAnswer(
        (_) async => right([updated]),
      );

      final controller = await readyController();
      final error = await controller.updateMembershipDates(
        'mm-1',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 2, 1),
      );

      expect(error, isNull);
      verify(
        () => repo.update(
          'mm-1',
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 2, 1),
        ),
      ).called(1);
      final list = container.read(memberMembershipsControllerProvider(memberId));
      expect(list.value, [updated]);
    });

    test('returns failure message on error', () async {
      when(
        () => repo.update(
          any(),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer(
        (_) async => left(const DataFailure('update failed')),
      );

      final controller = await readyController();
      final error = await controller.updateMembershipDates(
        'mm-1',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 2, 1),
      );

      expect(error, 'update failed');
    });
  });

  group('cancelMembership', () {
    test('returns null and refreshes on success', () async {
      final cancelled = buildMemberMembership(
        status: MemberMembershipStatus.cancelled,
      );
      when(() => repo.cancel('mm-1')).thenAnswer((_) async => right(cancelled));
      when(() => repo.fetchByMember(memberId)).thenAnswer(
        (_) async => right([cancelled]),
      );

      final controller = await readyController();
      final error = await controller.cancelMembership('mm-1');

      expect(error, isNull);
      verify(() => repo.cancel('mm-1')).called(1);
      final list = container.read(memberMembershipsControllerProvider(memberId));
      expect(list.value?.single.status, MemberMembershipStatus.cancelled);
    });

    test('returns failure message on error', () async {
      when(() => repo.cancel(any())).thenAnswer(
        (_) async => left(const DataFailure('cancel failed')),
      );

      final controller = await readyController();
      final error = await controller.cancelMembership('mm-1');

      expect(error, 'cancel failed');
    });
  });
}
