// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'product_lot_dto.dart';

class ProductLotDtoMapper extends ClassMapperBase<ProductLotDto> {
  ProductLotDtoMapper._();

  static ProductLotDtoMapper? _instance;
  static ProductLotDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ProductLotDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ProductLotDto';

  static String _$id(ProductLotDto v) => v.id;
  static const Field<ProductLotDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(ProductLotDto v) => v.collectionId;
  static const Field<ProductLotDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(ProductLotDto v) => v.collectionName;
  static const Field<ProductLotDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$product(ProductLotDto v) => v.product;
  static const Field<ProductLotDto, String> _f$product = Field(
    'product',
    _$product,
  );
  static String _$lotNumber(ProductLotDto v) => v.lotNumber;
  static const Field<ProductLotDto, String> _f$lotNumber = Field(
    'lotNumber',
    _$lotNumber,
  );
  static num _$quantity(ProductLotDto v) => v.quantity;
  static const Field<ProductLotDto, num> _f$quantity = Field(
    'quantity',
    _$quantity,
    opt: true,
    def: 0,
  );
  static String? _$expiration(ProductLotDto v) => v.expiration;
  static const Field<ProductLotDto, String> _f$expiration = Field(
    'expiration',
    _$expiration,
    opt: true,
  );
  static String? _$notes(ProductLotDto v) => v.notes;
  static const Field<ProductLotDto, String> _f$notes = Field(
    'notes',
    _$notes,
    opt: true,
  );
  static bool _$isDeleted(ProductLotDto v) => v.isDeleted;
  static const Field<ProductLotDto, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static String? _$created(ProductLotDto v) => v.created;
  static const Field<ProductLotDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(ProductLotDto v) => v.updated;
  static const Field<ProductLotDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<ProductLotDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #product: _f$product,
    #lotNumber: _f$lotNumber,
    #quantity: _f$quantity,
    #expiration: _f$expiration,
    #notes: _f$notes,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static ProductLotDto _instantiate(DecodingData data) {
    return ProductLotDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      product: data.dec(_f$product),
      lotNumber: data.dec(_f$lotNumber),
      quantity: data.dec(_f$quantity),
      expiration: data.dec(_f$expiration),
      notes: data.dec(_f$notes),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ProductLotDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ProductLotDto>(map);
  }

  static ProductLotDto fromJson(String json) {
    return ensureInitialized().decodeJson<ProductLotDto>(json);
  }
}

mixin ProductLotDtoMappable {
  String toJson() {
    return ProductLotDtoMapper.ensureInitialized().encodeJson<ProductLotDto>(
      this as ProductLotDto,
    );
  }

  Map<String, dynamic> toMap() {
    return ProductLotDtoMapper.ensureInitialized().encodeMap<ProductLotDto>(
      this as ProductLotDto,
    );
  }

  ProductLotDtoCopyWith<ProductLotDto, ProductLotDto, ProductLotDto>
  get copyWith => _ProductLotDtoCopyWithImpl<ProductLotDto, ProductLotDto>(
    this as ProductLotDto,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return ProductLotDtoMapper.ensureInitialized().stringifyValue(
      this as ProductLotDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return ProductLotDtoMapper.ensureInitialized().equalsValue(
      this as ProductLotDto,
      other,
    );
  }

  @override
  int get hashCode {
    return ProductLotDtoMapper.ensureInitialized().hashValue(
      this as ProductLotDto,
    );
  }
}

extension ProductLotDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ProductLotDto, $Out> {
  ProductLotDtoCopyWith<$R, ProductLotDto, $Out> get $asProductLotDto =>
      $base.as((v, t, t2) => _ProductLotDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ProductLotDtoCopyWith<$R, $In extends ProductLotDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? product,
    String? lotNumber,
    num? quantity,
    String? expiration,
    String? notes,
    bool? isDeleted,
    String? created,
    String? updated,
  });
  ProductLotDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ProductLotDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ProductLotDto, $Out>
    implements ProductLotDtoCopyWith<$R, ProductLotDto, $Out> {
  _ProductLotDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ProductLotDto> $mapper =
      ProductLotDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? product,
    String? lotNumber,
    num? quantity,
    Object? expiration = $none,
    Object? notes = $none,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (product != null) #product: product,
      if (lotNumber != null) #lotNumber: lotNumber,
      if (quantity != null) #quantity: quantity,
      if (expiration != $none) #expiration: expiration,
      if (notes != $none) #notes: notes,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  ProductLotDto $make(CopyWithData data) => ProductLotDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    product: data.get(#product, or: $value.product),
    lotNumber: data.get(#lotNumber, or: $value.lotNumber),
    quantity: data.get(#quantity, or: $value.quantity),
    expiration: data.get(#expiration, or: $value.expiration),
    notes: data.get(#notes, or: $value.notes),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  ProductLotDtoCopyWith<$R2, ProductLotDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ProductLotDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

