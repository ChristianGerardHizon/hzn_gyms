import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:hzn_gyms/src/core/packages/pocketbase/pocketbase_collections.dart';
import 'package:hzn_gyms/src/features/users/data/repositories/user_repository.dart';
import 'package:hzn_gyms/src/features/users/domain/user.dart';

import '../../../helpers/pb_test_helpers.dart';

void main() {
  late MockPocketBase pb;
  late MockRecordService users;
  late UserRepositoryImpl repo;

  setUp(() {
    pb = MockPocketBase();
    users = MockRecordService();
    when(() => pb.baseURL).thenReturn('http://pb.test');
    stubCollection(pb, PocketBaseCollections.users, users);
    repo = UserRepositoryImpl(pb);
  });

  test('changePassword sends oldPassword, password, and passwordConfirm',
      () async {
    when(
      () => users.update('user-1', body: any(named: 'body')),
    ).thenAnswer(
      (_) async => buildRecord(id: 'user-1', collectionName: 'users'),
    );

    final result = await repo.changePassword(
      userId: 'user-1',
      oldPassword: 'old-secret',
      newPassword: 'new-secret',
    );

    expect(result.isRight(), isTrue);

    final body = verify(
      () => users.update('user-1', body: captureAny(named: 'body')),
    ).captured.single as Map<String, dynamic>;

    expect(body['oldPassword'], 'old-secret');
    expect(body['password'], 'new-secret');
    expect(body['passwordConfirm'], 'new-secret');
  });

  test('changePassword maps ClientException to Failure', () async {
    when(
      () => users.update('user-1', body: any(named: 'body')),
    ).thenThrow(
      ClientException(
        url: Uri.parse('http://pb.test'),
        statusCode: 400,
        response: {
          'message': 'Failed to authenticate.',
          'data': {
            'oldPassword': {
              'code': 'validation_invalid_old_password',
              'message': 'Wrong old password.',
            },
          },
        },
      ),
    );

    final result = await repo.changePassword(
      userId: 'user-1',
      oldPassword: 'wrong',
      newPassword: 'new-secret',
    );

    expect(result.isLeft(), isTrue);
  });

  test('create sends email and organization fields', () async {
    when(
      () => users.create(body: any(named: 'body'), expand: any(named: 'expand')),
    ).thenAnswer(
      (_) async => buildRecord(
        id: 'user-1',
        collectionName: 'users',
        data: {
          'name': 'Admin',
          'email': 'admin@example.com',
          'organization': 'org-1',
          'role': 'role-admin',
          'branch': 'branch-1',
        },
      ),
    );

    final result = await repo.create(
      const User(
        id: '',
        name: 'Admin',
        email: 'admin@example.com',
        organizationId: 'org-1',
        roleId: 'role-admin',
        branchId: 'branch-1',
      ),
      'secret123',
    );

    expect(result.isRight(), isTrue);

    final body = verify(
      () => users.create(body: captureAny(named: 'body'), expand: any(named: 'expand')),
    ).captured.single as Map<String, dynamic>;

    expect(body['email'], 'admin@example.com');
    expect(body['organization'], 'org-1');
    expect(body['password'], 'secret123');
    expect(body.containsKey('username'), isFalse);
  });

  test('update sends verified and omits username', () async {
    when(
      () => users.update(
        any(),
        body: any(named: 'body'),
        expand: any(named: 'expand'),
      ),
    ).thenAnswer(
      (_) async => buildRecord(
        id: 'user-1',
        collectionName: 'users',
        data: {
          'name': 'Admin',
          'email': 'admin@example.com',
          'verified': true,
        },
      ),
    );

    final result = await repo.update(
      const User(
        id: 'user-1',
        name: 'Admin',
        email: 'admin@example.com',
        verified: true,
        roleId: 'role-admin',
        branchId: 'branch-1',
      ),
    );

    expect(result.isRight(), isTrue);
    final body = verify(
      () => users.update(
        'user-1',
        body: captureAny(named: 'body'),
        expand: any(named: 'expand'),
      ),
    ).captured.single as Map<String, dynamic>;

    expect(body['verified'], isTrue);
    expect(body['name'], 'Admin');
    expect(body.containsKey('username'), isFalse);
  });
}
