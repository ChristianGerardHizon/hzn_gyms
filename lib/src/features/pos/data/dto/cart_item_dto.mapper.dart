// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'cart_item_dto.dart';

class CartItemDtoMapper extends ClassMapperBase<CartItemDto> {
  CartItemDtoMapper._();

  static CartItemDtoMapper? _instance;
  static CartItemDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CartItemDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'CartItemDto';

  static String _$id(CartItemDto v) => v.id;
  static const Field<CartItemDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(CartItemDto v) => v.collectionId;
  static const Field<CartItemDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(CartItemDto v) => v.collectionName;
  static const Field<CartItemDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$cart(CartItemDto v) => v.cart;
  static const Field<CartItemDto, String> _f$cart = Field('cart', _$cart);
  static String _$product(CartItemDto v) => v.product;
  static const Field<CartItemDto, String> _f$product = Field(
    'product',
    _$product,
  );
  static num _$quantity(CartItemDto v) => v.quantity;
  static const Field<CartItemDto, num> _f$quantity = Field(
    'quantity',
    _$quantity,
  );
  static num? _$customPrice(CartItemDto v) => v.customPrice;
  static const Field<CartItemDto, num> _f$customPrice = Field(
    'customPrice',
    _$customPrice,
    opt: true,
  );
  static String? _$productLot(CartItemDto v) => v.productLot;
  static const Field<CartItemDto, String> _f$productLot = Field(
    'productLot',
    _$productLot,
    opt: true,
  );
  static String? _$lotNumber(CartItemDto v) => v.lotNumber;
  static const Field<CartItemDto, String> _f$lotNumber = Field(
    'lotNumber',
    _$lotNumber,
    opt: true,
  );
  static String? _$created(CartItemDto v) => v.created;
  static const Field<CartItemDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(CartItemDto v) => v.updated;
  static const Field<CartItemDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<CartItemDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #cart: _f$cart,
    #product: _f$product,
    #quantity: _f$quantity,
    #customPrice: _f$customPrice,
    #productLot: _f$productLot,
    #lotNumber: _f$lotNumber,
    #created: _f$created,
    #updated: _f$updated,
  };

  static CartItemDto _instantiate(DecodingData data) {
    return CartItemDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      cart: data.dec(_f$cart),
      product: data.dec(_f$product),
      quantity: data.dec(_f$quantity),
      customPrice: data.dec(_f$customPrice),
      productLot: data.dec(_f$productLot),
      lotNumber: data.dec(_f$lotNumber),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CartItemDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CartItemDto>(map);
  }

  static CartItemDto fromJson(String json) {
    return ensureInitialized().decodeJson<CartItemDto>(json);
  }
}

mixin CartItemDtoMappable {
  String toJson() {
    return CartItemDtoMapper.ensureInitialized().encodeJson<CartItemDto>(
      this as CartItemDto,
    );
  }

  Map<String, dynamic> toMap() {
    return CartItemDtoMapper.ensureInitialized().encodeMap<CartItemDto>(
      this as CartItemDto,
    );
  }

  CartItemDtoCopyWith<CartItemDto, CartItemDto, CartItemDto> get copyWith =>
      _CartItemDtoCopyWithImpl<CartItemDto, CartItemDto>(
        this as CartItemDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CartItemDtoMapper.ensureInitialized().stringifyValue(
      this as CartItemDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return CartItemDtoMapper.ensureInitialized().equalsValue(
      this as CartItemDto,
      other,
    );
  }

  @override
  int get hashCode {
    return CartItemDtoMapper.ensureInitialized().hashValue(this as CartItemDto);
  }
}

extension CartItemDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CartItemDto, $Out> {
  CartItemDtoCopyWith<$R, CartItemDto, $Out> get $asCartItemDto =>
      $base.as((v, t, t2) => _CartItemDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CartItemDtoCopyWith<$R, $In extends CartItemDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? cart,
    String? product,
    num? quantity,
    num? customPrice,
    String? productLot,
    String? lotNumber,
    String? created,
    String? updated,
  });
  CartItemDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CartItemDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CartItemDto, $Out>
    implements CartItemDtoCopyWith<$R, CartItemDto, $Out> {
  _CartItemDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CartItemDto> $mapper =
      CartItemDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? cart,
    String? product,
    num? quantity,
    Object? customPrice = $none,
    Object? productLot = $none,
    Object? lotNumber = $none,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (cart != null) #cart: cart,
      if (product != null) #product: product,
      if (quantity != null) #quantity: quantity,
      if (customPrice != $none) #customPrice: customPrice,
      if (productLot != $none) #productLot: productLot,
      if (lotNumber != $none) #lotNumber: lotNumber,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  CartItemDto $make(CopyWithData data) => CartItemDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    cart: data.get(#cart, or: $value.cart),
    product: data.get(#product, or: $value.product),
    quantity: data.get(#quantity, or: $value.quantity),
    customPrice: data.get(#customPrice, or: $value.customPrice),
    productLot: data.get(#productLot, or: $value.productLot),
    lotNumber: data.get(#lotNumber, or: $value.lotNumber),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  CartItemDtoCopyWith<$R2, CartItemDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CartItemDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

