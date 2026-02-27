// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'sale_item.dart';

class SaleItemMapper extends ClassMapperBase<SaleItem> {
  SaleItemMapper._();

  static SaleItemMapper? _instance;
  static SaleItemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SaleItemMapper._());
      ProductMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'SaleItem';

  static String _$id(SaleItem v) => v.id;
  static const Field<SaleItem, String> _f$id = Field('id', _$id);
  static String _$saleId(SaleItem v) => v.saleId;
  static const Field<SaleItem, String> _f$saleId = Field('saleId', _$saleId);
  static String _$productId(SaleItem v) => v.productId;
  static const Field<SaleItem, String> _f$productId = Field(
    'productId',
    _$productId,
  );
  static String _$productName(SaleItem v) => v.productName;
  static const Field<SaleItem, String> _f$productName = Field(
    'productName',
    _$productName,
  );
  static num _$quantity(SaleItem v) => v.quantity;
  static const Field<SaleItem, num> _f$quantity = Field('quantity', _$quantity);
  static num _$unitPrice(SaleItem v) => v.unitPrice;
  static const Field<SaleItem, num> _f$unitPrice = Field(
    'unitPrice',
    _$unitPrice,
  );
  static num _$subtotal(SaleItem v) => v.subtotal;
  static const Field<SaleItem, num> _f$subtotal = Field('subtotal', _$subtotal);
  static Product? _$product(SaleItem v) => v.product;
  static const Field<SaleItem, Product> _f$product = Field(
    'product',
    _$product,
    opt: true,
  );
  static String? _$productLotId(SaleItem v) => v.productLotId;
  static const Field<SaleItem, String> _f$productLotId = Field(
    'productLotId',
    _$productLotId,
    opt: true,
  );
  static String? _$lotNumber(SaleItem v) => v.lotNumber;
  static const Field<SaleItem, String> _f$lotNumber = Field(
    'lotNumber',
    _$lotNumber,
    opt: true,
  );
  static String? _$itemType(SaleItem v) => v.itemType;
  static const Field<SaleItem, String> _f$itemType = Field(
    'itemType',
    _$itemType,
    opt: true,
  );
  static DateTime? _$created(SaleItem v) => v.created;
  static const Field<SaleItem, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(SaleItem v) => v.updated;
  static const Field<SaleItem, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<SaleItem> fields = const {
    #id: _f$id,
    #saleId: _f$saleId,
    #productId: _f$productId,
    #productName: _f$productName,
    #quantity: _f$quantity,
    #unitPrice: _f$unitPrice,
    #subtotal: _f$subtotal,
    #product: _f$product,
    #productLotId: _f$productLotId,
    #lotNumber: _f$lotNumber,
    #itemType: _f$itemType,
    #created: _f$created,
    #updated: _f$updated,
  };

  static SaleItem _instantiate(DecodingData data) {
    return SaleItem(
      id: data.dec(_f$id),
      saleId: data.dec(_f$saleId),
      productId: data.dec(_f$productId),
      productName: data.dec(_f$productName),
      quantity: data.dec(_f$quantity),
      unitPrice: data.dec(_f$unitPrice),
      subtotal: data.dec(_f$subtotal),
      product: data.dec(_f$product),
      productLotId: data.dec(_f$productLotId),
      lotNumber: data.dec(_f$lotNumber),
      itemType: data.dec(_f$itemType),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static SaleItem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SaleItem>(map);
  }

  static SaleItem fromJson(String json) {
    return ensureInitialized().decodeJson<SaleItem>(json);
  }
}

mixin SaleItemMappable {
  String toJson() {
    return SaleItemMapper.ensureInitialized().encodeJson<SaleItem>(
      this as SaleItem,
    );
  }

  Map<String, dynamic> toMap() {
    return SaleItemMapper.ensureInitialized().encodeMap<SaleItem>(
      this as SaleItem,
    );
  }

  SaleItemCopyWith<SaleItem, SaleItem, SaleItem> get copyWith =>
      _SaleItemCopyWithImpl<SaleItem, SaleItem>(
        this as SaleItem,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return SaleItemMapper.ensureInitialized().stringifyValue(this as SaleItem);
  }

  @override
  bool operator ==(Object other) {
    return SaleItemMapper.ensureInitialized().equalsValue(
      this as SaleItem,
      other,
    );
  }

  @override
  int get hashCode {
    return SaleItemMapper.ensureInitialized().hashValue(this as SaleItem);
  }
}

extension SaleItemValueCopy<$R, $Out> on ObjectCopyWith<$R, SaleItem, $Out> {
  SaleItemCopyWith<$R, SaleItem, $Out> get $asSaleItem =>
      $base.as((v, t, t2) => _SaleItemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class SaleItemCopyWith<$R, $In extends SaleItem, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ProductCopyWith<$R, Product, Product>? get product;
  $R call({
    String? id,
    String? saleId,
    String? productId,
    String? productName,
    num? quantity,
    num? unitPrice,
    num? subtotal,
    Product? product,
    String? productLotId,
    String? lotNumber,
    String? itemType,
    DateTime? created,
    DateTime? updated,
  });
  SaleItemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _SaleItemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, SaleItem, $Out>
    implements SaleItemCopyWith<$R, SaleItem, $Out> {
  _SaleItemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SaleItem> $mapper =
      SaleItemMapper.ensureInitialized();
  @override
  ProductCopyWith<$R, Product, Product>? get product =>
      $value.product?.copyWith.$chain((v) => call(product: v));
  @override
  $R call({
    String? id,
    String? saleId,
    String? productId,
    String? productName,
    num? quantity,
    num? unitPrice,
    num? subtotal,
    Object? product = $none,
    Object? productLotId = $none,
    Object? lotNumber = $none,
    Object? itemType = $none,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (saleId != null) #saleId: saleId,
      if (productId != null) #productId: productId,
      if (productName != null) #productName: productName,
      if (quantity != null) #quantity: quantity,
      if (unitPrice != null) #unitPrice: unitPrice,
      if (subtotal != null) #subtotal: subtotal,
      if (product != $none) #product: product,
      if (productLotId != $none) #productLotId: productLotId,
      if (lotNumber != $none) #lotNumber: lotNumber,
      if (itemType != $none) #itemType: itemType,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  SaleItem $make(CopyWithData data) => SaleItem(
    id: data.get(#id, or: $value.id),
    saleId: data.get(#saleId, or: $value.saleId),
    productId: data.get(#productId, or: $value.productId),
    productName: data.get(#productName, or: $value.productName),
    quantity: data.get(#quantity, or: $value.quantity),
    unitPrice: data.get(#unitPrice, or: $value.unitPrice),
    subtotal: data.get(#subtotal, or: $value.subtotal),
    product: data.get(#product, or: $value.product),
    productLotId: data.get(#productLotId, or: $value.productLotId),
    lotNumber: data.get(#lotNumber, or: $value.lotNumber),
    itemType: data.get(#itemType, or: $value.itemType),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  SaleItemCopyWith<$R2, SaleItem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _SaleItemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

