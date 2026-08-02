import 'dart:io';

import 'package:ebe_gym/src/core/constants/constants.dart';
import 'package:ebe_gym/src/core/database/app_database.dart';
import 'package:ebe_gym/src/core/foundation/failure.dart';
import 'package:ebe_gym/src/core/packages/pocketbase/pocketbase_collections.dart';
import 'package:ebe_gym/src/core/sync/outbox_service.dart';
import 'package:ebe_gym/src/core/sync/sync_status.dart';
import 'package:ebe_gym/src/features/members/data/local/member_local_data_source.dart';
import 'package:ebe_gym/src/features/members/data/repositories/member_repository.dart';
import 'package:ebe_gym/src/features/members/domain/member.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/pb_test_helpers.dart';

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.root);

  final Directory root;

  @override
  Future<String?> getApplicationDocumentsPath() async => root.path;
}

void main() {
  late AppDatabase db;
  late MemberLocalDataSource local;
  late MockPocketBase pb;
  late MockRecordService members;
  late OutboxService outbox;
  late bool online;
  late bool hasAuth;
  late Directory tempDir;

  /// Far-future JWT so offline writes can be allowed when needed.
  const validToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
      'eyJleHAiOjQ4MzgzODQwMDB9.'
      'signature';

  setUpAll(() {
    registerFallbackValue(<http.MultipartFile>[]);
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('member_repo_test_');
    PathProviderPlatform.instance = _FakePathProvider(tempDir);

    db = createTestDatabase();
    local = MemberLocalDataSource(db, 'http://pb.test');
    pb = MockPocketBase();
    members = MockRecordService();
    outbox = OutboxService(db);
    online = true;
    hasAuth = true;
    when(() => pb.baseURL).thenReturn('http://pb.test');
    when(() => pb.authStore).thenReturn(AuthStore()..save(validToken, null));
    stubCollection(pb, PocketBaseCollections.members, members);
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  MemberRepositoryImpl buildRepo() => MemberRepositoryImpl(
        pb: pb,
        localDataSource: local,
        outboxService: outbox,
        isOnline: () => online,
        hasAuth: () => hasAuth,
      );

  void stubGetFullList(List<RecordModel> records) {
    when(
      () => members.getFullList(
        filter: any(named: 'filter'),
        sort: any(named: 'sort'),
      ),
    ).thenAnswer((_) async => records);
  }

  void stubGetList(ResultList<RecordModel> result) {
    when(
      () => members.getList(
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
        filter: any(named: 'filter'),
        sort: any(named: 'sort'),
      ),
    ).thenAnswer((_) async => result);
  }

  group('fetchOne', () {
    test('empty id returns DataFailure', () async {
      final result = await buildRepo().fetchOne('');
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<DataFailure>()),
        (_) => fail('expected left'),
      );
    });

    test('offline returns cached member without calling PB', () async {
      online = false;
      await local.upsertMembers([
        const Member(id: 'm1', name: 'Cached'),
      ]);

      final result = await buildRepo().fetchOne('m1');
      expect(result.getOrElse((_) => throw StateError('l')).name, 'Cached');
      verifyNever(() => members.getOne(any()));
    });

    test('online fetches and upserts cache', () async {
      when(() => members.getOne('m1')).thenAnswer(
        (_) async => buildMemberRecord(id: 'm1', name: 'Remote'),
      );

      final result = await buildRepo().fetchOne('m1');
      expect(result.getOrElse((_) => throw StateError('l')).name, 'Remote');
      expect((await local.getMemberById('m1'))?.name, 'Remote');
    });

    test('network failure falls back to cache', () async {
      await local.upsertMembers([
        const Member(id: 'm1', name: 'Cached'),
      ]);
      when(() => members.getOne('m1')).thenThrow(Exception('network'));

      final result = await buildRepo().fetchOne('m1');
      expect(result.getOrElse((_) => throw StateError('l')).name, 'Cached');
    });

    test('network failure with no cache returns left', () async {
      when(() => members.getOne('m1')).thenThrow(Exception('network'));

      final result = await buildRepo().fetchOne('m1');
      expect(result.isLeft(), isTrue);
    });
  });

  group('fetchAll / syncAllMembers / invalidateCache', () {
    test('fetchAll replaces cache and returns local list', () async {
      stubGetFullList([buildMemberRecord(id: 'm1', name: 'Alice')]);

      final result = await buildRepo().fetchAll();
      final list = result.getOrElse((_) => throw StateError('l'));
      expect(list.single.name, 'Alice');
      expect((await local.getMemberById('m1'))?.name, 'Alice');
    });

    test('fetchAll preserves pending local members', () async {
      await local.upsertMembers(
        [const Member(id: 'pending-1', name: 'Offline')],
        syncStatus: SyncStatus.pending,
      );
      stubGetFullList([buildMemberRecord(id: 'm1', name: 'Alice')]);

      final result = await buildRepo().fetchAll();
      final names =
          result.getOrElse((_) => throw StateError('l')).map((m) => m.name);
      expect(names, containsAll(['Alice', 'Offline']));
    });

    test('syncAllMembers replaces cache from PB', () async {
      stubGetFullList([buildMemberRecord(id: 'm2', name: 'FromServer')]);

      final result = await buildRepo().syncAllMembers();
      expect(result.isRight(), isTrue);
      expect((await local.getMemberById('m2'))?.name, 'FromServer');
    });

    test('invalidateCache clears synced members only', () async {
      await local.upsertMembers([
        const Member(id: 'synced', name: 'S'),
      ]);
      await local.upsertMembers(
        [const Member(id: 'pending', name: 'P')],
        syncStatus: SyncStatus.pending,
      );

      await buildRepo().invalidateCache();
      expect(await local.getMemberById('synced'), isNull);
      expect(await local.getMemberById('pending'), isNotNull);
    });
  });

  group('create / createWithPhoto', () {
    test('online create writes body with client id and caches synced', () async {
      when(
        () => members.create(
          body: any(named: 'body'),
          files: any(named: 'files'),
        ),
      ).thenAnswer((invocation) async {
        final body = invocation.namedArguments[#body] as Map<String, dynamic>;
        expect(body['id'], isNotEmpty);
        expect(body['name'], 'New Member');
        expect(body['addedBy'], 'user-1');
        return buildMemberRecord(id: body['id'] as String, name: 'New Member');
      });

      final result = await buildRepo().create(
        const Member(id: '', name: 'New Member', addedBy: 'user-1'),
      );
      final created = result.getOrElse((_) => throw StateError('l'));
      expect(created.name, 'New Member');
      expect(created.id, isNotEmpty);
      expect(
        (await local.getMemberById(created.id))?.syncStatus,
        SyncStatus.synced,
      );
      expect(await db.outboxDao.getPendingAndFailed(), isEmpty);
    });

    test('online createWithPhoto passes file to PB', () async {
      final photo = http.MultipartFile.fromBytes(
        'photo',
        [1, 2, 3],
        filename: 'face.jpg',
      );
      when(
        () => members.create(
          body: any(named: 'body'),
          files: any(named: 'files'),
        ),
      ).thenAnswer((invocation) async {
        final files =
            invocation.namedArguments[#files] as List<http.MultipartFile>;
        expect(files, hasLength(1));
        expect(files.single.filename, 'face.jpg');
        return buildMemberRecord(id: 'm-photo', name: 'With Photo');
      });

      final result = await buildRepo().createWithPhoto(
        const Member(id: 'm-photo', name: 'With Photo'),
        photo: photo,
      );
      expect(result.isRight(), isTrue);
    });

    test('offline create queues outbox and stores pending member', () async {
      online = false;

      final result = await buildRepo().create(
        const Member(
          id: '',
          name: 'Offline Member',
          mobileNumber: '0917',
          branch: 'branch-1',
        ),
      );
      final created = result.getOrElse((_) => throw StateError('l'));
      expect(created.syncStatus, SyncStatus.pending);
      expect(created.id, isNotEmpty);
      expect(
        (await local.getMemberById(created.id))?.syncStatus,
        SyncStatus.pending,
      );

      final pending = await db.outboxDao.getPendingAndFailed();
      expect(pending, hasLength(1));
      expect(pending.single.entityType, OutboxEntityType.member.value);
      expect(pending.single.operation, OutboxOperation.create.value);
      expect(pending.single.clientRecordId, created.id);
      verifyNever(
        () => members.create(
          body: any(named: 'body'),
          files: any(named: 'files'),
        ),
      );
    });

    test('offline createWithPhoto saves local photo and attachment', () async {
      online = false;
      final photo = http.MultipartFile.fromBytes(
        'photo',
        [9, 8, 7],
        filename: 'offline.jpg',
      );

      final result = await buildRepo().createWithPhoto(
        const Member(id: 'offline-photo', name: 'Offline Photo'),
        photo: photo,
      );
      final created = result.getOrElse((_) => throw StateError('l'));
      expect(created.photo, contains('offline-photo-offline.jpg'));
      expect(File(created.photo!).existsSync(), isTrue);

      final pending = await db.outboxDao.getPendingAndFailed();
      expect(pending, hasLength(1));
      final attachment =
          await db.outboxDao.getAttachment(pending.single.id);
      expect(attachment, isNotNull);
      expect(attachment!.filename, 'offline.jpg');
    });

    test('network failure while online queues create when auth allows', () async {
      when(
        () => members.create(
          body: any(named: 'body'),
          files: any(named: 'files'),
        ),
      ).thenThrow(Exception('network unreachable'));

      final result = await buildRepo().create(
        const Member(id: 'm-net', name: 'Queued After Fail'),
      );
      final created = result.getOrElse((_) => throw StateError('l'));
      expect(created.syncStatus, SyncStatus.pending);
      expect(await db.outboxDao.getPendingAndFailed(), hasLength(1));
    });

    test('non-network create failure returns left', () async {
      when(
        () => members.create(
          body: any(named: 'body'),
          files: any(named: 'files'),
        ),
      ).thenThrow(
        ClientException(
          url: Uri.parse('http://pb.test'),
          statusCode: 400,
          response: const {'message': 'validation failed'},
        ),
      );

      final result = await buildRepo().create(
        const Member(id: 'm-bad', name: 'Bad'),
      );
      expect(result.isLeft(), isTrue);
      expect(await db.outboxDao.getPendingAndFailed(), isEmpty);
    });
  });

  group('update', () {
    test('online update omits addedBy and caches synced', () async {
      when(
        () => members.update(
          'm1',
          body: any(named: 'body'),
        ),
      ).thenAnswer((invocation) async {
        final body = invocation.namedArguments[#body] as Map<String, dynamic>;
        expect(body.containsKey('addedBy'), isFalse);
        expect(body['name'], 'Updated');
        return buildMemberRecord(id: 'm1', name: 'Updated');
      });

      final result = await buildRepo().update(
        const Member(id: 'm1', name: 'Updated', addedBy: 'user-1'),
      );
      expect(result.getOrElse((_) => throw StateError('l')).name, 'Updated');
      expect(
        (await local.getMemberById('m1'))?.syncStatus,
        SyncStatus.synced,
      );
    });

    test('offline update queues outbox entry', () async {
      online = false;
      await local.upsertMembers([
        const Member(id: 'm1', name: 'Old'),
      ]);

      final result = await buildRepo().update(
        const Member(id: 'm1', name: 'New Name', mobileNumber: '0999'),
      );
      final updated = result.getOrElse((_) => throw StateError('l'));
      expect(updated.syncStatus, SyncStatus.pending);
      expect(updated.name, 'New Name');

      final pending = await db.outboxDao.getPendingAndFailed();
      expect(pending, hasLength(1));
      expect(pending.single.operation, OutboxOperation.update.value);
      verifyNever(
        () => members.update(any(), body: any(named: 'body')),
      );
    });

    test('network failure while online queues update', () async {
      when(
        () => members.update(any(), body: any(named: 'body')),
      ).thenThrow(Exception('connection timed out'));

      final result = await buildRepo().update(
        const Member(id: 'm1', name: 'Retry Offline'),
      );
      expect(
        result.getOrElse((_) => throw StateError('l')).syncStatus,
        SyncStatus.pending,
      );
      expect(await db.outboxDao.getPendingAndFailed(), hasLength(1));
    });
  });

  group('delete', () {
    test('deletes from PB and local cache', () async {
      await local.upsertMembers([
        const Member(id: 'm1', name: 'Gone'),
      ]);
      when(() => members.delete('m1')).thenAnswer((_) async {});

      final result = await buildRepo().delete('m1');
      expect(result.isRight(), isTrue);
      expect(await local.getMemberById('m1'), isNull);
      verify(() => members.delete('m1')).called(1);
    });

    test('PB failure returns left and keeps cache', () async {
      await local.upsertMembers([
        const Member(id: 'm1', name: 'Stay'),
      ]);
      when(() => members.delete('m1')).thenThrow(Exception('server'));

      final result = await buildRepo().delete('m1');
      expect(result.isLeft(), isTrue);
      expect(await local.getMemberById('m1'), isNotNull);
    });
  });

  group('search', () {
    test('builds name/mobile filter and upserts results', () async {
      when(
        () => members.getFullList(
          filter: any(named: 'filter'),
          sort: any(named: 'sort'),
        ),
      ).thenAnswer((invocation) async {
        final filter = invocation.namedArguments[#filter] as String;
        expect(filter, contains("name ~ 'Jane'"));
        expect(filter, contains("mobileNumber ~ 'Jane'"));
        expect(invocation.namedArguments[#sort], 'name');
        return [buildMemberRecord(id: 'm1', name: 'Jane')];
      });

      final result = await buildRepo().search('Jane');
      expect(result.getOrElse((_) => throw StateError('l')).single.name, 'Jane');
      expect(await local.getMemberById('m1'), isNotNull);
    });

    test('uses custom search fields', () async {
      when(
        () => members.getFullList(
          filter: any(named: 'filter'),
          sort: any(named: 'sort'),
        ),
      ).thenAnswer((invocation) async {
        final filter = invocation.namedArguments[#filter] as String;
        expect(filter, contains("email ~ 'a@b.com'"));
        expect(filter, isNot(contains('mobileNumber')));
        return [];
      });

      final result = await buildRepo().search(
        'a@b.com',
        fields: ['email'],
      );
      expect(result.isRight(), isTrue);
    });
  });

  group('searchQuick', () {
    test('returns cached matches immediately when offline', () async {
      online = false;
      await local.upsertMembers([
        const Member(id: 'm1', name: 'Jane Doe'),
      ]);

      final result = await buildRepo().searchQuick('Jane');
      expect(result.getOrElse((_) => throw StateError('l')).single.name, 'Jane Doe');
      verifyNever(
        () => members.getList(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
          filter: any(named: 'filter'),
          sort: any(named: 'sort'),
        ),
      );
    });

    test('uses capped server page and falls back to cache on empty server result',
        () async {
      await local.upsertMembers([
        const Member(id: 'm1', name: 'Jane Cached'),
      ]);

      when(
        () => members.getList(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
          filter: any(named: 'filter'),
          sort: any(named: 'sort'),
        ),
      ).thenAnswer((invocation) async {
        expect(invocation.namedArguments[#page], 1);
        expect(invocation.namedArguments[#perPage], Pagination.memberPickerSearchLimit);
        return ResultList<RecordModel>(
          page: 1,
          perPage: Pagination.memberPickerSearchLimit,
          totalItems: 0,
          totalPages: 0,
          items: [],
        );
      });

      final result = await buildRepo().searchQuick('Jane');
      expect(
        result.getOrElse((_) => throw StateError('l')).single.name,
        'Jane Cached',
      );
    });

    test('prefers server matches when online', () async {
      when(
        () => members.getList(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
          filter: any(named: 'filter'),
          sort: any(named: 'sort'),
        ),
      ).thenAnswer(
        (_) async => ResultList<RecordModel>(
          page: 1,
          perPage: Pagination.memberPickerSearchLimit,
          totalItems: 1,
          totalPages: 1,
          items: [buildMemberRecord(id: 'm2', name: 'Jane Server')],
        ),
      );

      final result = await buildRepo().searchQuick('Jane');
      expect(
        result.getOrElse((_) => throw StateError('l')).single.name,
        'Jane Server',
      );
    });
  });

  group('updatePhoto', () {
    test('online updatePhoto syncs cache', () async {
      final file = http.MultipartFile.fromBytes(
        'photo',
        [1, 2],
        filename: 'new.jpg',
      );
      when(
        () => members.update(
          'm1',
          files: any(named: 'files'),
        ),
      ).thenAnswer(
        (_) async => buildMemberRecord(id: 'm1', name: 'Jane', photo: 'new.jpg'),
      );

      final result = await buildRepo().updatePhoto('m1', file);
      expect(result.isRight(), isTrue);
      expect(
        (await local.getMemberById('m1'))?.syncStatus,
        SyncStatus.synced,
      );
    });

    test('offline updatePhoto queues when member is cached', () async {
      online = false;
      await local.upsertMembers([
        const Member(id: 'm1', name: 'Jane'),
      ]);
      final file = http.MultipartFile.fromBytes(
        'photo',
        [4, 5, 6],
        filename: 'queued.jpg',
      );

      final result = await buildRepo().updatePhoto('m1', file);
      final updated = result.getOrElse((_) => throw StateError('l'));
      expect(updated.syncStatus, SyncStatus.pending);
      expect(updated.photo, contains('m1-queued.jpg'));

      final pending = await db.outboxDao.getPendingAndFailed();
      expect(pending, hasLength(1));
      expect(pending.single.operation, OutboxOperation.update.value);
    });

    test('offline updatePhoto fails when member missing from cache', () async {
      online = false;
      final file = http.MultipartFile.fromBytes(
        'photo',
        [1],
        filename: 'missing.jpg',
      );

      final result = await buildRepo().updatePhoto('unknown', file);
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<DataFailure>()),
        (_) => fail('expected left'),
      );
    });
  });

  group('pagination', () {
    test('fetchPaginated maps ResultList and upserts items', () async {
      stubGetList(
        ResultList<RecordModel>(
          page: 2,
          perPage: 10,
          totalItems: 25,
          totalPages: 3,
          items: [buildMemberRecord(id: 'm1', name: 'Paged')],
        ),
      );

      final result = await buildRepo().fetchPaginated(page: 2, perPage: 10);
      final page = result.getOrElse((_) => throw StateError('l'));
      expect(page.page, 2);
      expect(page.totalItems, 25);
      expect(page.totalPages, 3);
      expect(page.items.single.name, 'Paged');
      expect(await local.getMemberById('m1'), isNotNull);
    });

    test('searchPaginated combines search and extra filter', () async {
      when(
        () => members.getList(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
          filter: any(named: 'filter'),
          sort: any(named: 'sort'),
        ),
      ).thenAnswer((invocation) async {
        final filter = invocation.namedArguments[#filter] as String;
        expect(filter, contains("name ~ 'Jo'"));
        expect(filter, contains('&&'));
        expect(filter, contains("branch = 'b1'"));
        return ResultList<RecordModel>(
          page: 1,
          perPage: 20,
          totalItems: 1,
          totalPages: 1,
          items: [buildMemberRecord(id: 'm1', name: 'Jo')],
        );
      });

      final result = await buildRepo().searchPaginated(
        'Jo',
        filter: "branch = 'b1'",
      );
      expect(result.getOrElse((_) => throw StateError('l')).items.single.name, 'Jo');
    });
  });
}
