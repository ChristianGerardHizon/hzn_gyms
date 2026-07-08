// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'product.dart';

class ProductMapper extends ClassMapperBase<Product> {
  ProductMapper._();

  static ProductMapper? _instance;
  static ProductMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ProductMapper._());
      QuantityUnitMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Product';

  static String _$id(Product v) => v.id;
  static const Field<Product, String> _f$id = Field('id', _$id);
  static String _$name(Product v) => v.name;
  static const Field<Product, String> _f$name = Field('name', _$name);
  static String? _$description(Product v) => v.description;
  static const Field<Product, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );
  static String? _$categoryId(Product v) => v.categoryId;
  static const Field<Product, String> _f$categoryId = Field(
    'categoryId',
    _$categoryId,
    opt: true,
  );
  static String? _$categoryName(Product v) => v.categoryName;
  static const Field<Product, String> _f$categoryName = Field(
    'categoryName',
    _$categoryName,
    opt: true,
  );
  static String? _$image(Product v) => v.image;
  static const Field<Product, String> _f$image = Field(
    'image',
    _$image,
    opt: true,
  );
  static String? _$branch(Product v) => v.branch;
  static const Field<Product, String> _f$branch = Field(
    'branch',
    _$branch,
    opt: true,
  );
  static num? _$stockThreshold(Product v) => v.stockThreshold;
  static const Field<Product, num> _f$stockThreshold = Field(
    'stockThreshold',
    _$stockThreshold,
    opt: true,
  );
  static num _$price(Product v) => v.price;
  static const Field<Product, num> _f$price = Field(
    'price',
    _$price,
    opt: true,
    def: 0,
  );
  static bool _$forSale(Product v) => v.forSale;
  static const Field<Product, bool> _f$forSale = Field(
    'forSale',
    _$forSale,
    opt: true,
    def: true,
  );
  static bool _$trackStock(Product v) => v.trackStock;
  static const Field<Product, bool> _f$trackStock = Field(
    'trackStock',
    _$trackStock,
    opt: true,
    def: false,
  );
  static bool _$requireStock(Product v) => v.requireStock;
  static const Field<Product, bool> _f$requireStock = Field(
    'requireStock',
    _$requireStock,
    opt: true,
    def: false,
  );
  static num? _$quantity(Product v) => v.quantity;
  static const Field<Product, num> _f$quantity = Field(
    'quantity',
    _$quantity,
    opt: true,
  );
  static DateTime? _$expiration(Product v) => v.expiration;
  static const Field<Product, DateTime> _f$expiration = Field(
    'expiration',
    _$expiration,
    opt: true,
  );
  static bool _$trackByLot(Product v) => v.trackByLot;
  static const Field<Product, bool> _f$trackByLot = Field(
    'trackByLot',
    _$trackByLot,
    opt: true,
    def: false,
  );
  static String? _$quantityUnitId(Product v) => v.quantityUnitId;
  static const Field<Product, String> _f$quantityUnitId = Field(
    'quantityUnitId',
    _$quantityUnitId,
    opt: true,
  );
  static QuantityUnit? _$quantityUnit(Product v) => v.quantityUnit;
  static const Field<Product, QuantityUnit> _f$quantityUnit = Field(
    'quantityUnit',
    _$quantityUnit,
    opt: true,
  );
  static bool _$isDeleted(Product v) => v.isDeleted;
  static const Field<Product, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static DateTime? _$created(Product v) => v.created;
  static const Field<Product, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(Product v) => v.updated;
  static const Field<Product, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<Product> fields = const {
    #id: _f$id,
    #name: _f$name,
    #description: _f$description,
    #categoryId: _f$categoryId,
    #categoryName: _f$categoryName,
    #image: _f$image,
    #branch: _f$branch,
    #stockThreshold: _f$stockThreshold,
    #price: _f$price,
    #forSale: _f$forSale,
    #trackStock: _f$trackStock,
    #requireStock: _f$requireStock,
    #quantity: _f$quantity,
    #expiration: _f$expiration,
    #trackByLot: _f$trackByLot,
    #quantityUnitId: _f$quantityUnitId,
    #quantityUnit: _f$quantityUnit,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static Product _instantiate(DecodingData data) {
    return Product(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      description: data.dec(_f$description),
      categoryId: data.dec(_f$categoryId),
      categoryName: data.dec(_f$categoryName),
      image: data.dec(_f$image),
      branch: data.dec(_f$branch),
      stockThreshold: data.dec(_f$stockThreshold),
      price: data.dec(_f$price),
      forSale: data.dec(_f$forSale),
      trackStock: data.dec(_f$trackStock),
      requireStock: data.dec(_f$requireStock),
      quantity: data.dec(_f$quantity),
      expiration: data.dec(_f$expiration),
      trackByLot: data.dec(_f$trackByLot),
      quantityUnitId: data.dec(_f$quantityUnitId),
      quantityUnit: data.dec(_f$quantityUnit),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Product fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Product>(map);
  }

  static Product fromJson(String json) {
    return ensureInitialized().decodeJson<Product>(json);
  }
}

