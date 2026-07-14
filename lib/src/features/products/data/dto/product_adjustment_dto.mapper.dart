// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'product_adjustment_dto.dart';

class ProductAdjustmentDtoMapper extends ClassMapperBase<ProductAdjustmentDto> {
  ProductAdjustmentDtoMapper._();

  static ProductAdjustmentDtoMapper? _instance;
  static ProductAdjustmentDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ProductAdjustmentDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ProductAdjustmentDto';

  static String _$id(ProductAdjustmentDto v) => v.id;
  static const Field<ProductAdjustmentDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(ProductAdjustmentDto v) => v.collectionId;
  static const Field<ProductAdjustmentDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(ProductAdjustmentDto v) => v.collectionName;
  static const Field<ProductAdjustmentDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$type(ProductAdjustmentDto v) => v.type;
  static const Field<ProductAdjustmentDto, String> _f$type = Field(
    'type',
    _$type,
  );
  static num _$oldValue(ProductAdjustmentDto v) => v.oldValue;
  static const Field<ProductAdjustmentDto, num> _f$oldValue = Field(
    'oldValue',
    _$oldValue,
  );
  static num _$newValue(ProductAdjustmentDto v) => v.newValue;
  static const Field<ProductAdjustmentDto, num> _f$newValue = Field(
    'newValue',
    _$newValue,
  );
  static String? _$reason(ProductAdjustmentDto v) => v.reason;
  static const Field<ProductAdjustmentDto, String> _f$reason = Field(
    'reason',
    _$reason,
    opt: true,
  );
  static String? _$product(ProductAdjustmentDto v) => v.product;
  static const Field<ProductAdjustmentDto, String> _f$product = Field(
    'product',
    _$product,
    opt: true,
  );
  static String? _$productStock(ProductAdjustmentDto v) => v.productStock;
  static const Field<ProductAdjustmentDto, String> _f$productStock = Field(
    'productStock',
    _$productStock,
    opt: true,
  );
  static String? _$productLot(ProductAdjustmentDto v) => v.productLot;
  static const Field<ProductAdjustmentDto, String> _f$productLot = Field(
    'productLot',
    _$productLot,
    opt: true,
  );
  static bool _$isDeleted(ProductAdjustmentDto v) => v.isDeleted;
  static const Field<ProductAdjustmentDto, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static String? _$created(ProductAdjustmentDto v) => v.created;
  static const Field<ProductAdjustmentDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(ProductAdjustmentDto v) => v.updated;
  static const Field<ProductAdjustmentDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<ProductAdjustmentDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #type: _f$type,
    #oldValue: _f$oldValue,
    #newValue: _f$newValue,
    #reason: _f$reason,
    #product: _f$product,
    #productStock: _f$productStock,
    #productLot: _f$productLot,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static ProductAdjustmentDto _instantiate(DecodingData data) {
    return ProductAdjustmentDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      type: data.dec(_f$type),
      oldValue: data.dec(_f$oldValue),
      newValue: data.dec(_f$newValue),
      reason: data.dec(_f$reason),
      product: data.dec(_f$product),
      productStock: data.dec(_f$productStock),
      productLot: data.dec(_f$productLot),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ProductAdjustmentDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ProductAdjustmentDto>(map);
  }

  static ProductAdjustmentDto fromJson(String json) {
    return ensureInitialized().decodeJson<ProductAdjustmentDto>(json);
  }
}

mixin ProductAdjustmentDtoMappable {
  String toJson() {
    return ProductAdjustmentDtoMapper.ensureInitialized()
        .encodeJson<ProductAdjustmentDto>(this as ProductAdjustmentDto);
  }

  Map<String, dynamic> toMap() {
    return ProductAdjustmentDtoMapper.ensureInitialized()
        .encodeMap<ProductAdjustmentDto>(this as ProductAdjustmentDto);
  }

  ProductAdjustmentDtoCopyWith<
    ProductAdjustmentDto,
    ProductAdjustmentDto,
    ProductAdjustmentDto
  >
  get copyWith =>
      _ProductAdjustmentDtoCopyWithImpl<
        ProductAdjustmentDto,
        ProductAdjustmentDto
      >(this as ProductAdjustmentDto, $identity, $identity);
  @override
  String toString() {
    return ProductAdjustmentDtoMapper.ensureInitialized().stringifyValue(
      this as ProductAdjustmentDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return ProductAdjustmentDtoMapper.ensureInitialized().equalsValue(
      this as ProductAdjustmentDto,
      other,
    );
  }

  @override
  int get hashCode {
    return ProductAdjustmentDtoMapper.ensureInitialized().hashValue(
      this as ProductAdjustmentDto,
    );
  }
}

extension ProductAdjustmentDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ProductAdjustmentDto, $Out> {
  ProductAdjustmentDtoCopyWith<$R, ProductAdjustmentDto, $Out>
  get $asProductAdjustmentDto => $base.as(
    (v, t, t2) => _ProductAdjustmentDtoCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class ProductAdjustmentDtoCopyWith<
  $R,
  $In extends ProductAdjustmentDto,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? type,
    num? oldValue,
    num? newValue,
    String? reason,
    String? product,
    String? productStock,
    String? productLot,
    bool? isDeleted,
    String? created,
    String? updated,
  });
  ProductAdjustmentDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ProductAdjustmentDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ProductAdjustmentDto, $Out>
    implements ProductAdjustmentDtoCopyWith<$R, ProductAdjustmentDto, $Out> {
  _ProductAdjustmentDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ProductAdjustmentDto> $mapper =
      ProductAdjustmentDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? type,
    num? oldValue,
    num? newValue,
    Object? reason = $none,
    Object? product = $none,
    Object? productStock = $none,
    Object? productLot = $none,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (type != null) #type: type,
      if (oldValue != null) #oldValue: oldValue,
      if (newValue != null) #newValue: newValue,
      if (reason != $none) #reason: reason,
      if (product != $none) #product: product,
      if (productStock != $none) #productStock: productStock,
      if (productLot != $none) #productLot: productLot,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  ProductAdjustmentDto $make(CopyWithData data) => ProductAdjustmentDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    type: data.get(#type, or: $value.type),
    oldValue: data.get(#oldValue, or: $value.oldValue),
    newValue: data.get(#newValue, or: $value.newValue),
    reason: data.get(#reason, or: $value.reason),
    product: data.get(#product, or: $value.product),
    productStock: data.get(#productStock, or: $value.productStock),
    productLot: data.get(#productLot, or: $value.productLot),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  ProductAdjustmentDtoCopyWith<$R2, ProductAdjustmentDto, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ProductAdjustmentDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

