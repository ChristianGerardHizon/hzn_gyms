// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'product_adjustment.dart';

class ProductAdjustmentMapper extends ClassMapperBase<ProductAdjustment> {
  ProductAdjustmentMapper._();

  static ProductAdjustmentMapper? _instance;
  static ProductAdjustmentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ProductAdjustmentMapper._());
      ProductAdjustmentTypeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ProductAdjustment';

  static String _$id(ProductAdjustment v) => v.id;
  static const Field<ProductAdjustment, String> _f$id = Field('id', _$id);
  static ProductAdjustmentType _$type(ProductAdjustment v) => v.type;
  static const Field<ProductAdjustment, ProductAdjustmentType> _f$type = Field(
    'type',
    _$type,
  );
  static num _$oldValue(ProductAdjustment v) => v.oldValue;
  static const Field<ProductAdjustment, num> _f$oldValue = Field(
    'oldValue',
    _$oldValue,
  );
  static num _$newValue(ProductAdjustment v) => v.newValue;
  static const Field<ProductAdjustment, num> _f$newValue = Field(
    'newValue',
    _$newValue,
  );
  static String? _$reason(ProductAdjustment v) => v.reason;
  static const Field<ProductAdjustment, String> _f$reason = Field(
    'reason',
    _$reason,
    opt: true,
  );
  static String? _$productId(ProductAdjustment v) => v.productId;
  static const Field<ProductAdjustment, String> _f$productId = Field(
    'productId',
    _$productId,
    opt: true,
  );
  static String? _$productStockId(ProductAdjustment v) => v.productStockId;
  static const Field<ProductAdjustment, String> _f$productStockId = Field(
    'productStockId',
    _$productStockId,
    opt: true,
  );
  static String? _$productLotId(ProductAdjustment v) => v.productLotId;
  static const Field<ProductAdjustment, String> _f$productLotId = Field(
    'productLotId',
    _$productLotId,
    opt: true,
  );
  static bool _$isDeleted(ProductAdjustment v) => v.isDeleted;
  static const Field<ProductAdjustment, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static DateTime? _$created(ProductAdjustment v) => v.created;
  static const Field<ProductAdjustment, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(ProductAdjustment v) => v.updated;
  static const Field<ProductAdjustment, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<ProductAdjustment> fields = const {
    #id: _f$id,
    #type: _f$type,
    #oldValue: _f$oldValue,
    #newValue: _f$newValue,
    #reason: _f$reason,
    #productId: _f$productId,
    #productStockId: _f$productStockId,
    #productLotId: _f$productLotId,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static ProductAdjustment _instantiate(DecodingData data) {
    return ProductAdjustment(
      id: data.dec(_f$id),
      type: data.dec(_f$type),
      oldValue: data.dec(_f$oldValue),
      newValue: data.dec(_f$newValue),
      reason: data.dec(_f$reason),
      productId: data.dec(_f$productId),
      productStockId: data.dec(_f$productStockId),
      productLotId: data.dec(_f$productLotId),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ProductAdjustment fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ProductAdjustment>(map);
  }

  static ProductAdjustment fromJson(String json) {
    return ensureInitialized().decodeJson<ProductAdjustment>(json);
  }
}

mixin ProductAdjustmentMappable {
  String toJson() {
    return ProductAdjustmentMapper.ensureInitialized()
        .encodeJson<ProductAdjustment>(this as ProductAdjustment);
  }

  Map<String, dynamic> toMap() {
    return ProductAdjustmentMapper.ensureInitialized()
        .encodeMap<ProductAdjustment>(this as ProductAdjustment);
  }

  ProductAdjustmentCopyWith<
    ProductAdjustment,
    ProductAdjustment,
    ProductAdjustment
  >
  get copyWith =>
      _ProductAdjustmentCopyWithImpl<ProductAdjustment, ProductAdjustment>(
        this as ProductAdjustment,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ProductAdjustmentMapper.ensureInitialized().stringifyValue(
      this as ProductAdjustment,
    );
  }

  @override
  bool operator ==(Object other) {
    return ProductAdjustmentMapper.ensureInitialized().equalsValue(
      this as ProductAdjustment,
      other,
    );
  }

  @override
  int get hashCode {
    return ProductAdjustmentMapper.ensureInitialized().hashValue(
      this as ProductAdjustment,
    );
  }
}

extension ProductAdjustmentValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ProductAdjustment, $Out> {
  ProductAdjustmentCopyWith<$R, ProductAdjustment, $Out>
  get $asProductAdjustment => $base.as(
    (v, t, t2) => _ProductAdjustmentCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class ProductAdjustmentCopyWith<
  $R,
  $In extends ProductAdjustment,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    ProductAdjustmentType? type,
    num? oldValue,
    num? newValue,
    String? reason,
    String? productId,
    String? productStockId,
    String? productLotId,
    bool? isDeleted,
    DateTime? created,
    DateTime? updated,
  });
  ProductAdjustmentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ProductAdjustmentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ProductAdjustment, $Out>
    implements ProductAdjustmentCopyWith<$R, ProductAdjustment, $Out> {
  _ProductAdjustmentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ProductAdjustment> $mapper =
      ProductAdjustmentMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    ProductAdjustmentType? type,
    num? oldValue,
    num? newValue,
    Object? reason = $none,
    Object? productId = $none,
    Object? productStockId = $none,
    Object? productLotId = $none,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (type != null) #type: type,
      if (oldValue != null) #oldValue: oldValue,
      if (newValue != null) #newValue: newValue,
      if (reason != $none) #reason: reason,
      if (productId != $none) #productId: productId,
      if (productStockId != $none) #productStockId: productStockId,
      if (productLotId != $none) #productLotId: productLotId,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  ProductAdjustment $make(CopyWithData data) => ProductAdjustment(
    id: data.get(#id, or: $value.id),
    type: data.get(#type, or: $value.type),
    oldValue: data.get(#oldValue, or: $value.oldValue),
    newValue: data.get(#newValue, or: $value.newValue),
    reason: data.get(#reason, or: $value.reason),
    productId: data.get(#productId, or: $value.productId),
    productStockId: data.get(#productStockId, or: $value.productStockId),
    productLotId: data.get(#productLotId, or: $value.productLotId),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  ProductAdjustmentCopyWith<$R2, ProductAdjustment, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ProductAdjustmentCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

