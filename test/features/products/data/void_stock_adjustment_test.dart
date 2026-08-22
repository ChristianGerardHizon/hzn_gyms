import 'package:kylie_gym/src/core/foundation/failure.dart';
import 'package:kylie_gym/src/features/products/data/repositories/product_adjustment_repository.dart';
import 'package:kylie_gym/src/features/products/data/void_stock_adjustment.dart';
import 'package:kylie_gym/src/features/products/domain/product_adjustment.dart';
import 'package:kylie_gym/src/features/products/domain/product_adjustment_type.dart';
import 'package:kylie_gym/src/features/products/domain/stock_quantity_change.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

class MockProductAdjustmentRepository extends Mock
    implements ProductAdjustmentRepository {}

void main() {
  late MockProductAdjustmentRepository adjustmentRepo;
  late MockProductRepository productRepo;
  late MockProductLotRepository lotRepo;

  setUpAll(() {
    registerFallbackValue(ProductAdjustmentType.product);
  });

  setUp(() {
    adjustmentRepo = MockProductAdjustmentRepository();
    productRepo = MockProductRepository();
    lotRepo = MockProductLotRepository();
  });

  ProductAdjustment buildAdj({
    String id = 'adj-1',
    ProductAdjustmentType type = ProductAdjustmentType.product,
    num oldValue = 10,
    num newValue = 15,
    String? reason = 'Cycle count',
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

  void stubCreateSuccess({String reverseId = 'adj-void'}) {
    when(
      () => adjustmentRepo.create(
        type: any(named: 'type'),
        oldValue: any(named: 'oldValue'),
        newValue: any(named: 'newValue'),
        reason: any(named: 'reason'),
        productId: any(named: 'productId'),
        productStockId: any(named: 'productStockId'),
        productLotId: any(named: 'productLotId'),
        saleId: any(named: 'saleId'),
        voidsAdjustmentId: any(named: 'voidsAdjustmentId'),
        voidedById: any(named: 'voidedById'),
      ),
    ).thenAnswer(
      (invocation) async => Right(
        ProductAdjustment(
          id: reverseId,
          type: invocation.namedArguments[#type] as ProductAdjustmentType,
          oldValue: invocation.namedArguments[#oldValue] as num,
          newValue: invocation.namedArguments[#newValue] as num,
          reason: invocation.namedArguments[#reason] as String?,
          productId: invocation.namedArguments[#productId] as String?,
          productLotId: invocation.namedArguments[#productLotId] as String?,
          voidsAdjustmentId:
              invocation.namedArguments[#voidsAdjustmentId] as String?,
          voidedById: invocation.namedArguments[#voidedById] as String?,
        ),
      ),
    );
  }

  group('voidStockAdjustmentWithSideEffects', () {
    test('rejects already voided adjustments', () async {
      final result = await voidStockAdjustmentWithSideEffects(
        adjustmentRepo: adjustmentRepo,
        productRepo: productRepo,
        lotRepo: lotRepo,
        adjustment: buildAdj(isVoided: true),
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<PresentationFailure>()),
        (_) => fail('expected failure'),
      );
      verifyNever(
        () => productRepo.incrementQuantity(any(), any()),
      );
    });

    test('rejects sale-linked adjustments', () async {
      final result = await voidStockAdjustmentWithSideEffects(
        adjustmentRepo: adjustmentRepo,
        productRepo: productRepo,
        lotRepo: lotRepo,
        adjustment: buildAdj(saleId: 'sale-1'),
      );

      expect(result.isLeft(), isTrue);
      verifyNever(() => productRepo.incrementQuantity(any(), any()));
    });

    test('voids product adjustment and reverses quantity', () async {
      final adj = buildAdj(oldValue: 10, newValue: 15);
      when(() => productRepo.fetchOne('prod-1')).thenAnswer(
        (_) async => Right(buildProduct(id: 'prod-1', quantity: 20)),
      );
      when(() => productRepo.incrementQuantity('prod-1', -5)).thenAnswer(
        (_) async => const Right(
          StockQuantityChange(oldValue: 20, newValue: 15),
        ),
      );
      stubCreateSuccess();
      when(
        () => adjustmentRepo.markVoided(
          id: 'adj-1',
          voidedById: 'user-1',
        ),
      ).thenAnswer(
        (_) async => Right(adj.copyWith(isVoided: true, voidedById: 'user-1')),
      );

      final result = await voidStockAdjustmentWithSideEffects(
        adjustmentRepo: adjustmentRepo,
        productRepo: productRepo,
        lotRepo: lotRepo,
        adjustment: adj,
        voidedById: 'user-1',
      );

      expect(result.isRight(), isTrue);
      final reverse = result.fold((_) => null, (a) => a)!;
      expect(reverse.voidsAdjustmentId, 'adj-1');
      expect(reverse.oldValue, 20);
      expect(reverse.newValue, 15);
      expect(reverse.reason, 'Void: Cycle count');

      verify(() => productRepo.incrementQuantity('prod-1', -5)).called(1);
      verify(
        () => adjustmentRepo.markVoided(id: 'adj-1', voidedById: 'user-1'),
      ).called(1);
    });

    test('refuses void when reversing increase would go negative', () async {
      final adj = buildAdj(oldValue: 10, newValue: 15);
      when(() => productRepo.fetchOne('prod-1')).thenAnswer(
        (_) async => Right(buildProduct(id: 'prod-1', quantity: 2)),
      );

      final result = await voidStockAdjustmentWithSideEffects(
        adjustmentRepo: adjustmentRepo,
        productRepo: productRepo,
        lotRepo: lotRepo,
        adjustment: adj,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f.messageString, contains('negative')),
        (_) => fail('expected failure'),
      );
      verifyNever(() => productRepo.incrementQuantity(any(), any()));
    });

    test('voids lot adjustment and syncs product total', () async {
      final adj = buildAdj(
        type: ProductAdjustmentType.productStock,
        oldValue: 5,
        newValue: 2,
        productLotId: 'lot-1',
      );
      when(() => lotRepo.incrementQuantity('lot-1', 3)).thenAnswer(
        (_) async => const Right(
          StockQuantityChange(oldValue: 2, newValue: 5),
        ),
      );
      when(() => lotRepo.calculateTotalQuantity('prod-1')).thenAnswer(
        (_) async => const Right(12),
      );
      when(() => productRepo.updateQuantity('prod-1', 12)).thenAnswer(
        (_) async => Right(buildProduct(id: 'prod-1', quantity: 12)),
      );
      stubCreateSuccess();
      when(
        () => adjustmentRepo.markVoided(
          id: any(named: 'id'),
          voidedById: any(named: 'voidedById'),
        ),
      ).thenAnswer((_) async => Right(adj.copyWith(isVoided: true)));

      final result = await voidStockAdjustmentWithSideEffects(
        adjustmentRepo: adjustmentRepo,
        productRepo: productRepo,
        lotRepo: lotRepo,
        adjustment: adj,
      );

      expect(result.isRight(), isTrue);
      verify(() => lotRepo.incrementQuantity('lot-1', 3)).called(1);
      verify(() => productRepo.updateQuantity('prod-1', 12)).called(1);
    });
  });
}
