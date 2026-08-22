import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kylie_gym/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:kylie_gym/src/features/pos/data/repositories/payment_repository.dart';
import 'package:kylie_gym/src/features/pos/data/repositories/sales_repository.dart';
import 'package:kylie_gym/src/features/pos/domain/payment.dart';
import 'package:kylie_gym/src/features/pos/domain/payment_method.dart';
import 'package:kylie_gym/src/features/pos/domain/payment_type.dart';
import 'package:kylie_gym/src/features/pos/domain/sale.dart';
import 'package:kylie_gym/src/features/pos/domain/sale_item.dart';
import 'package:kylie_gym/src/features/pos/presentation/cart_controller.dart';
import 'package:kylie_gym/src/features/pos/presentation/checkout_controller.dart';
import 'package:kylie_gym/src/features/products/data/repositories/product_adjustment_repository.dart';
import 'package:kylie_gym/src/features/products/data/repositories/product_lot_repository.dart';
import 'package:kylie_gym/src/features/products/data/repositories/product_repository.dart';
import 'package:kylie_gym/src/features/products/domain/product_adjustment.dart';
import 'package:kylie_gym/src/features/products/domain/product_adjustment_type.dart';
import 'package:kylie_gym/src/features/products/domain/stock_quantity_change.dart';
import 'package:kylie_gym/src/features/settings/presentation/controllers/current_branch_controller.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

class _FakeSale extends Fake implements Sale {}

class _FakeSaleItem extends Fake implements SaleItem {}

class MockProductAdjustmentRepository extends Mock
    implements ProductAdjustmentRepository {}

class _TestCartController extends CartController {
  _TestCartController(this._initial);

  final CartState _initial;

  @override
  Future<CartState> build() async => _initial;

