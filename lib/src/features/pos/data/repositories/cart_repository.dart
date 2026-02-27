import 'package:fpdart/fpdart.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../domain/cart.dart';
import '../../domain/cart_item.dart';
import '../dto/cart_dto.dart';
import '../dto/cart_item_dto.dart';

part 'cart_repository.g.dart';

abstract class CartRepository {
  FutureEither<Cart> createCart(Cart cart);
  FutureEither<Cart> getCart(String id);
  FutureEither<List<Cart>> getActiveCarts(String branchId);
  FutureEither<Cart> updateCart(Cart cart);
  FutureEither<void> deleteCart(String id);

  // Cart Items
  FutureEither<List<CartItem>> getCartItems(String cartId);
  FutureEither<CartItem> addCartItem(CartItem item);
  FutureEither<CartItem> updateCartItem(CartItem item);
  FutureEither<void> deleteCartItem(String id);
}

@Riverpod(keepAlive: true)
CartRepository cartRepository(Ref ref) {
  return CartRepositoryImpl(ref.watch(pocketbaseProvider));
}

class CartRepositoryImpl implements CartRepository {
  final PocketBase _pb;

  CartRepositoryImpl(this._pb);

  RecordService get _carts => _pb.collection(PocketBaseCollections.carts);
  RecordService get _cartItems =>
      _pb.collection(PocketBaseCollections.cartItems);

  Cart _toCartEntity(RecordModel record) {
    return CartDto.fromRecord(record).toEntity();
  }

  CartItem _toCartItemEntity(RecordModel record) {
    // Expand product if available
    final productExpanded = record.get<RecordModel?>('expand.product');
    return CartItemDto.fromRecord(record)
        .toEntity(productExpanded: productExpanded);
  }

  @override
  FutureEither<Cart> createCart(Cart cart) async {
    return TaskEither.tryCatch(
      () async {
        final body = {
          'branch': cart.branchId,
          'status': cart.status,
          'user': cart.userId,
          'total_amount': cart.totalAmount,
        };
        final record = await _carts.create(body: body);
        return _toCartEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Cart> getCart(String id) async {
    return TaskEither.tryCatch(
      () async {
        final record = await _carts.getOne(id);
        return _toCartEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<Cart>> getActiveCarts(String branchId) async {
    return TaskEither.tryCatch(
      () async {
        final records = await _carts.getFullList(
          filter: 'branch = "$branchId" && status = "active"',
          sort: '-created',
        );
        return records.map(_toCartEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<Cart> updateCart(Cart cart) async {
    return TaskEither.tryCatch(
      () async {
        final body = {
          'branch': cart.branchId,
          'status': cart.status,
          'user': cart.userId,
          'total_amount': cart.totalAmount,
        };
        final record = await _carts.update(cart.id, body: body);
        return _toCartEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<void> deleteCart(String id) async {
    return TaskEither.tryCatch(
      () async {
        await _carts.delete(id);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<List<CartItem>> getCartItems(String cartId) async {
    return TaskEither.tryCatch(
      () async {
        final records = await _cartItems.getFullList(
          filter: 'cart = "$cartId"',
          expand: 'product.quantityUnit',
        );
        return records.map(_toCartItemEntity).toList();
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<CartItem> addCartItem(CartItem item) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'cart': item.cartId,
          'product': item.productId,
          'quantity': item.quantity,
        };
        // Add custom price if present (for variable-price products)
        if (item.customPrice != null) {
          body['customPrice'] = item.customPrice;
        }
        // Add lot fields if present (for lot-tracked products)
        if (item.productLotId != null && item.productLotId!.isNotEmpty) {
          body['productLot'] = item.productLotId;
          body['lotNumber'] = item.lotNumber;
        }
        final record = await _cartItems.create(body: body, expand: 'product.quantityUnit');
        return _toCartItemEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<CartItem> updateCartItem(CartItem item) async {
    return TaskEither.tryCatch(
      () async {
        final body = <String, dynamic>{
          'quantity': item.quantity,
          // Always send customPrice so it can be updated or cleared
          'customPrice': item.customPrice ?? 0,
        };
        // Update lot fields if present
        if (item.productLotId != null) {
          body['productLot'] = item.productLotId;
          body['lotNumber'] = item.lotNumber;
        }
        final record =
            await _cartItems.update(item.id, body: body, expand: 'product.quantityUnit');
        return _toCartItemEntity(record);
      },
      Failure.handle,
    ).run();
  }

  @override
  FutureEither<void> deleteCartItem(String id) async {
    return TaskEither.tryCatch(
      () async {
        await _cartItems.delete(id);
      },
      Failure.handle,
    ).run();
  }
}
