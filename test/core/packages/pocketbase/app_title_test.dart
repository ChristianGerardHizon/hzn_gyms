import 'package:flutter_test/flutter_test.dart';
import 'package:kylie_gym/src/core/packages/pocketbase/pocketbase_provider.dart';

void main() {
  group('appTitle', () {
    test('uses Kylie Gym branding for the current environment', () {
      expect(appTitle, contains('Kylie Gym'));
      expect(appTitle, isNot(contains('Ebe')));
    });
  });
}
