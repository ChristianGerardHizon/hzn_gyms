import 'package:ebe_gym/src/features/pos/domain/sale.dart';
import 'package:ebe_gym/src/features/sales/domain/open_unpaid_sale.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('normalizeCustomerName', () {
    test('trims lowercases and collapses whitespace', () {
      expect(normalizeCustomerName('  Jeff  17. '), 'jeff 17');
    });

    test('null/empty becomes empty', () {
      expect(normalizeCustomerName(null), '');
      expect(normalizeCustomerName('   '), '');
    });
  });

  group('isOpenUnpaidSaleStatus', () {
    test('recognizes awaitingPayment and pending', () {
      expect(isOpenUnpaidSaleStatus('awaitingPayment'), isTrue);
      expect(isOpenUnpaidSaleStatus('pending'), isTrue);
      expect(isOpenUnpaidSaleStatus('AwaitingPayment'), isTrue);
    });

    test('rejects paid and voided', () {
      expect(isOpenUnpaidSaleStatus('paid'), isFalse);
      expect(isOpenUnpaidSaleStatus('voided'), isFalse);
      expect(isOpenUnpaidSaleStatus(null), isFalse);
    });
  });

  group('findMatchingOpenUnpaidSales', () {
    final unpaidMember = buildSale(
      id: 's1',
      status: 'awaitingPayment',
      isPaid: false,
    ).copyWith(customerId: 'm1', customerName: 'Nelson', branchId: 'b1');

    final unpaidWalkIn = buildSale(
      id: 's2',
      status: 'pending',
      isPaid: false,
    ).copyWith(customerName: 'JEFF 17', branchId: 'b1');

    final paid = buildSale(
      id: 's3',
      status: 'paid',
      isPaid: true,
    ).copyWith(customerId: 'm1', customerName: 'Nelson', branchId: 'b1');

    final voided = buildSale(
      id: 's4',
      status: 'voided',
      isPaid: false,
    ).copyWith(customerName: 'JEFF 17', branchId: 'b1');

    test('matches same member unpaid only', () {
      final matches = findMatchingOpenUnpaidSales(
        sales: [unpaidMember, unpaidWalkIn, paid, voided],
        memberId: 'm1',
        branchId: 'b1',
      );
      expect(matches.map((s) => s.id), ['s1']);
    });

    test('matches walk-in name case-insensitively', () {
      final matches = findMatchingOpenUnpaidSales(
        sales: [unpaidMember, unpaidWalkIn, paid, voided],
        customerName: 'jeff 17',
        branchId: 'b1',
      );
      expect(matches.map((s) => s.id), ['s2']);
    });

    test('ignores generic Walk-in label', () {
      final generic = buildSale(
        id: 's5',
        status: 'pending',
        isPaid: false,
      ).copyWith(customerName: Sale.walkInLabel, branchId: 'b1');
      final matches = findMatchingOpenUnpaidSales(
        sales: [generic],
        customerName: Sale.walkInLabel,
        branchId: 'b1',
      );
      expect(matches, isEmpty);
    });
  });
}
