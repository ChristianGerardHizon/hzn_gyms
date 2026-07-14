// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'cart_item.dart';

class CartItemMapper extends ClassMapperBase<CartItem> {
  CartItemMapper._();

  static CartItemMapper? _instance;
  static CartItemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CartItemMapper._());
      ProductMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CartItem';

  static String _$id(CartItem v) => v.id;
  static const Field<CartItem, String> _f$id = Field(
    'id',
    _$id,
    opt: true,
    def: '',
  );
  static String _$cartId(CartItem v) => v.cartId;
  static const Field<CartItem, String> _f$cartId = Field(
    'cartId',
    _$cartId,
    opt: true,
    def: '',
  );
  static String _$productId(CartItem v) => v.productId;
  static const Field<CartItem, String> _f$productId = Field(
    'productId',
    _$productId,
    opt: true,
    def: '',
  );
  static Product? _$product(CartItem v) => v.product;
  static const Field<CartItem, Product> _f$product = Field(
    'product',
    _$product,
    opt: true,
  );
  static num _$quantity(CartItem v) => v.quantity;
  static const Field<CartItem, num> _f$quantity = Field(
    'quantity',
    _$quantity,
    opt: true,
    def: 1,
  );
  static num? _$customPrice(CartItem v) => v.customPrice;
  static const Field<CartItem, num> _f$customPrice = Field(
    'customPrice',
    _$customPrice,
    opt: true,
  );
  static String? _$productLotId(CartItem v) => v.productLotId;
  static const Field<CartItem, String> _f$productLotId = Field(
    'productLotId',
    _$productLotId,
    opt: true,
  );
  static String? _$lotNumber(CartItem v) => v.lotNumber;
  static const Field<CartItem, String> _f$lotNumber = Field(
    'lotNumber',
    _$lotNumber,
    opt: true,
  );
  static DateTime? _$created(CartItem v) => v.created;
  static const Field<CartItem, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(CartItem v) => v.updated;
  static const Field<CartItem, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<CartItem> fields = const {
    #id: _f$id,
    #cartId: _f$cartId,
    #productId: _f$productId,
    #product: _f$product,
    #quantity: _f$quantity,
    #customPrice: _f$customPrice,
    #productLotId: _f$productLotId,
    #lotNumber: _f$lotNumber,
    #created: _f$created,
    #updated: _f$updated,
  };

  static CartItem _instantiate(DecodingData data) {
    return CartItem(
      id: data.dec(_f$id),
      cartId: data.dec(_f$cartId),
      productId: data.dec(_f$productId),
      product: data.dec(_f$product),
      quantity: data.dec(_f$quantity),
      customPrice: data.dec(_f$customPrice),
      productLotId: data.dec(_f$productLotId),
      lotNumber: data.dec(_f$lotNumber),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CartItem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CartItem>(map);
  }

  static CartItem fromJson(String json) {
    return ensureInitialized().decodeJson<CartItem>(json);
  }
}

mixin CartItemMappable {
  String toJson() {
    return CartItemMapper.ensureInitialized().encodeJson<CartItem>(
      this as CartItem,
    );
  }

  Map<String, dynamic> toMap() {
    return CartItemMapper.ensureInitialized().encodeMap<CartItem>(
      this as CartItem,
    );
  }

  CartItemCopyWith<CartItem, CartItem, CartItem> get copyWith =>
      _CartItemCopyWithImpl<CartItem, CartItem>(
        this as CartItem,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CartItemMapper.ensureInitialized().stringifyValue(this as CartItem);
  }

  @override
  bool operator ==(Object other) {
    return CartItemMapper.ensureInitialized().equalsValue(
      this as CartItem,
      other,
    );
  }

  @override
  int get hashCode {
    return CartItemMapper.ensureInitialized().hashValue(this as CartItem);
  }
}

extension CartItemValueCopy<$R, $Out> on ObjectCopyWith<$R, CartItem, $Out> {
  CartItemCopyWith<$R, CartItem, $Out> get $asCartItem =>
      $base.as((v, t, t2) => _CartItemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CartItemCopyWith<$R, $In extends CartItem, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ProductCopyWith<$R, Product, Product>? get product;
  $R call({
    String? id,
    String? cartId,
    String? productId,
    Product? product,
    num? quantity,
    num? customPrice,
    String? productLotId,
    String? lotNumber,
    DateTime? created,
    DateTime? updated,
  });
  CartItemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CartItemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CartItem, $Out>
    implements CartItemCopyWith<$R, CartItem, $Out> {
  _CartItemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CartItem> $mapper =
      CartItemMapper.ensureInitialized();
  @override
  ProductCopyWith<$R, Product, Product>? get product =>
      $value.product?.copyWith.$chain((v) => call(product: v));
  @override
  $R call({
    String? id,
    String? cartId,
    String? productId,
    Object? product = $none,
    num? quantity,
    Object? customPrice = $none,
    Object? productLotId = $none,
    Object? lotNumber = $none,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (cartId != null) #cartId: cartId,
      if (productId != null) #productId: productId,
      if (product != $none) #product: product,
      if (quantity != null) #quantity: quantity,
      if (customPrice != $none) #customPrice: customPrice,
      if (productLotId != $none) #productLotId: productLotId,
      if (lotNumber != $none) #lotNumber: lotNumber,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  CartItem $make(CopyWithData data) => CartItem(
    id: data.get(#id, or: $value.id),
    cartId: data.get(#cartId, or: $value.cartId),
    productId: data.get(#productId, or: $value.productId),
    product: data.get(#product, or: $value.product),
    quantity: data.get(#quantity, or: $value.quantity),
    customPrice: data.get(#customPrice, or: $value.customPrice),
    productLotId: data.get(#productLotId, or: $value.productLotId),
    lotNumber: data.get(#lotNumber, or: $value.lotNumber),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  CartItemCopyWith<$R2, CartItem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CartItemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

