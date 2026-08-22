import 'package:kylie_gym/src/features/pos/domain/out_of_stock_warn.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('startOfNextLocalDay', () {
    test('returns midnight of the following local calendar day', () {
      final now = DateTime(2026, 8, 7, 15, 30);
      expect(startOfNextLocalDay(now), DateTime(2026, 8, 8));
    });

    test('rolls over the month', () {
      final now = DateTime(2026, 1, 31, 23, 0);
      expect(startOfNextLocalDay(now), DateTime(2026, 2, 1));
    });
  });

  group('isOutOfStockWarnSnoozeActive', () {
    test('is false when value is null or empty', () {
      expect(isOutOfStockWarnSnoozeActive(null), isFalse);
      expect(isOutOfStockWarnSnoozeActive(''), isFalse);
    });

    test('is true before expiry', () {
      final now = DateTime.utc(2026, 8, 7, 10);
      final until = DateTime.utc(2026, 8, 8).toIso8601String();
      expect(isOutOfStockWarnSnoozeActive(until, now), isTrue);
    });

    test('is false at or after expiry', () {
      final until = DateTime.utc(2026, 8, 8).toIso8601String();
      expect(
        isOutOfStockWarnSnoozeActive(until, DateTime.utc(2026, 8, 8)),
        isFalse,
      );
      expect(
        isOutOfStockWarnSnoozeActive(until, DateTime.utc(2026, 8, 8, 1)),
        isFalse,
      );
    });

    test('is false for invalid iso', () {
      expect(isOutOfStockWarnSnoozeActive('not-a-date'), isFalse);
    });
  });

  test('outOfStockWarnSnoozeKey is product-scoped', () {
    expect(
      outOfStockWarnSnoozeKey('prod-1'),
      'pos.outOfStockWarnSnoozeUntil.prod-1',
    );
  });
}
