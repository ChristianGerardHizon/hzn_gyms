import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:hzn_gyms/src/core/foundation/failure.dart';
import 'package:hzn_gyms/src/core/packages/pocketbase/pocketbase_collections.dart';
import 'package:hzn_gyms/src/core/packages/storage/auth_storage_provider.dart';
import 'package:hzn_gyms/src/features/auth/data/auth_dto.dart';
import 'package:hzn_gyms/src/features/auth/data/auth_repository.dart';

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

    final result = await repo.login('c@test.com', 'secret');
    expect(result.isRight(), isTrue);
    expect(
      result.getOrElse((_) => throw StateError('l')).user.email,
      'c@test.com',
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

  test('requestVerification delegates to collection', () async {
    when(() => users.requestVerification(any())).thenAnswer((_) async {});
    expect((await repo.requestVerification('a@b.com')).isRight(), isTrue);
    verify(() => users.requestVerification('a@b.com')).called(1);
  });

  test('confirmVerification delegates to collection', () async {
    when(() => users.confirmVerification(any())).thenAnswer((_) async {});
    expect((await repo.confirmVerification('token-1')).isRight(), isTrue);
    verify(() => users.confirmVerification('token-1')).called(1);
  });

  test('loginWithGoogle saves auth when staff role is present', () async {
    final auth = sampleAuth().copyWith(role: 'role-1');
    when(
      () => users.authWithOAuth2(
        any(),
        any(),
        expand: any(named: 'expand'),
      ),
    ).thenAnswer((invocation) async {
      final callback = invocation.positionalArguments[1] as Function;
      await callback(Uri.parse('https://accounts.google.com/o/oauth2'));
      return RecordAuth(
        token: auth.token,
        record: auth.toRecordModel(),
      );
    });
    when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});

    final result = await repo.loginWithGoogle(
      openUrl: (_) async => true,
    );
    expect(result.isRight(), isTrue);
    expect(
      result.getOrElse((_) => throw StateError('l')).user.roleId,
      'role-1',
    );
    verify(
      () => storage.write(key: any(named: 'key'), value: any(named: 'value')),
    ).called(1);
  });

  test('loginWithGoogle fails when staff role is missing', () async {
    final auth = sampleAuth(); // no role
    when(
      () => users.authWithOAuth2(
        any(),
        any(),
        expand: any(named: 'expand'),
      ),
    ).thenAnswer((invocation) async {
      final callback = invocation.positionalArguments[1] as Function;
      await callback(Uri.parse('https://accounts.google.com/o/oauth2'));
      return RecordAuth(
        token: auth.token,
        record: auth.toRecordModel(),
      );
    });

    final result = await repo.loginWithGoogle(openUrl: (_) async => true);
    expect(result.isLeft(), isTrue);
    result.fold(
      (f) {
        expect(f, isA<AuthFailure>());
        expect(f.identifier, 'google_no_staff');
      },
      (_) => fail('expected left'),
    );
    expect(pb.authStore.token, isEmpty);
  });

  test('loginWithGoogle fails when URL cannot be opened', () async {
    when(
      () => users.authWithOAuth2(
        any(),
        any(),
        expand: any(named: 'expand'),
      ),
    ).thenAnswer((invocation) async {
      final callback = invocation.positionalArguments[1] as Function;
      await callback(Uri.parse('https://accounts.google.com/o/oauth2'));
      throw StateError('should not reach auth result');
    });

    final result = await repo.loginWithGoogle(openUrl: (_) async => false);
    expect(result.isLeft(), isTrue);
    result.fold(
      (f) {
        expect(f, isA<AuthFailure>());
        expect(f.identifier, 'google_launch_failed');
      },
      (_) => fail('expected left'),
    );
  });
}
