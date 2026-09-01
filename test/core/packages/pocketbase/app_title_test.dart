import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/core/packages/pocketbase/pocketbase_provider.dart';

void main() {
  group('appTitle', () {
    test('uses HZN Gyms branding for the current environment', () {
      expect(appTitle, contains('HZN Gyms'));
      expect(appTitle, isNot(contains('Kylie')));
    });
  });
}
