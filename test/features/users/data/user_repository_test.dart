import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:hzn_gyms/src/core/packages/pocketbase/pocketbase_collections.dart';
import 'package:hzn_gyms/src/features/users/data/repositories/user_repository.dart';

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
}
