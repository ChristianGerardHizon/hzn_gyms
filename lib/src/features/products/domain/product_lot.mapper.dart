// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'product_lot.dart';

class ProductLotMapper extends ClassMapperBase<ProductLot> {
  ProductLotMapper._();

  static ProductLotMapper? _instance;
  static ProductLotMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ProductLotMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ProductLot';

  static String _$id(ProductLot v) => v.id;
  static const Field<ProductLot, String> _f$id = Field('id', _$id);
  static String _$productId(ProductLot v) => v.productId;
  static const Field<ProductLot, String> _f$productId = Field(
    'productId',
    _$productId,
  );
  static String _$lotNumber(ProductLot v) => v.lotNumber;
  static const Field<ProductLot, String> _f$lotNumber = Field(
    'lotNumber',
    _$lotNumber,
  );
  static num _$quantity(ProductLot v) => v.quantity;
  static const Field<ProductLot, num> _f$quantity = Field(
    'quantity',
    _$quantity,
    opt: true,
    def: 0,
  );
  static DateTime? _$expiration(ProductLot v) => v.expiration;
  static const Field<ProductLot, DateTime> _f$expiration = Field(
    'expiration',
    _$expiration,
    opt: true,
  );
  static String? _$notes(ProductLot v) => v.notes;
  static const Field<ProductLot, String> _f$notes = Field(
    'notes',
    _$notes,
    opt: true,
  );
  static bool _$isDeleted(ProductLot v) => v.isDeleted;
  static const Field<ProductLot, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static DateTime? _$created(ProductLot v) => v.created;
  static const Field<ProductLot, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(ProductLot v) => v.updated;
  static const Field<ProductLot, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<ProductLot> fields = const {
    #id: _f$id,
    #productId: _f$productId,
    #lotNumber: _f$lotNumber,
    #quantity: _f$quantity,
    #expiration: _f$expiration,
    #notes: _f$notes,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static ProductLot _instantiate(DecodingData data) {
    return ProductLot(
      id: data.dec(_f$id),
      productId: data.dec(_f$productId),
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

  static ProductLot fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ProductLot>(map);
  }

  static ProductLot fromJson(String json) {
    return ensureInitialized().decodeJson<ProductLot>(json);
  }
}

mixin ProductLotMappable {
  String toJson() {
    return ProductLotMapper.ensureInitialized().encodeJson<ProductLot>(
      this as ProductLot,
    );
  }

  Map<String, dynamic> toMap() {
    return ProductLotMapper.ensureInitialized().encodeMap<ProductLot>(
      this as ProductLot,
    );
  }

  ProductLotCopyWith<ProductLot, ProductLot, ProductLot> get copyWith =>
      _ProductLotCopyWithImpl<ProductLot, ProductLot>(
        this as ProductLot,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ProductLotMapper.ensureInitialized().stringifyValue(
      this as ProductLot,
    );
  }

  @override
  bool operator ==(Object other) {
    return ProductLotMapper.ensureInitialized().equalsValue(
      this as ProductLot,
      other,
    );
  }

  @override
  int get hashCode {
    return ProductLotMapper.ensureInitialized().hashValue(this as ProductLot);
  }
}

extension ProductLotValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ProductLot, $Out> {
  ProductLotCopyWith<$R, ProductLot, $Out> get $asProductLot =>
      $base.as((v, t, t2) => _ProductLotCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ProductLotCopyWith<$R, $In extends ProductLot, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? productId,
    String? lotNumber,
    num? quantity,
    DateTime? expiration,
    String? notes,
    bool? isDeleted,
    DateTime? created,
    DateTime? updated,
  });
  ProductLotCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ProductLotCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ProductLot, $Out>
    implements ProductLotCopyWith<$R, ProductLot, $Out> {
  _ProductLotCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ProductLot> $mapper =
      ProductLotMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? productId,
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
      if (productId != null) #productId: productId,
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
  ProductLot $make(CopyWithData data) => ProductLot(
    id: data.get(#id, or: $value.id),
    productId: data.get(#productId, or: $value.productId),
    lotNumber: data.get(#lotNumber, or: $value.lotNumber),
    quantity: data.get(#quantity, or: $value.quantity),
    expiration: data.get(#expiration, or: $value.expiration),
    notes: data.get(#notes, or: $value.notes),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  ProductLotCopyWith<$R2, ProductLot, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ProductLotCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

