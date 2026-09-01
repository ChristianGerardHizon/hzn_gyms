import 'package:hzn_gyms/src/features/settings/domain/branch.dart';
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

  group('branchDetailValue', () {
    test('returns em dash for null or blank', () {
      expect(branchDetailValue(null), '—');
      expect(branchDetailValue(''), '—');
      expect(branchDetailValue('   '), '—');
    });

    test('returns trimmed value when present', () {
      expect(branchDetailValue('Main St'), 'Main St');
      expect(branchDetailValue('  9am-5pm  '), '9am-5pm');
    });
  });
}
