import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kylie_gym/src/core/packages/pocketbase/pocketbase_collections.dart';
import 'package:kylie_gym/src/features/pos/data/repositories/cart_repository.dart';
import 'package:kylie_gym/src/features/pos/domain/cart.dart';
import 'package:kylie_gym/src/features/pos/domain/cart_item.dart';

import '../../../helpers/pb_test_helpers.dart';

void main() {
  late MockPocketBase pb;
  late MockRecordService carts;
  late MockRecordService cartItems;
  late CartRepositoryImpl repo;

  setUp(() {
    pb = MockPocketBase();
    carts = MockRecordService();
    cartItems = MockRecordService();
    when(() => pb.baseURL).thenReturn('http://pb.test');
    stubCollection(pb, PocketBaseCollections.carts, carts);
    stubCollection(pb, PocketBaseCollections.cartItems, cartItems);
    repo = CartRepositoryImpl(pb);
  });

  test('createCart / getCart / updateCart / deleteCart', () async {
    when(
      () => carts.create(body: any(named: 'body')),
    ).thenAnswer((_) async => buildCartRecord(id: 'c1'));
    when(() => carts.getOne('c1')).thenAnswer(
      (_) async => buildCartRecord(id: 'c1', status: 'active'),
    );
    when(
      () => carts.update('c1', body: any(named: 'body')),
    ).thenAnswer(
      (_) async => buildCartRecord(id: 'c1', status: 'abandoned'),
    );
    when(() => carts.delete('c1')).thenAnswer((_) async {});

    final created = await repo.createCart(
      const Cart(id: '', branchId: 'branch-1', status: 'active'),
    );
    expect(created.isRight(), isTrue);
    expect(
      (await repo.getCart('c1')).getOrElse((_) => throw StateError('l')).id,
      'c1',
    );
    expect(
      (await repo.updateCart(
        const Cart(id: 'c1', branchId: 'branch-1', status: 'abandoned'),
      ))
          .getOrElse((_) => throw StateError('l'))
          .status,
      'abandoned',
    );
    expect((await repo.deleteCart('c1')).isRight(), isTrue);
  });

  test('getActiveCarts filters by branch and active status', () async {
    when(
      () => carts.getFullList(
        filter: any(named: 'filter'),
        sort: any(named: 'sort'),
      ),
    ).thenAnswer((invocation) async {
      expect(
        invocation.namedArguments[#filter],
        'branch = "branch-1" && status = "active"',
      );
      return [buildCartRecord()];
    });

    final result = await repo.getActiveCarts('branch-1');
    expect(result.getOrElse((_) => []).single.id, 'cart-1');
  });

  test('addCartItem includes customPrice and lot fields', () async {
    when(
      () => cartItems.create(
        body: any(named: 'body'),
        expand: any(named: 'expand'),
      ),
    ).thenAnswer((invocation) async {
      final body = invocation.namedArguments[#body] as Map<String, dynamic>;
      expect(body['customPrice'], 12);
      expect(body['productLot'], 'lot-1');
      expect(body['lotNumber'], 'L1');
      return buildCartItemRecord(
        customPrice: 12,
        productLot: 'lot-1',
        lotNumber: 'L1',
      );
    });

    final result = await repo.addCartItem(
      const CartItem(
        cartId: 'cart-1',
        productId: 'prod-1',
        quantity: 1,
        customPrice: 12,
        productLotId: 'lot-1',
        lotNumber: 'L1',
      ),
    );
    expect(result.isRight(), isTrue);
  });

  test('updateCartItem sends customPrice 0 when null', () async {
    when(
      () => cartItems.update(
        any(),
        body: any(named: 'body'),
        expand: any(named: 'expand'),
      ),
    ).thenAnswer((invocation) async {
      final body = invocation.namedArguments[#body] as Map<String, dynamic>;
      expect(body['customPrice'], 0);
      return buildCartItemRecord(id: 'ci-1');
    });

    final result = await repo.updateCartItem(
      const CartItem(id: 'ci-1', cartId: 'c', productId: 'p', quantity: 2),
    );
    expect(result.isRight(), isTrue);
  });

  test('getCartItems and deleteCartItem', () async {
    when(
      () => cartItems.getFullList(
        filter: any(named: 'filter'),
        expand: any(named: 'expand'),
      ),
    ).thenAnswer((_) async => [buildCartItemRecord()]);
    when(() => cartItems.delete('ci-1')).thenAnswer((_) async {});

    final items = await repo.getCartItems('cart-1');
    expect(items.getOrElse((_) => []).single.id, 'ci-1');
    expect((await repo.deleteCartItem('ci-1')).isRight(), isTrue);
  });

  test('failures become Left', () async {
    when(() => carts.getOne(any())).thenThrow(Exception('boom'));
    final result = await repo.getCart('x');
    expect(result.isLeft(), isTrue);
  });
}
