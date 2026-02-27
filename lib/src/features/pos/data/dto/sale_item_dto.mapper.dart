// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'sale_item_dto.dart';

class SaleItemDtoMapper extends ClassMapperBase<SaleItemDto> {
  SaleItemDtoMapper._();

  static SaleItemDtoMapper? _instance;
  static SaleItemDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SaleItemDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'SaleItemDto';

  static String _$id(SaleItemDto v) => v.id;
  static const Field<SaleItemDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(SaleItemDto v) => v.collectionId;
  static const Field<SaleItemDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(SaleItemDto v) => v.collectionName;
  static const Field<SaleItemDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$sale(SaleItemDto v) => v.sale;
  static const Field<SaleItemDto, String> _f$sale = Field('sale', _$sale);
  static String _$product(SaleItemDto v) => v.product;
  static const Field<SaleItemDto, String> _f$product = Field(
    'product',
    _$product,
  );
  static String _$productName(SaleItemDto v) => v.productName;
  static const Field<SaleItemDto, String> _f$productName = Field(
    'productName',
    _$productName,
  );
  static num _$quantity(SaleItemDto v) => v.quantity;
  static const Field<SaleItemDto, num> _f$quantity = Field(
    'quantity',
    _$quantity,
  );
  static num _$unitPrice(SaleItemDto v) => v.unitPrice;
  static const Field<SaleItemDto, num> _f$unitPrice = Field(
    'unitPrice',
    _$unitPrice,
  );
  static num _$subtotal(SaleItemDto v) => v.subtotal;
  static const Field<SaleItemDto, num> _f$subtotal = Field(
    'subtotal',
    _$subtotal,
  );
  static String? _$productLot(SaleItemDto v) => v.productLot;
  static const Field<SaleItemDto, String> _f$productLot = Field(
    'productLot',
    _$productLot,
    opt: true,
  );
  static String? _$lotNumber(SaleItemDto v) => v.lotNumber;
  static const Field<SaleItemDto, String> _f$lotNumber = Field(
    'lotNumber',
    _$lotNumber,
    opt: true,
  );
  static String? _$itemType(SaleItemDto v) => v.itemType;
  static const Field<SaleItemDto, String> _f$itemType = Field(
    'itemType',
    _$itemType,
    opt: true,
  );
  static String? _$created(SaleItemDto v) => v.created;
  static const Field<SaleItemDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(SaleItemDto v) => v.updated;
  static const Field<SaleItemDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<SaleItemDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #sale: _f$sale,
    #product: _f$product,
    #productName: _f$productName,
    #quantity: _f$quantity,
    #unitPrice: _f$unitPrice,
    #subtotal: _f$subtotal,
    #productLot: _f$productLot,
    #lotNumber: _f$lotNumber,
    #itemType: _f$itemType,
    #created: _f$created,
    #updated: _f$updated,
  };

  static SaleItemDto _instantiate(DecodingData data) {
    return SaleItemDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      sale: data.dec(_f$sale),
      product: data.dec(_f$product),
      productName: data.dec(_f$productName),
      quantity: data.dec(_f$quantity),
      unitPrice: data.dec(_f$unitPrice),
      subtotal: data.dec(_f$subtotal),
      productLot: data.dec(_f$productLot),
      lotNumber: data.dec(_f$lotNumber),
      itemType: data.dec(_f$itemType),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static SaleItemDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SaleItemDto>(map);
  }

  static SaleItemDto fromJson(String json) {
    return ensureInitialized().decodeJson<SaleItemDto>(json);
  }
}

mixin SaleItemDtoMappable {
  String toJson() {
    return SaleItemDtoMapper.ensureInitialized().encodeJson<SaleItemDto>(
      this as SaleItemDto,
    );
  }

  Map<String, dynamic> toMap() {
    return SaleItemDtoMapper.ensureInitialized().encodeMap<SaleItemDto>(
      this as SaleItemDto,
    );
  }

  SaleItemDtoCopyWith<SaleItemDto, SaleItemDto, SaleItemDto> get copyWith =>
      _SaleItemDtoCopyWithImpl<SaleItemDto, SaleItemDto>(
        this as SaleItemDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return SaleItemDtoMapper.ensureInitialized().stringifyValue(
      this as SaleItemDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return SaleItemDtoMapper.ensureInitialized().equalsValue(
      this as SaleItemDto,
      other,
    );
  }

  @override
  int get hashCode {
    return SaleItemDtoMapper.ensureInitialized().hashValue(this as SaleItemDto);
  }
}

extension SaleItemDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, SaleItemDto, $Out> {
  SaleItemDtoCopyWith<$R, SaleItemDto, $Out> get $asSaleItemDto =>
      $base.as((v, t, t2) => _SaleItemDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class SaleItemDtoCopyWith<$R, $In extends SaleItemDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? sale,
    String? product,
    String? productName,
    num? quantity,
    num? unitPrice,
    num? subtotal,
    String? productLot,
    String? lotNumber,
    String? itemType,
    String? created,
    String? updated,
  });
  SaleItemDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _SaleItemDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, SaleItemDto, $Out>
    implements SaleItemDtoCopyWith<$R, SaleItemDto, $Out> {
  _SaleItemDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SaleItemDto> $mapper =
      SaleItemDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? sale,
    String? product,
    String? productName,
    num? quantity,
    num? unitPrice,
    num? subtotal,
    Object? productLot = $none,
    Object? lotNumber = $none,
    Object? itemType = $none,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (sale != null) #sale: sale,
      if (product != null) #product: product,
      if (productName != null) #productName: productName,
      if (quantity != null) #quantity: quantity,
      if (unitPrice != null) #unitPrice: unitPrice,
      if (subtotal != null) #subtotal: subtotal,
      if (productLot != $none) #productLot: productLot,
      if (lotNumber != $none) #lotNumber: lotNumber,
      if (itemType != $none) #itemType: itemType,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  SaleItemDto $make(CopyWithData data) => SaleItemDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    sale: data.get(#sale, or: $value.sale),
    product: data.get(#product, or: $value.product),
    productName: data.get(#productName, or: $value.productName),
    quantity: data.get(#quantity, or: $value.quantity),
    unitPrice: data.get(#unitPrice, or: $value.unitPrice),
    subtotal: data.get(#subtotal, or: $value.subtotal),
    productLot: data.get(#productLot, or: $value.productLot),
    lotNumber: data.get(#lotNumber, or: $value.lotNumber),
    itemType: data.get(#itemType, or: $value.itemType),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  SaleItemDtoCopyWith<$R2, SaleItemDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _SaleItemDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

