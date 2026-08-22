import 'package:kylie_gym/src/features/pos/domain/product_sale_line.dart';
import 'package:kylie_gym/src/features/products/domain/product_sales_by_date.dart';
import 'package:flutter_test/flutter_test.dart';

ProductSaleLine _line({
  required String id,
  required DateTime? created,
  num quantity = 1,
  num subtotal = 10,
  String status = 'completed',
}) {
  return ProductSaleLine(
    saleItemId: id,
    saleId: 'sale-$id',
    receiptNumber: 'R-$id',
    quantity: quantity,
    unitPrice: subtotal / quantity,
    subtotal: subtotal,
    isPaid: status == 'completed' || status == 'paid',
    status: status,
    created: created,
  );
}

void main() {
  group('groupProductSalesByDate', () {
    test('returns empty for empty input', () {
      expect(groupProductSalesByDate(const []), isEmpty);
    });

    test('groups by local calendar day, newest day first', () {
      final day1 = DateTime(2026, 8, 10, 14, 0);
      final day1Earlier = DateTime(2026, 8, 10, 9, 0);
      final day2 = DateTime(2026, 8, 9, 18, 0);
      final day3 = DateTime(2026, 8, 8, 12, 0);

      // Newest-first source order (as from repository).
      final lines = [
        _line(id: 'a', created: day1),
        _line(id: 'b', created: day1Earlier),
        _line(id: 'c', created: day2),
        _line(id: 'd', created: day3),
      ];

      final groups = groupProductSalesByDate(lines);

      expect(groups, hasLength(3));
      expect(groups[0].date, DateTime(2026, 8, 10));
      expect(groups[0].lines.map((l) => l.saleItemId), ['a', 'b']);
      expect(groups[1].date, DateTime(2026, 8, 9));
      expect(groups[1].lines.map((l) => l.saleItemId), ['c']);
      expect(groups[2].date, DateTime(2026, 8, 8));
      expect(groups[2].lines.map((l) => l.saleItemId), ['d']);
    });

    test('day totals exclude voided/pending lines', () {
      final day = DateTime(2026, 8, 10, 12);
      final lines = [
        _line(id: 'ok', created: day, quantity: 2, subtotal: 40),
        _line(
          id: 'void',
          created: day,
          quantity: 5,
          subtotal: 100,
          status: 'voided',
        ),
        _line(
          id: 'pending',
          created: day,
          quantity: 3,
          subtotal: 30,
          status: 'pending',
        ),
      ];

      final group = groupProductSalesByDate(lines).single;
      expect(group.totalQty, 2);
      expect(group.totalRevenue, 40);
    });

    test('null created lines go in trailing unknown group', () {
      final dated = DateTime(2026, 8, 10, 12);
      final lines = [
        _line(id: 'known', created: dated),
        _line(id: 'unknown', created: null),
      ];

      final groups = groupProductSalesByDate(lines);
      expect(groups, hasLength(2));
      expect(groups[0].date, DateTime(2026, 8, 10));
      expect(groups[0].lines.single.saleItemId, 'known');
      expect(groups[1].date, isNull);
      expect(groups[1].lines.single.saleItemId, 'unknown');
    });
  });

  group('todaysProductSalesSummary', () {
    final now = DateTime(2026, 8, 10, 15, 30);

    test('sums only lines from today that count toward totals', () {
      final lines = [
        _line(
          id: 'today-ok',
          created: DateTime(2026, 8, 10, 9),
          quantity: 2,
          subtotal: 50,
        ),
        _line(
          id: 'today-void',
          created: DateTime(2026, 8, 10, 10),
          quantity: 9,
          subtotal: 90,
          status: 'voided',
        ),
        _line(
          id: 'yesterday',
          created: DateTime(2026, 8, 9, 20),
          quantity: 4,
          subtotal: 40,
        ),
        _line(id: 'no-date', created: null, quantity: 1, subtotal: 10),
      ];

      final summary = todaysProductSalesSummary(lines, now: now);
      expect(summary.totalQty, 2);
      expect(summary.totalRevenue, 50);
    });

    test('returns zeros when no today lines', () {
      final lines = [
        _line(id: 'old', created: DateTime(2026, 8, 1), quantity: 1),
      ];
      final summary = todaysProductSalesSummary(lines, now: now);
      expect(summary.totalQty, 0);
      expect(summary.totalRevenue, 0);
    });
  });
}
