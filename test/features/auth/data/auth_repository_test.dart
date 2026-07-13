import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:ebe_gym/src/core/foundation/failure.dart';
import 'package:ebe_gym/src/core/packages/pocketbase/pocketbase_collections.dart';
import 'package:ebe_gym/src/core/packages/storage/auth_storage_provider.dart';
import 'package:ebe_gym/src/features/auth/data/auth_dto.dart';
import 'package:ebe_gym/src/features/auth/data/auth_repository.dart';

import '../../../helpers/pb_test_helpers.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockPocketBase pb;
  late MockRecordService users;
  late MockFlutterSecureStorage storage;
  late AuthStorageService authStorage;
  late AuthRepositoryImpl repo;

  AuthDto sampleAuth() => const AuthDto(
        token: 'tok',
        id: 'user-1',
        collectionId: 'c',
        collectionName: 'users',
        name: 'Cashier',
        username: 'cashier',
        email: 'c@test.com',
        verified: true,
        branch: 'branch-1',
      );

  setUp(() {
    pb = MockPocketBase();
    users = MockRecordService();
    storage = MockFlutterSecureStorage();
    when(() => pb.baseURL).thenReturn('http://pb.test');
    when(() => pb.authStore).thenReturn(AuthStore());
    stubCollection(pb, PocketBaseCollections.users, users);
    authStorage = AuthStorageService(storage);
    repo = AuthRepositoryImpl(pb: pb, authStorage: authStorage);
  });

  test('login saves auth and returns AuthState', () async {
    final auth = sampleAuth();
    when(
      () => users.authWithPassword(
        any(),
        any(),
        expand: any(named: 'expand'),
      ),
    ).thenAnswer(
      (_) async => RecordAuth(
        token: auth.token,
        record: auth.toRecordModel(),
      ),
    );
    when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});

    final result = await repo.login('cashier', 'secret');
    expect(result.isRight(), isTrue);
    expect(
      result.getOrElse((_) => throw StateError('l')).user.username,
      'cashier',
    );
    verify(
      () => storage.write(key: any(named: 'key'), value: any(named: 'value')),
    ).called(1);
  });

  test('logout clears store and storage', () async {
    when(() => storage.delete(key: any(named: 'key'))).thenAnswer((_) async {});
    pb.authStore.save('tok', null);

    final result = await repo.logout();
    expect(result.isRight(), isTrue);
    expect(pb.authStore.token, isEmpty);
    verify(() => storage.delete(key: any(named: 'key'))).called(1);
  });

  test('getCachedAuth restores from storage', () async {
    final auth = sampleAuth();
    when(() => storage.read(key: any(named: 'key'))).thenAnswer(
      (_) async => auth.toJson(),
    );

    final result = await repo.getCachedAuth();
    expect(result.isRight(), isTrue);
    expect(result.getOrElse((_) => throw StateError('l')).token, 'tok');
    expect(pb.authStore.token, 'tok');
  });

  test('getCachedAuth returns NoAuthFailure when empty', () async {
    when(() => storage.read(key: any(named: 'key'))).thenAnswer((_) async => null);
    final result = await repo.getCachedAuth();
    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<NoAuthFailure>()),
      (_) => fail('expected left'),
    );
  });

  test('requestPasswordReset delegates to collection', () async {
    when(() => users.requestPasswordReset(any())).thenAnswer((_) async {});
    expect((await repo.requestPasswordReset('a@b.com')).isRight(), isTrue);
    verify(() => users.requestPasswordReset('a@b.com')).called(1);
  });
}
