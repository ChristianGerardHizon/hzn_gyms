import 'package:kylie_gym/src/core/database/app_database.dart';
import 'package:kylie_gym/src/core/packages/pocketbase/pocketbase_collections.dart';
import 'package:kylie_gym/src/core/sync/outbox_service.dart';
import 'package:kylie_gym/src/features/members/data/dto/member_dto.dart';
import 'package:kylie_gym/src/features/members/data/local/member_local_data_source.dart';
import 'package:kylie_gym/src/features/members/data/repositories/member_repository.dart';
import 'package:kylie_gym/src/features/members/presentation/controllers/member_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';
import '../../../../helpers/pb_test_helpers.dart';

void main() {
  const memberId = 'member-1';

  /// Lets the background revalidation and any resulting rebuild settle.
  Future<void> settle() async {
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  group('with stubbed collaborators', () {
    late MockMemberLocalDataSource local;
    late MockMemberRepository repo;
    late ProviderContainer container;

    final cachedMember = buildMember(id: memberId, name: 'Jane Doe');

    setUp(() {
      local = MockMemberLocalDataSource();
      repo = MockMemberRepository();

      container = ProviderContainer(
        overrides: [
          memberLocalDataSourceProvider.overrideWithValue(local),
          memberRepositoryProvider.overrideWithValue(repo),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('returns the cached member and revalidates only once', () async {
      when(
        () => local.getMemberById(memberId),
      ).thenAnswer((_) async => cachedMember);
      when(
        () => repo.fetchOne(memberId),
      ).thenAnswer((_) async => right(cachedMember));

      container.listen(memberProvider(memberId), (_, __) {});
      final result = await container.read(memberProvider(memberId).future);
      await settle();

      expect(result, cachedMember);
      verify(() => repo.fetchOne(memberId)).called(1);
    });

    test('rebuilds once when revalidation changes the cached member', () async {
      final updated = buildMember(id: memberId, name: 'Jane Smith');
      var revalidated = false;

      when(
        () => local.getMemberById(memberId),
      ).thenAnswer((_) async => revalidated ? updated : cachedMember);
      when(() => repo.fetchOne(memberId)).thenAnswer((_) async {
        revalidated = true;
        return right(updated);
      });

      container.listen(memberProvider(memberId), (_, __) {});
      await container.read(memberProvider(memberId).future);
      await settle();

      expect(container.read(memberProvider(memberId)).value, updated);
      verify(() => repo.fetchOne(memberId)).called(2);
    });

    test('falls back to the repository when nothing is cached', () async {
      when(() => local.getMemberById(memberId)).thenAnswer((_) async => null);
      when(
        () => repo.fetchOne(memberId),
      ).thenAnswer((_) async => right(cachedMember));

      final result = await container.read(memberProvider(memberId).future);
      await settle();

      expect(result, cachedMember);
      verify(() => repo.fetchOne(memberId)).called(1);
    });
  });

  // Guards the actual regression: the cached entity and the entity rebuilt
  // from a freshly fetched record must round-trip through Drift identically,
  // otherwise revalidation invalidates itself in an endless fetch loop.
  group('against the real Drift cache', () {
    late AppDatabase db;
    late MemberLocalDataSource local;
    late MockPocketBase pb;
    late MockRecordService members;
    late ProviderContainer container;

    RecordModel buildFullRecord({String name = 'Jane Doe'}) {
      return buildRecord(
        id: memberId,
        collectionName: PocketBaseCollections.members,
        data: {
          'name': name,
          'photo': 'avatar.jpg',
          'mobileNumber': '09171234567',
          'dateOfBirth': '1990-05-20 00:00:00.000Z',
          'sex': 'female',
          'branch': 'branch-1',
          'created': '2026-01-15 08:30:45.123Z',
          'updated': '2026-02-20 11:05:09.456Z',
        },
      );
    }

    setUp(() {
      db = createTestDatabase();
      local = MemberLocalDataSource(db, 'http://pb.test');
      pb = MockPocketBase();
      members = MockRecordService();
      when(() => pb.baseURL).thenReturn('http://pb.test');
      stubCollection(pb, PocketBaseCollections.members, members);

      final repo = MemberRepositoryImpl(
        pb: pb,
        localDataSource: local,
        outboxService: OutboxService(db),
        isOnline: () => true,
        hasAuth: () => true,
      );

      container = ProviderContainer(
        overrides: [
          memberLocalDataSourceProvider.overrideWithValue(local),
          memberRepositoryProvider.overrideWithValue(repo),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('unchanged record does not trigger a fetch loop', () async {
      final record = buildFullRecord();
      await local.upsertFromDtos([MemberDto.fromRecord(record)]);
      when(() => members.getOne(memberId)).thenAnswer((_) async => record);

      container.listen(memberProvider(memberId), (_, __) {});
      final result = await container.read(memberProvider(memberId).future);
      await settle();

      expect(result?.name, 'Jane Doe');
      verify(() => members.getOne(memberId)).called(1);
    });

    test('changed record refreshes then settles', () async {
      await local.upsertFromDtos([MemberDto.fromRecord(buildFullRecord())]);
      when(
        () => members.getOne(memberId),
      ).thenAnswer((_) async => buildFullRecord(name: 'Jane Smith'));

      container.listen(memberProvider(memberId), (_, __) {});
      await container.read(memberProvider(memberId).future);
      await settle();

      expect(container.read(memberProvider(memberId)).value?.name, 'Jane Smith');
      verify(() => members.getOne(memberId)).called(2);
    });
  });
}
