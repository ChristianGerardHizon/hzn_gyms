// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'cart_controller.dart';

class CartStateMapper extends ClassMapperBase<CartState> {
  CartStateMapper._();

  static CartStateMapper? _instance;
  static CartStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CartStateMapper._());
      CartItemMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CartState';

  static String? _$cartId(CartState v) => v.cartId;
  static const Field<CartState, String> _f$cartId = Field(
    'cartId',
    _$cartId,
    opt: true,
  );
  static List<CartItem> _$items(CartState v) => v.items;
  static const Field<CartState, List<CartItem>> _f$items = Field(
    'items',
    _$items,
    opt: true,
    def: const [],
  );
  static bool _$isSyncing(CartState v) => v.isSyncing;
  static const Field<CartState, bool> _f$isSyncing = Field(
    'isSyncing',
    _$isSyncing,
    opt: true,
    def: false,
  );

  @override
  final MappableFields<CartState> fields = const {
    #cartId: _f$cartId,
    #items: _f$items,
    #isSyncing: _f$isSyncing,
  };

  static CartState _instantiate(DecodingData data) {
    return CartState(
      cartId: data.dec(_f$cartId),
      items: data.dec(_f$items),
      isSyncing: data.dec(_f$isSyncing),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CartState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CartState>(map);
  }

  static CartState fromJson(String json) {
    return ensureInitialized().decodeJson<CartState>(json);
  }
}

mixin CartStateMappable {
  String toJson() {
    return CartStateMapper.ensureInitialized().encodeJson<CartState>(
      this as CartState,
    );
  }

  Map<String, dynamic> toMap() {
    return CartStateMapper.ensureInitialized().encodeMap<CartState>(
      this as CartState,
    );
  }

  CartStateCopyWith<CartState, CartState, CartState> get copyWith =>
      _CartStateCopyWithImpl<CartState, CartState>(
        this as CartState,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CartStateMapper.ensureInitialized().stringifyValue(
      this as CartState,
    );
  }

  @override
  bool operator ==(Object other) {
    return CartStateMapper.ensureInitialized().equalsValue(
      this as CartState,
      other,
    );
  }

  @override
  int get hashCode {
    return CartStateMapper.ensureInitialized().hashValue(this as CartState);
  }
}

extension CartStateValueCopy<$R, $Out> on ObjectCopyWith<$R, CartState, $Out> {
  CartStateCopyWith<$R, CartState, $Out> get $asCartState =>
      $base.as((v, t, t2) => _CartStateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CartStateCopyWith<$R, $In extends CartState, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, CartItem, CartItemCopyWith<$R, CartItem, CartItem>>
  get items;
  $R call({String? cartId, List<CartItem>? items, bool? isSyncing});
  CartStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CartStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CartState, $Out>
    implements CartStateCopyWith<$R, CartState, $Out> {
  _CartStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CartState> $mapper =
      CartStateMapper.ensureInitialized();
  @override
  ListCopyWith<$R, CartItem, CartItemCopyWith<$R, CartItem, CartItem>>
  get items => ListCopyWith(
    $value.items,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(items: v),
  );
  @override
  $R call({Object? cartId = $none, List<CartItem>? items, bool? isSyncing}) =>
      $apply(
        FieldCopyWithData({
          if (cartId != $none) #cartId: cartId,
          if (items != null) #items: items,
          if (isSyncing != null) #isSyncing: isSyncing,
        }),
      );
  @override
  CartState $make(CopyWithData data) => CartState(
    cartId: data.get(#cartId, or: $value.cartId),
    items: data.get(#items, or: $value.items),
    isSyncing: data.get(#isSyncing, or: $value.isSyncing),
  );

  @override
  CartStateCopyWith<$R2, CartState, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CartStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