mixin ProductMappable {
  String toJson() {
    return ProductMapper.ensureInitialized().encodeJson<Product>(
      this as Product,
    );
  }

  Map<String, dynamic> toMap() {
    return ProductMapper.ensureInitialized().encodeMap<Product>(
      this as Product,
    );
  }

  ProductCopyWith<Product, Product, Product> get copyWith =>
      _ProductCopyWithImpl<Product, Product>(
        this as Product,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ProductMapper.ensureInitialized().stringifyValue(this as Product);
  }

  @override
  bool operator ==(Object other) {
    return ProductMapper.ensureInitialized().equalsValue(
      this as Product,
      other,
    );
  }

  @override
  int get hashCode {
    return ProductMapper.ensureInitialized().hashValue(this as Product);
  }
}

extension ProductValueCopy<$R, $Out> on ObjectCopyWith<$R, Product, $Out> {
  ProductCopyWith<$R, Product, $Out> get $asProduct =>
      $base.as((v, t, t2) => _ProductCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ProductCopyWith<$R, $In extends Product, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  QuantityUnitCopyWith<$R, QuantityUnit, QuantityUnit>? get quantityUnit;
  $R call({
    String? id,
    String? name,
    String? description,
    String? categoryId,
    String? categoryName,
    String? image,
    String? branch,
    num? stockThreshold,
    num? price,
    bool? forSale,
    bool? trackStock,
    bool? requireStock,
    num? quantity,
    DateTime? expiration,
    bool? trackByLot,
    String? quantityUnitId,
    QuantityUnit? quantityUnit,
    bool? isDeleted,
    DateTime? created,
    DateTime? updated,
  });
  ProductCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ProductCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Product, $Out>
    implements ProductCopyWith<$R, Product, $Out> {
  _ProductCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Product> $mapper =
      ProductMapper.ensureInitialized();
  @override
  QuantityUnitCopyWith<$R, QuantityUnit, QuantityUnit>? get quantityUnit =>
      $value.quantityUnit?.copyWith.$chain((v) => call(quantityUnit: v));
  @override
  $R call({
    String? id,
    String? name,
    Object? description = $none,
    Object? categoryId = $none,
    Object? categoryName = $none,
    Object? image = $none,
    Object? branch = $none,
    Object? stockThreshold = $none,
    num? price,
    bool? forSale,
    bool? trackStock,
    bool? requireStock,
    Object? quantity = $none,
    Object? expiration = $none,
    bool? trackByLot,
    Object? quantityUnitId = $none,
    Object? quantityUnit = $none,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (description != $none) #description: description,
      if (categoryId != $none) #categoryId: categoryId,
      if (categoryName != $none) #categoryName: categoryName,
      if (image != $none) #image: image,
      if (branch != $none) #branch: branch,
      if (stockThreshold != $none) #stockThreshold: stockThreshold,
      if (price != null) #price: price,
      if (forSale != null) #forSale: forSale,
      if (trackStock != null) #trackStock: trackStock,
      if (requireStock != null) #requireStock: requireStock,
      if (quantity != $none) #quantity: quantity,
      if (expiration != $none) #expiration: expiration,
      if (trackByLot != null) #trackByLot: trackByLot,
      if (quantityUnitId != $none) #quantityUnitId: quantityUnitId,
      if (quantityUnit != $none) #quantityUnit: quantityUnit,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  Product $make(CopyWithData data) => Product(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    description: data.get(#description, or: $value.description),
    categoryId: data.get(#categoryId, or: $value.categoryId),
    categoryName: data.get(#categoryName, or: $value.categoryName),
    image: data.get(#image, or: $value.image),
    branch: data.get(#branch, or: $value.branch),
    stockThreshold: data.get(#stockThreshold, or: $value.stockThreshold),
    price: data.get(#price, or: $value.price),
    forSale: data.get(#forSale, or: $value.forSale),
    trackStock: data.get(#trackStock, or: $value.trackStock),
    requireStock: data.get(#requireStock, or: $value.requireStock),
    quantity: data.get(#quantity, or: $value.quantity),
    expiration: data.get(#expiration, or: $value.expiration),
    trackByLot: data.get(#trackByLot, or: $value.trackByLot),
    quantityUnitId: data.get(#quantityUnitId, or: $value.quantityUnitId),
    quantityUnit: data.get(#quantityUnit, or: $value.quantityUnit),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  ProductCopyWith<$R2, Product, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ProductCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

