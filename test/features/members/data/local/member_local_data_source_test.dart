import 'package:flutter_test/flutter_test.dart';
import 'package:kylie_gym/src/core/database/app_database.dart';
import 'package:kylie_gym/src/core/sync/sync_status.dart';
import 'package:kylie_gym/src/features/members/data/dto/member_dto.dart';
import 'package:kylie_gym/src/features/members/data/local/member_local_data_source.dart';
import 'package:kylie_gym/src/features/members/domain/member.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late AppDatabase db;
  late MemberLocalDataSource local;

  setUp(() {
    db = createTestDatabase();
    local = MemberLocalDataSource(db, 'http://pb.test');
  });

  tearDown(() async {
    await db.close();
  });

  MemberDto dto({
    String id = 'm1',
    String name = 'Jane',
    String? branch,
    String? sex,
    String? photo,
  }) {
    return MemberDto(
      id: id,
      collectionId: 'c',
      collectionName: 'members',
      name: name,
      branch: branch,
      sex: sex,
      photo: photo,
      updated: '2024-01-01T00:00:00.000Z',
    );
  }

  test('upsertFromDtos then getMemberById builds photo URL', () async {
    await local.upsertFromDtos([dto(photo: 'a.jpg', sex: 'female')]);
    final member = await local.getMemberById('m1');
    expect(member, isNotNull);
    expect(member!.name, 'Jane');
    expect(member.sex, MemberSex.female);
    expect(
      member.photo,
      startsWith('http://pb.test/api/files/members/m1/a.jpg'),
    );
  });

  test('upsertFromDtos synced skips unsynced ids', () async {
    await local.upsertMembers(
      [const Member(id: 'm1', name: 'Local Edit')],
      syncStatus: SyncStatus.pending,
    );
    await local.upsertFromDtos([dto(name: 'Server Name')]);

    final member = await local.getMemberById('m1');
    expect(member!.name, 'Local Edit');
    expect(member.syncStatus, SyncStatus.pending);
  });

  test('pending local photo preferred over server file', () async {
    await local.upsertMembers(
      [const Member(id: 'm1', name: 'Jane')],
      syncStatus: SyncStatus.pending,
      localPhotoPath: '/tmp/local.jpg',
    );
    final member = await local.getMemberById('m1');
    expect(member!.photo, '/tmp/local.jpg');
  });

  test('replaceAllFromDtos preserves unsynced members', () async {
    await local.upsertMembers(
      [const Member(id: 'pending-1', name: 'Offline')],
      syncStatus: SyncStatus.pending,
    );
    await local.replaceAllFromDtos([
      dto(id: 'm2', name: 'Synced'),
    ]);

    expect(await local.getMemberById('pending-1'), isNotNull);
    expect(await local.getMemberById('m2'), isNotNull);
  });

  test('getPaginated and searchPaginated', () async {
    await local.upsertFromDtos([
      dto(id: 'a', name: 'Alice', branch: 'b1'),
      dto(id: 'b', name: 'Bob', branch: 'b1'),
      dto(id: 'c', name: 'Cara', branch: 'b2'),
    ]);

    final page = await local.getPaginated(page: 1, perPage: 2, branchId: 'b1');
    expect(page.items, hasLength(2));
    expect(page.totalItems, 2);
    expect(page.totalPages, 1);

    final search = await local.searchPaginated('Ali', branchId: 'b1');
    expect(search.items.map((m) => m.name), ['Alice']);
  });

  test('searchQuick returns matches without counting total rows', () async {
    await local.upsertFromDtos([
      dto(id: 'a', name: 'Alice'),
      dto(id: 'b', name: 'Alicia'),
      dto(id: 'c', name: 'Alex'),
    ]);

    final matches = await local.searchQuick('Ali', limit: 2);
    expect(matches, hasLength(2));
    expect(matches.map((m) => m.name), ['Alice', 'Alicia']);
  });

  test('searchPaginated matches tokenized names with irregular spacing',
      () async {
    await local.upsertFromDtos([
      dto(id: '1', name: 'CHLOE  SY'),
      dto(id: '2', name: 'Chloe Smith'),
      dto(id: '3', name: 'Sybil Jones'),
    ]);

    final byFullName = await local.searchPaginated('chloe sy');
    expect(byFullName.items.map((m) => m.id), ['1']);

    final byReversed = await local.searchPaginated('sy chloe');
    expect(byReversed.items.map((m) => m.id), ['1']);

    final byFirstOnly = await local.searchPaginated('chloe');
    expect(byFirstOnly.items.map((m) => m.id).toSet(), {'1', '2'});
  });

  test('clearSynced keeps pending; clearAll empties', () async {
    await local.upsertFromDtos([dto(id: 'synced', name: 'S')]);
    await local.upsertMembers(
      [const Member(id: 'pending', name: 'P')],
      syncStatus: SyncStatus.pending,
    );

    await local.clearSynced();
    expect(await local.getMemberById('synced'), isNull);
    expect(await local.getMemberById('pending'), isNotNull);

    await local.clearAll();
    expect(await local.hasCachedMembers(), isFalse);
  });
}
