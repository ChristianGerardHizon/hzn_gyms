import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ebe_gym/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ebe_gym/src/features/pos/data/repositories/payment_repository.dart';
import 'package:ebe_gym/src/features/pos/data/repositories/sales_repository.dart';
import 'package:ebe_gym/src/features/pos/domain/payment.dart';
import 'package:ebe_gym/src/features/pos/domain/payment_method.dart';
import 'package:ebe_gym/src/features/pos/domain/payment_type.dart';
import 'package:ebe_gym/src/features/pos/domain/sale.dart';
import 'package:ebe_gym/src/features/pos/domain/sale_item.dart';
import 'package:ebe_gym/src/features/pos/presentation/cart_controller.dart';
import 'package:ebe_gym/src/features/pos/presentation/checkout_controller.dart';
import 'package:ebe_gym/src/features/products/data/repositories/product_lot_repository.dart';
import 'package:ebe_gym/src/features/products/data/repositories/product_repository.dart';
import 'package:ebe_gym/src/features/settings/presentation/controllers/current_branch_controller.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

class _FakeSale extends Fake implements Sale {}

class _FakeSaleItem extends Fake implements SaleItem {}

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
  });

  late MockSalesRepository salesRepo;
  late MockPaymentRepository paymentRepo;
  late MockProductLotRepository lotRepo;
  late MockProductRepository productRepo;

  ProviderContainer createContainer({
    CartState? cart,
    bool authenticated = true,
    String? branchId = 'branch-1',
  }) {
    salesRepo = MockSalesRepository();
    paymentRepo = MockPaymentRepository();
    lotRepo = MockProductLotRepository();
    productRepo = MockProductRepository();

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
}
