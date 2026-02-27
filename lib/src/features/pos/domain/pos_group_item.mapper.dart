// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'pos_group_item.dart';

class PosGroupItemMapper extends ClassMapperBase<PosGroupItem> {
  PosGroupItemMapper._();

  static PosGroupItemMapper? _instance;
  static PosGroupItemMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PosGroupItemMapper._());
      ProductMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'PosGroupItem';

  static String _$id(PosGroupItem v) => v.id;
  static const Field<PosGroupItem, String> _f$id = Field(
    'id',
    _$id,
    opt: true,
    def: '',
  );
  static String _$groupId(PosGroupItem v) => v.groupId;
  static const Field<PosGroupItem, String> _f$groupId = Field(
    'groupId',
    _$groupId,
  );
  static String? _$productId(PosGroupItem v) => v.productId;
  static const Field<PosGroupItem, String> _f$productId = Field(
    'productId',
    _$productId,
    opt: true,
  );
  static int _$sortOrder(PosGroupItem v) => v.sortOrder;
  static const Field<PosGroupItem, int> _f$sortOrder = Field(
    'sortOrder',
    _$sortOrder,
    opt: true,
    def: 0,
  );
  static Product? _$product(PosGroupItem v) => v.product;
  static const Field<PosGroupItem, Product> _f$product = Field(
    'product',
    _$product,
    opt: true,
  );
  static DateTime? _$created(PosGroupItem v) => v.created;
  static const Field<PosGroupItem, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(PosGroupItem v) => v.updated;
  static const Field<PosGroupItem, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<PosGroupItem> fields = const {
    #id: _f$id,
    #groupId: _f$groupId,
    #productId: _f$productId,
    #sortOrder: _f$sortOrder,
    #product: _f$product,
    #created: _f$created,
    #updated: _f$updated,
  };

  static PosGroupItem _instantiate(DecodingData data) {
    return PosGroupItem(
      id: data.dec(_f$id),
      groupId: data.dec(_f$groupId),
      productId: data.dec(_f$productId),
      sortOrder: data.dec(_f$sortOrder),
      product: data.dec(_f$product),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static PosGroupItem fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PosGroupItem>(map);
  }

  static PosGroupItem fromJson(String json) {
    return ensureInitialized().decodeJson<PosGroupItem>(json);
  }
}

mixin PosGroupItemMappable {
  String toJson() {
    return PosGroupItemMapper.ensureInitialized().encodeJson<PosGroupItem>(
      this as PosGroupItem,
    );
  }

  Map<String, dynamic> toMap() {
    return PosGroupItemMapper.ensureInitialized().encodeMap<PosGroupItem>(
      this as PosGroupItem,
    );
  }

  PosGroupItemCopyWith<PosGroupItem, PosGroupItem, PosGroupItem> get copyWith =>
      _PosGroupItemCopyWithImpl<PosGroupItem, PosGroupItem>(
        this as PosGroupItem,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PosGroupItemMapper.ensureInitialized().stringifyValue(
      this as PosGroupItem,
    );
  }

  @override
  bool operator ==(Object other) {
    return PosGroupItemMapper.ensureInitialized().equalsValue(
      this as PosGroupItem,
      other,
    );
  }

  @override
  int get hashCode {
    return PosGroupItemMapper.ensureInitialized().hashValue(
      this as PosGroupItem,
    );
  }
}

extension PosGroupItemValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PosGroupItem, $Out> {
  PosGroupItemCopyWith<$R, PosGroupItem, $Out> get $asPosGroupItem =>
      $base.as((v, t, t2) => _PosGroupItemCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PosGroupItemCopyWith<$R, $In extends PosGroupItem, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ProductCopyWith<$R, Product, Product>? get product;
  $R call({
    String? id,
    String? groupId,
    String? productId,
    int? sortOrder,
    Product? product,
    DateTime? created,
    DateTime? updated,
  });
  PosGroupItemCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PosGroupItemCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PosGroupItem, $Out>
    implements PosGroupItemCopyWith<$R, PosGroupItem, $Out> {
  _PosGroupItemCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PosGroupItem> $mapper =
      PosGroupItemMapper.ensureInitialized();
  @override
  ProductCopyWith<$R, Product, Product>? get product =>
      $value.product?.copyWith.$chain((v) => call(product: v));
  @override
  $R call({
    String? id,
    String? groupId,
    Object? productId = $none,
    int? sortOrder,
    Object? product = $none,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (groupId != null) #groupId: groupId,
      if (productId != $none) #productId: productId,
      if (sortOrder != null) #sortOrder: sortOrder,
      if (product != $none) #product: product,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  PosGroupItem $make(CopyWithData data) => PosGroupItem(
    id: data.get(#id, or: $value.id),
    groupId: data.get(#groupId, or: $value.groupId),
    productId: data.get(#productId, or: $value.productId),
    sortOrder: data.get(#sortOrder, or: $value.sortOrder),
    product: data.get(#product, or: $value.product),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  PosGroupItemCopyWith<$R2, PosGroupItem, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PosGroupItemCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

