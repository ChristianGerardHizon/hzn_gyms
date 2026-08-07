import 'package:ebe_gym/src/features/products/domain/product_adjustment.dart';
import 'package:ebe_gym/src/features/products/domain/product_adjustment_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ProductAdjustment buildAdj({
    String id = 'adj-1',
    ProductAdjustmentType type = ProductAdjustmentType.product,
    num oldValue = 10,
    num newValue = 15,
    String? reason,
    String? productId = 'prod-1',
    String? productLotId,
    String? saleId,
    bool isVoided = false,
    String? voidsAdjustmentId,
  }) {
    return ProductAdjustment(
      id: id,
      type: type,
      oldValue: oldValue,
      newValue: newValue,
      reason: reason,
      productId: productId,
      productLotId: productLotId,
      saleId: saleId,
      isVoided: isVoided,
      voidsAdjustmentId: voidsAdjustmentId,
    );
  }

  group('ProductAdjustment void helpers', () {
    test('canVoid is true for manual adjustments', () {
      final adj = buildAdj();
      expect(adj.canVoid, isTrue);
      expect(adj.voidBlockReason, isNull);
      expect(adj.countsTowardSummary, isTrue);
    });

    test('blocks already voided adjustments', () {
      final adj = buildAdj(isVoided: true);
      expect(adj.canVoid, isFalse);
      expect(adj.voidBlockReason, contains('already voided'));
      expect(adj.countsTowardSummary, isFalse);
    });

    test('blocks void reverse records', () {
      final adj = buildAdj(voidsAdjustmentId: 'adj-original');
      expect(adj.isVoidRecord, isTrue);
      expect(adj.canVoid, isFalse);
      expect(adj.voidBlockReason, contains('void record'));
      expect(adj.countsTowardSummary, isFalse);
    });

    test('blocks sale-linked adjustments', () {
      final adj = buildAdj(saleId: 'sale-1');
      expect(adj.isSaleLinked, isTrue);
      expect(adj.canVoid, isFalse);
      expect(adj.voidBlockReason, contains('sale'));
    });
  });
}
