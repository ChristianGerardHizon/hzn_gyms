// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'cart.dart';

class CartMapper extends ClassMapperBase<Cart> {
  CartMapper._();

  static CartMapper? _instance;
  static CartMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CartMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Cart';

  static String _$id(Cart v) => v.id;
  static const Field<Cart, String> _f$id = Field('id', _$id);
  static String _$branchId(Cart v) => v.branchId;
  static const Field<Cart, String> _f$branchId = Field('branchId', _$branchId);
  static String _$status(Cart v) => v.status;
  static const Field<Cart, String> _f$status = Field('status', _$status);
  static String? _$userId(Cart v) => v.userId;
  static const Field<Cart, String> _f$userId = Field(
    'userId',
    _$userId,
    opt: true,
  );
  static num? _$totalAmount(Cart v) => v.totalAmount;
  static const Field<Cart, num> _f$totalAmount = Field(
    'totalAmount',
    _$totalAmount,
    opt: true,
  );
  static DateTime? _$created(Cart v) => v.created;
  static const Field<Cart, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(Cart v) => v.updated;
  static const Field<Cart, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<Cart> fields = const {
    #id: _f$id,
    #branchId: _f$branchId,
    #status: _f$status,
    #userId: _f$userId,
    #totalAmount: _f$totalAmount,
    #created: _f$created,
    #updated: _f$updated,
  };

  static Cart _instantiate(DecodingData data) {
    return Cart(
      id: data.dec(_f$id),
      branchId: data.dec(_f$branchId),
      status: data.dec(_f$status),
      userId: data.dec(_f$userId),
      totalAmount: data.dec(_f$totalAmount),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Cart fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Cart>(map);
  }

  static Cart fromJson(String json) {
    return ensureInitialized().decodeJson<Cart>(json);
  }
}

mixin CartMappable {
  String toJson() {
    return CartMapper.ensureInitialized().encodeJson<Cart>(this as Cart);
  }

  Map<String, dynamic> toMap() {
    return CartMapper.ensureInitialized().encodeMap<Cart>(this as Cart);
  }

  CartCopyWith<Cart, Cart, Cart> get copyWith =>
      _CartCopyWithImpl<Cart, Cart>(this as Cart, $identity, $identity);
  @override
  String toString() {
    return CartMapper.ensureInitialized().stringifyValue(this as Cart);
  }

  @override
  bool operator ==(Object other) {
    return CartMapper.ensureInitialized().equalsValue(this as Cart, other);
  }

  @override
  int get hashCode {
    return CartMapper.ensureInitialized().hashValue(this as Cart);
  }
}

extension CartValueCopy<$R, $Out> on ObjectCopyWith<$R, Cart, $Out> {
  CartCopyWith<$R, Cart, $Out> get $asCart =>
      $base.as((v, t, t2) => _CartCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CartCopyWith<$R, $In extends Cart, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? branchId,
    String? status,
    String? userId,
    num? totalAmount,
    DateTime? created,
    DateTime? updated,
  });
  CartCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CartCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Cart, $Out>
    implements CartCopyWith<$R, Cart, $Out> {
  _CartCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Cart> $mapper = CartMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? branchId,
    String? status,
    Object? userId = $none,
    Object? totalAmount = $none,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (branchId != null) #branchId: branchId,
      if (status != null) #status: status,
      if (userId != $none) #userId: userId,
      if (totalAmount != $none) #totalAmount: totalAmount,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  Cart $make(CopyWithData data) => Cart(
    id: data.get(#id, or: $value.id),
    branchId: data.get(#branchId, or: $value.branchId),
    status: data.get(#status, or: $value.status),
    userId: data.get(#userId, or: $value.userId),
    totalAmount: data.get(#totalAmount, or: $value.totalAmount),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  CartCopyWith<$R2, Cart, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _CartCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

