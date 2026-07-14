// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'cart_dto.dart';

class CartDtoMapper extends ClassMapperBase<CartDto> {
  CartDtoMapper._();

  static CartDtoMapper? _instance;
  static CartDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CartDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'CartDto';

  static String _$id(CartDto v) => v.id;
  static const Field<CartDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(CartDto v) => v.collectionId;
  static const Field<CartDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(CartDto v) => v.collectionName;
  static const Field<CartDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$branch(CartDto v) => v.branch;
  static const Field<CartDto, String> _f$branch = Field('branch', _$branch);
  static String _$status(CartDto v) => v.status;
  static const Field<CartDto, String> _f$status = Field('status', _$status);
  static String? _$user(CartDto v) => v.user;
  static const Field<CartDto, String> _f$user = Field(
    'user',
    _$user,
    opt: true,
  );
  static num? _$totalAmount(CartDto v) => v.totalAmount;
  static const Field<CartDto, num> _f$totalAmount = Field(
    'totalAmount',
    _$totalAmount,
    opt: true,
  );
  static String? _$created(CartDto v) => v.created;
  static const Field<CartDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(CartDto v) => v.updated;
  static const Field<CartDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<CartDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #branch: _f$branch,
    #status: _f$status,
    #user: _f$user,
    #totalAmount: _f$totalAmount,
    #created: _f$created,
    #updated: _f$updated,
  };

  static CartDto _instantiate(DecodingData data) {
    return CartDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      branch: data.dec(_f$branch),
      status: data.dec(_f$status),
      user: data.dec(_f$user),
      totalAmount: data.dec(_f$totalAmount),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CartDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CartDto>(map);
  }

  static CartDto fromJson(String json) {
    return ensureInitialized().decodeJson<CartDto>(json);
  }
}

mixin CartDtoMappable {
  String toJson() {
    return CartDtoMapper.ensureInitialized().encodeJson<CartDto>(
      this as CartDto,
    );
  }

  Map<String, dynamic> toMap() {
    return CartDtoMapper.ensureInitialized().encodeMap<CartDto>(
      this as CartDto,
    );
  }

  CartDtoCopyWith<CartDto, CartDto, CartDto> get copyWith =>
      _CartDtoCopyWithImpl<CartDto, CartDto>(
        this as CartDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CartDtoMapper.ensureInitialized().stringifyValue(this as CartDto);
  }

  @override
  bool operator ==(Object other) {
    return CartDtoMapper.ensureInitialized().equalsValue(
      this as CartDto,
      other,
    );
  }

  @override
  int get hashCode {
    return CartDtoMapper.ensureInitialized().hashValue(this as CartDto);
  }
}

extension CartDtoValueCopy<$R, $Out> on ObjectCopyWith<$R, CartDto, $Out> {
  CartDtoCopyWith<$R, CartDto, $Out> get $asCartDto =>
      $base.as((v, t, t2) => _CartDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CartDtoCopyWith<$R, $In extends CartDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? branch,
    String? status,
    String? user,
    num? totalAmount,
    String? created,
    String? updated,
  });
  CartDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CartDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CartDto, $Out>
    implements CartDtoCopyWith<$R, CartDto, $Out> {
  _CartDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CartDto> $mapper =
      CartDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? branch,
    String? status,
    Object? user = $none,
    Object? totalAmount = $none,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (branch != null) #branch: branch,
      if (status != null) #status: status,
      if (user != $none) #user: user,
      if (totalAmount != $none) #totalAmount: totalAmount,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  CartDto $make(CopyWithData data) => CartDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    branch: data.get(#branch, or: $value.branch),
    status: data.get(#status, or: $value.status),
    user: data.get(#user, or: $value.user),
    totalAmount: data.get(#totalAmount, or: $value.totalAmount),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  CartDtoCopyWith<$R2, CartDto, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _CartDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

