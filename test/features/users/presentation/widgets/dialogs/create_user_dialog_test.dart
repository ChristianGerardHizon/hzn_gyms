import 'package:hzn_gyms/src/features/users/presentation/widgets/dialogs/create_user_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('userDetailLocationForCurrentPath', () {
    test('returns top-level users detail path', () {
      expect(
        userDetailLocationForCurrentPath('/users', 'user-1'),
        '/users/user-1',
      );
      expect(
        userDetailLocationForCurrentPath('/organization/users', 'user-1'),
        '/users/user-1',
      );
    });
  });
}
