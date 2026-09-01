import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hzn_gyms/src/core/foundation/failure.dart';
import 'package:hzn_gyms/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:hzn_gyms/src/features/pos/data/repositories/cart_repository.dart';
import 'package:hzn_gyms/src/features/pos/domain/cart.dart';
import 'package:hzn_gyms/src/features/pos/domain/cart_item.dart';
import 'package:hzn_gyms/src/features/pos/presentation/cart_controller.dart';
import 'package:hzn_gyms/src/features/settings/presentation/controllers/current_branch_controller.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

class _FakeCart extends Fake implements Cart {}

class _FakeCartItem extends Fake implements CartItem {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeCart());
    registerFallbackValue(_FakeCartItem());
  });

  late MockCartRepository cartRepo;

  ProviderContainer createContainer({
    String? branchId = 'branch-1',
    List<Cart> activeCarts = const [],
    List<CartItem> initialItems = const [],
  }) {
    cartRepo = MockCartRepository();

    when(() => cartRepo.getActiveCarts(any())).thenAnswer(
      (_) async => right(activeCarts),
    );
    if (activeCarts.isNotEmpty) {
      when(() => cartRepo.getCartItems(activeCarts.first.id)).thenAnswer(
        (_) async => right(initialItems),
      );
    }

    return ProviderContainer(
      overrides: [
        cartRepositoryProvider.overrideWithValue(cartRepo),
        effectiveBranchIdForWriteProvider.overrideWithValue(branchId),
        currentAuthProvider.overrideWithValue(buildAuthState()),
      ],
    );
  }

  Future<CartController> readyController(ProviderContainer container) async {
    await container.read(cartControllerProvider.future);
    return container.read(cartControllerProvider.notifier);
  }

  test('build returns empty cart when no branch', () async {
    final container = createContainer(branchId: null);
    addTearDown(container.dispose);

    final state = await container.read(cartControllerProvider.future);
    expect(state.isEmpty, isTrue);
    verifyNever(() => cartRepo.getActiveCarts(any()));
  });

  test('build loads active cart items', () async {
    final items = [
      buildCartItem(id: 'ci-1', quantity: 2),
    ];
    final container = createContainer(
      activeCarts: [
        const Cart(id: 'cart-1', branchId: 'branch-1', status: 'active'),
      ],
      initialItems: items,
    );
    addTearDown(container.dispose);

    final state = await container.read(cartControllerProvider.future);
    expect(state.cartId, 'cart-1');
    expect(state.items, hasLength(1));
    expect(state.total, 200);
  });

  test('addToCart creates cart then appends item', () async {
    final container = createContainer();
    addTearDown(container.dispose);
    final controller = await readyController(container);
    final product = buildProduct(price: 25);

    when(() => cartRepo.createCart(any())).thenAnswer(
      (_) async => right(
        const Cart(id: 'cart-new', branchId: 'branch-1', status: 'active'),
      ),
    );
    when(() => cartRepo.addCartItem(any())).thenAnswer((invocation) async {
      final item = invocation.positionalArguments.first as CartItem;
      return right(item.copyWith(id: 'ci-new'));
    });

    final error = await controller.addToCart(product);
    expect(error, isNull);

    final state = container.read(cartControllerProvider).value!;
    expect(state.cartId, 'cart-new');
    expect(state.items, hasLength(1));
    expect(state.items.single.effectivePrice, 25);
    expect(state.total, 25);
  });

  test('addToCart merges quantity for existing non-lot item', () async {
    final product = buildProduct(price: 10);
    final existing = buildCartItem(
      id: 'ci-1',
      product: product,
      quantity: 1,
    );
    final container = createContainer(
      activeCarts: [
        const Cart(id: 'cart-1', branchId: 'branch-1', status: 'active'),
      ],
      initialItems: [existing],
    );
    addTearDown(container.dispose);
    final controller = await readyController(container);

    when(() => cartRepo.updateCartItem(any())).thenAnswer((invocation) async {
      final item = invocation.positionalArguments.first as CartItem;
      return right(item);
    });

    final error = await controller.addToCart(product);
    expect(error, isNull);

    final state = container.read(cartControllerProvider).value!;
    expect(state.items, hasLength(1));
    expect(state.items.single.quantity, 2);
  });

  test('addToCart returns error when create cart fails', () async {
    final container = createContainer();
    addTearDown(container.dispose);
    final controller = await readyController(container);

    when(() => cartRepo.createCart(any())).thenAnswer(
      (_) async => left(const GenericFailure('nope')),
    );

    final error = await controller.addToCart(buildProduct());
    expect(error, contains('Could not create cart'));
  });

  test('addToCartWithLot rejects when exceeding lot stock', () async {
    final product = buildProduct(id: 'prod-1', trackByLot: true);
    final lot = buildProductLot(id: 'lot-1', quantity: 2);
    final existing = buildCartItem(
      id: 'ci-1',
      productId: 'prod-1',
      product: product,
      quantity: 2,
    ).copyWith(productLotId: 'lot-1', lotNumber: 'L1');

    final container = createContainer(
      activeCarts: [
        const Cart(id: 'cart-1', branchId: 'branch-1', status: 'active'),
      ],
      initialItems: [existing],
    );
    addTearDown(container.dispose);
    final controller = await readyController(container);

    final error = await controller.addToCartWithLot(product, lot, 1);
    expect(error, 'Not enough stock in this lot');
  });

  test('addToCartWithLot adds new lot line', () async {
    final product = buildProduct(id: 'prod-1', trackByLot: true, price: 40);
    final lot = buildProductLot(id: 'lot-1', quantity: 10);
    final container = createContainer(
      activeCarts: [
        const Cart(id: 'cart-1', branchId: 'branch-1', status: 'active'),
      ],
    );
    addTearDown(container.dispose);
    final controller = await readyController(container);

    when(() => cartRepo.addCartItem(any())).thenAnswer((invocation) async {
      final item = invocation.positionalArguments.first as CartItem;
      return right(item.copyWith(id: 'ci-lot'));
    });

    final error = await controller.addToCartWithLot(product, lot, 3);
    expect(error, isNull);
    final state = container.read(cartControllerProvider).value!;
    expect(state.items.single.productLotId, 'lot-1');
    expect(state.items.single.quantity, 3);
    expect(state.total, 120);
  });

  test('updateQuantityById and removeItemById', () async {
    final product = buildProduct(price: 10);
    final existing = buildCartItem(id: 'ci-1', product: product, quantity: 3);
    final container = createContainer(
      activeCarts: [
        const Cart(id: 'cart-1', branchId: 'branch-1', status: 'active'),
      ],
      initialItems: [existing],
    );
    addTearDown(container.dispose);
    final controller = await readyController(container);

    when(() => cartRepo.updateCartItem(any())).thenAnswer((invocation) async {
      final item = invocation.positionalArguments.first as CartItem;
      return right(item);
    });
    when(() => cartRepo.deleteCartItem('ci-1')).thenAnswer(
      (_) async => right(null),
    );

    await controller.updateQuantityById('ci-1', 5);
    expect(
      container.read(cartControllerProvider).value!.items.single.quantity,
      5,
    );

    await controller.removeItemById('ci-1');
    expect(container.read(cartControllerProvider).value!.isEmpty, isTrue);
  });

  test('updateQuantity zero removes item', () async {
    final product = buildProduct(price: 10);
    final existing = buildCartItem(id: 'ci-1', product: product, quantity: 1);
    final container = createContainer(
      activeCarts: [
        const Cart(id: 'cart-1', branchId: 'branch-1', status: 'active'),
      ],
      initialItems: [existing],
    );
    addTearDown(container.dispose);
    final controller = await readyController(container);

    when(() => cartRepo.deleteCartItem('ci-1')).thenAnswer(
      (_) async => right(null),
    );

    await controller.updateQuantity(product, 0);
    expect(container.read(cartControllerProvider).value!.isEmpty, isTrue);
  });

  test('updateCustomPrice updates line price', () async {
    final product = buildProduct(price: 10);
    final existing = buildCartItem(
      id: 'ci-1',
      product: product,
      quantity: 2,
      customPrice: 8,
    );
    final container = createContainer(
      activeCarts: [
        const Cart(id: 'cart-1', branchId: 'branch-1', status: 'active'),
      ],
      initialItems: [existing],
    );
    addTearDown(container.dispose);
    final controller = await readyController(container);

    when(() => cartRepo.updateCartItem(any())).thenAnswer((invocation) async {
      final item = invocation.positionalArguments.first as CartItem;
      return right(item);
    });

    await controller.updateCustomPrice('ci-1', 12);
    final item = container.read(cartControllerProvider).value!.items.single;
    expect(item.customPrice, 12);
    expect(item.total, 24);
  });

  test('clearCart deletes items and abandons cart', () async {
    final existing = buildCartItem(id: 'ci-1', quantity: 1);
    final container = createContainer(
      activeCarts: [
        const Cart(id: 'cart-1', branchId: 'branch-1', status: 'active'),
      ],
      initialItems: [existing],
    );
    addTearDown(container.dispose);
    final controller = await readyController(container);

    when(() => cartRepo.deleteCartItem(any())).thenAnswer(
      (_) async => right(null),
    );
    when(() => cartRepo.updateCart(any())).thenAnswer(
      (_) async => right(
        const Cart(id: 'cart-1', branchId: 'branch-1', status: 'abandoned'),
      ),
    );

    await controller.clearCart();
    final state = container.read(cartControllerProvider).value!;
    expect(state.isEmpty, isTrue);
    expect(state.cartId, isNull);
    verify(() => cartRepo.updateCart(any())).called(1);
  });

  test('cartTotal and cartItems providers reflect state', () async {
    final container = createContainer(
      activeCarts: [
        const Cart(id: 'cart-1', branchId: 'branch-1', status: 'active'),
      ],
      initialItems: [
        buildCartItem(quantity: 2, product: buildProduct(price: 15)),
      ],
    );
    addTearDown(container.dispose);
    await container.read(cartControllerProvider.future);

    expect(container.read(cartTotalProvider), 30);
    expect(container.read(cartItemsProvider), hasLength(1));
  });
}
