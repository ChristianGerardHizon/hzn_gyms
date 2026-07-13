import 'package:ebe_gym/src/features/users/presentation/widgets/dialogs/create_user_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('userDetailLocationForCurrentPath', () {
    test('uses organization user detail under /organization', () {
      expect(
        userDetailLocationForCurrentPath('/organization/users', 'user-1'),
        '/organization/users/user-1',
      );
      expect(
        userDetailLocationForCurrentPath(
          '/organization/users/other',
          'user-1',
        ),
        '/organization/users/user-1',
      );
    });

    test('uses users detail outside organization shell', () {
      expect(
        userDetailLocationForCurrentPath('/users', 'user-1'),
        '/users/user-1',
      );
      expect(
        userDetailLocationForCurrentPath('/users/roles', 'user-1'),
        '/users/user-1',
      );
    });
  });
}