  @override
  Future<void> markAsConverted() async {
    state = const AsyncData(CartState());
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeSale());
    registerFallbackValue(_FakeSaleItem());
    registerFallbackValue(<SaleItem>[]);
    registerFallbackValue(PaymentMethod.cash);
    registerFallbackValue(PaymentType.payment);
    registerFallbackValue(ProductAdjustmentType.product);
  });

  late MockSalesRepository salesRepo;
  late MockPaymentRepository paymentRepo;
  late MockProductLotRepository lotRepo;
  late MockProductRepository productRepo;
  late MockProductAdjustmentRepository adjustmentRepo;

  ProviderContainer createContainer({
    CartState? cart,
    bool authenticated = true,
    String? branchId = 'branch-1',
  }) {
    salesRepo = MockSalesRepository();
    paymentRepo = MockPaymentRepository();
    lotRepo = MockProductLotRepository();
    productRepo = MockProductRepository();
    adjustmentRepo = MockProductAdjustmentRepository();

    // Default stock side-effect stubs (overridden per-test when verifying)
    when(() => productRepo.decrementQuantity(any(), any())).thenAnswer(
      (_) async => const Right(
        StockQuantityChange(oldValue: 10, newValue: 8),
      ),
    );
    when(() => productRepo.incrementQuantity(any(), any())).thenAnswer(
      (_) async => const Right(
        StockQuantityChange(oldValue: 8, newValue: 10),
      ),
    );
    when(() => productRepo.updateQuantity(any(), any())).thenAnswer(
      (_) async => Right(buildProduct()),
    );
    when(() => lotRepo.decrementQuantity(any(), any())).thenAnswer(
      (_) async => const Right(
        StockQuantityChange(oldValue: 5, newValue: 2),
      ),
    );
    when(() => lotRepo.incrementQuantity(any(), any())).thenAnswer(
      (_) async => const Right(
        StockQuantityChange(oldValue: 2, newValue: 5),
      ),
    );
    when(() => lotRepo.calculateTotalQuantity(any())).thenAnswer(
      (_) async => const Right(0),
    );
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
      ),
    ).thenAnswer(
      (_) async => const Right(
        ProductAdjustment(
          id: 'adj-1',
          type: ProductAdjustmentType.product,
          oldValue: 10,
          newValue: 8,
          saleId: 'created-1',
        ),
      ),
    );

    final cartState = cart ??
        CartState(
          items: [
            buildCartItem(
              quantity: 2,
              product: buildProduct(price: 50),
            ),
          ],
        );

    return ProviderContainer(
      overrides: [
        cartControllerProvider.overrideWith(
          () => _TestCartController(cartState),
        ),
        currentAuthProvider.overrideWithValue(
          authenticated ? buildAuthState() : null,
        ),
        effectiveBranchIdForWriteProvider.overrideWithValue(branchId),
        salesRepositoryProvider.overrideWithValue(salesRepo),
        paymentRepositoryProvider.overrideWithValue(paymentRepo),
        productLotRepositoryProvider.overrideWithValue(lotRepo),
        productRepositoryProvider.overrideWithValue(productRepo),
        productAdjustmentRepositoryProvider.overrideWithValue(adjustmentRepo),
      ],
    );
  }

  Future<void> waitForCart(ProviderContainer container) async {
    await container.read(cartControllerProvider.future);
  }

  test('fails when cart is empty', () async {
    final container = createContainer(cart: const CartState());
    addTearDown(container.dispose);
    await waitForCart(container);

    final result = await container
        .read(checkoutControllerProvider.notifier)
        .processCheckout(payNow: false);

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f.messageString, 'Cart is empty'),
      (_) => fail('expected failure'),
    );
  });

  test('fails when not authenticated', () async {
    final container = createContainer(authenticated: false);
    addTearDown(container.dispose);
    await waitForCart(container);

    final result = await container
        .read(checkoutControllerProvider.notifier)
        .processCheckout(payNow: false);

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f.messageString, 'Not authenticated'),
      (_) => fail('expected failure'),
    );
  });

  test('fails when no branch selected', () async {
    final container = createContainer(branchId: null);
    addTearDown(container.dispose);
    await waitForCart(container);

    final result = await container
        .read(checkoutControllerProvider.notifier)
        .processCheckout(payNow: false);

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f.messageString, 'No branch selected'),
      (_) => fail('expected failure'),
    );
  });

  test('payNow requires payment method and amount', () async {
    final container = createContainer();
    addTearDown(container.dispose);
    await waitForCart(container);

    final missingMethod = await container
        .read(checkoutControllerProvider.notifier)
        .processCheckout(
          payNow: true,
          paymentAmount: 10,
          paymentType: PaymentType.payment,
        );
    expect(
      missingMethod.fold((f) => f.messageString, (_) => ''),
      'Payment method is required',
    );

    final missingAmount = await container
        .read(checkoutControllerProvider.notifier)
        .processCheckout(
          payNow: true,
          paymentMethod: PaymentMethod.cash,
          paymentType: PaymentType.payment,
        );
    expect(
      missingAmount.fold((f) => f.messageString, (_) => ''),
      'Payment amount is required',
    );
  });

  test('pending checkout when not paying now', () async {
    final container = createContainer();
    addTearDown(container.dispose);
    await waitForCart(container);

    when(() => salesRepo.createSale(any(), any())).thenAnswer((invocation) async {
      final sale = invocation.positionalArguments[0] as Sale;
      final items = invocation.positionalArguments[1] as List<SaleItem>;
      expect(sale.status, 'pending');
      expect(sale.isPaid, isFalse);
      expect(sale.totalAmount, 100);
      expect(items.single.unitPrice, 50);
      expect(items.single.subtotal, 100);
      return right(
        buildSale(
          id: 'created-1',
          totalAmount: sale.totalAmount,
          status: sale.status,
          isPaid: sale.isPaid,
        ),
      );
    });
    when(() => salesRepo.getSale('created-1')).thenAnswer(
      (_) async => right(
        buildSale(id: 'created-1', totalAmount: 100, status: 'pending'),
      ),
    );

    final result = await container
        .read(checkoutControllerProvider.notifier)
        .processCheckout(payNow: false);

    expect(result.isRight(), isTrue);
    verifyNever(
      () => paymentRepo.create(
        saleId: any(named: 'saleId'),
        amount: any(named: 'amount'),
        paymentMethod: any(named: 'paymentMethod'),
        type: any(named: 'type'),
        paymentRef: any(named: 'paymentRef'),
        paymentProofFile: any(named: 'paymentProofFile'),
      ),
    );
  });

  test('paid checkout when payment covers cart total', () async {
    final container = createContainer();
    addTearDown(container.dispose);
    await waitForCart(container);

    when(() => salesRepo.createSale(any(), any())).thenAnswer((invocation) async {
      final sale = invocation.positionalArguments[0] as Sale;
      expect(sale.status, 'paid');
      expect(sale.isPaid, isTrue);
      return right(
        buildSale(
          id: 'created-2',
          totalAmount: 100,
          status: 'paid',
          isPaid: true,
        ),
      );
    });
    when(
      () => paymentRepo.create(
        saleId: any(named: 'saleId'),
        amount: any(named: 'amount'),
        paymentMethod: any(named: 'paymentMethod'),
        type: any(named: 'type'),
        paymentRef: any(named: 'paymentRef'),
        paymentProofFile: any(named: 'paymentProofFile'),
      ),
    ).thenAnswer(
      (_) async => right((
        payment: const Payment(
          id: 'pay-1',
          saleId: 'created-2',
          amount: 100,
          paymentMethod: PaymentMethod.cash,
          type: PaymentType.payment,
        ),
        saleIsPaid: true,
        saleStatus: 'paid',
      )),
    );
    when(() => salesRepo.getSale('created-2')).thenAnswer(
      (_) async => right(
        buildSale(id: 'created-2', totalAmount: 100, status: 'paid', isPaid: true),
      ),
    );

    final result = await container
        .read(checkoutControllerProvider.notifier)
        .processCheckout(
          payNow: true,
          paymentMethod: PaymentMethod.cash,
          paymentAmount: 100,
          paymentType: PaymentType.payment,
        );

    expect(result.isRight(), isTrue);
    final sale = result.getOrElse((_) => throw StateError('left'));
    expect(sale.status, 'paid');
  });

  test('awaitingPayment when partial payment', () async {
    final container = createContainer();
    addTearDown(container.dispose);
    await waitForCart(container);

    when(() => salesRepo.createSale(any(), any())).thenAnswer((invocation) async {
      final sale = invocation.positionalArguments[0] as Sale;
      expect(sale.status, 'awaitingPayment');
      expect(sale.isPaid, isFalse);
      return right(
        buildSale(
          id: 'created-3',
          totalAmount: 100,
          status: 'awaitingPayment',
        ),
      );
    });
    when(
      () => paymentRepo.create(
        saleId: any(named: 'saleId'),
        amount: any(named: 'amount'),
        paymentMethod: any(named: 'paymentMethod'),
        type: any(named: 'type'),
        paymentRef: any(named: 'paymentRef'),
        paymentProofFile: any(named: 'paymentProofFile'),
      ),
    ).thenAnswer(
      (_) async => right((
        payment: const Payment(
          id: 'pay-2',
          saleId: 'created-3',
          amount: 40,
          paymentMethod: PaymentMethod.cash,
          type: PaymentType.payment,
        ),
        saleIsPaid: false,
        saleStatus: 'awaitingPayment',
      )),
    );
    when(() => salesRepo.getSale('created-3')).thenAnswer(
      (_) async => right(
        buildSale(id: 'created-3', totalAmount: 100, status: 'awaitingPayment'),
      ),
    );

    final result = await container
        .read(checkoutControllerProvider.notifier)
        .processCheckout(
          payNow: true,
          paymentMethod: PaymentMethod.cash,
          paymentAmount: 40,
          paymentType: PaymentType.payment,
        );

    expect(result.isRight(), isTrue);
  });

  test('decrements product quantity for non-lot trackStock items', () async {
    final product = buildProduct(id: 'prod-nl', price: 50, trackStock: true);
    final container = createContainer(
      cart: CartState(
        items: [buildCartItem(quantity: 2, product: product, productId: product.id)],
      ),
    );
    addTearDown(container.dispose);
    await waitForCart(container);

    when(() => salesRepo.createSale(any(), any())).thenAnswer(
      (_) async => right(
        buildSale(id: 'created-nl', totalAmount: 100, status: 'pending'),
      ),
    );
    when(() => salesRepo.getSale('created-nl')).thenAnswer(
      (_) async => right(
        buildSale(id: 'created-nl', totalAmount: 100, status: 'pending'),
      ),
    );

    final result = await container
        .read(checkoutControllerProvider.notifier)
        .processCheckout(payNow: false);

    expect(result.isRight(), isTrue);
    verify(() => productRepo.decrementQuantity('prod-nl', 2)).called(1);
    verifyNever(() => lotRepo.decrementQuantity(any(), any()));
    verify(
      () => adjustmentRepo.create(
        type: ProductAdjustmentType.product,
        oldValue: 10,
        newValue: 8,
        reason: any(named: 'reason'),
        productId: 'prod-nl',
        productStockId: any(named: 'productStockId'),
        productLotId: any(named: 'productLotId'),
        saleId: 'created-nl',
      ),
    ).called(1);
  });

  test('skips product decrement when trackStock is false', () async {
    final product = buildProduct(id: 'prod-ns', price: 50, trackStock: false);
    final container = createContainer(
      cart: CartState(
        items: [buildCartItem(quantity: 1, product: product, productId: product.id)],
      ),
    );
    addTearDown(container.dispose);
    await waitForCart(container);

    when(() => salesRepo.createSale(any(), any())).thenAnswer(
      (_) async => right(
        buildSale(id: 'created-ns', totalAmount: 50, status: 'pending'),
      ),
    );
    when(() => salesRepo.getSale('created-ns')).thenAnswer(
      (_) async => right(
        buildSale(id: 'created-ns', totalAmount: 50, status: 'pending'),
      ),
    );

    final result = await container
        .read(checkoutControllerProvider.notifier)
        .processCheckout(payNow: false);

    expect(result.isRight(), isTrue);
    verifyNever(() => productRepo.decrementQuantity(any(), any()));
    verifyNever(() => lotRepo.decrementQuantity(any(), any()));
    verifyNever(
      () => adjustmentRepo.create(
        type: any(named: 'type'),
        oldValue: any(named: 'oldValue'),
        newValue: any(named: 'newValue'),
        reason: any(named: 'reason'),
        productId: any(named: 'productId'),
        productStockId: any(named: 'productStockId'),
        productLotId: any(named: 'productLotId'),
        saleId: any(named: 'saleId'),
      ),
    );
  });

  test('decrements lot and syncs product quantity for lot-tracked items', () async {
    final product = buildProduct(
      id: 'prod-lot',
      price: 50,
      trackStock: true,
      trackByLot: true,
    );
    final container = createContainer(
      cart: CartState(
        items: [
          buildCartItem(
            quantity: 3,
            product: product,
            productId: product.id,
            productLotId: 'lot-1',
            lotNumber: 'L1',
          ),
        ],
      ),
    );
    addTearDown(container.dispose);
    await waitForCart(container);

    when(() => salesRepo.createSale(any(), any())).thenAnswer(
      (_) async => right(
        buildSale(id: 'created-lot', totalAmount: 150, status: 'pending'),
      ),
    );
    when(() => salesRepo.getSale('created-lot')).thenAnswer(
      (_) async => right(
        buildSale(id: 'created-lot', totalAmount: 150, status: 'pending'),
      ),
    );
    when(() => lotRepo.calculateTotalQuantity('prod-lot'))
        .thenAnswer((_) async => const Right(7));

    final result = await container
        .read(checkoutControllerProvider.notifier)
        .processCheckout(payNow: false);

    expect(result.isRight(), isTrue);
    verify(() => lotRepo.decrementQuantity('lot-1', 3)).called(1);
    verify(() => productRepo.updateQuantity('prod-lot', 7)).called(1);
    verifyNever(() => productRepo.decrementQuantity(any(), any()));
    verify(
      () => adjustmentRepo.create(
        type: ProductAdjustmentType.productStock,
        oldValue: 5,
        newValue: 2,
        reason: any(named: 'reason'),
        productId: 'prod-lot',
        productStockId: any(named: 'productStockId'),
        productLotId: 'lot-1',
        saleId: 'created-lot',
      ),
    ).called(1);
  });
}
