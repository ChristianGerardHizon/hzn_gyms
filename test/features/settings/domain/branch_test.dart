import 'package:ebe_gym/src/features/settings/domain/branch.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Branch.pillLabel', () {
    test('uses uppercase code', () {
      const branch = Branch(
        id: '1',
        name: 'Bacolod Branch',
        code: 'bcd',
        address: 'x',
        contactNumber: '1',
      );
      expect(branch.pillLabel, 'BCD');
    });

    test('falls back by stripping Branch and truncating', () {
      const branch = Branch(
        id: '1',
        name: 'Bacolod Branch',
        code: '',
        address: 'x',
        contactNumber: '1',
      );
      expect(branch.pillLabel, 'BACOL');
    });
  });
}
