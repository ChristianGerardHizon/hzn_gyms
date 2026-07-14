// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'product_dto.dart';

class ProductDtoMapper extends ClassMapperBase<ProductDto> {
  ProductDtoMapper._();

  static ProductDtoMapper? _instance;
  static ProductDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ProductDtoMapper._());
      QuantityUnitMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ProductDto';

  static String _$id(ProductDto v) => v.id;
  static const Field<ProductDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(ProductDto v) => v.collectionId;
  static const Field<ProductDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(ProductDto v) => v.collectionName;
  static const Field<ProductDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$name(ProductDto v) => v.name;
  static const Field<ProductDto, String> _f$name = Field('name', _$name);
  static String? _$description(ProductDto v) => v.description;
  static const Field<ProductDto, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );
  static String? _$category(ProductDto v) => v.category;
  static const Field<ProductDto, String> _f$category = Field(
    'category',
    _$category,
    opt: true,
  );
  static String? _$categoryName(ProductDto v) => v.categoryName;
  static const Field<ProductDto, String> _f$categoryName = Field(
    'categoryName',
    _$categoryName,
    opt: true,
  );
  static String? _$image(ProductDto v) => v.image;
  static const Field<ProductDto, String> _f$image = Field(
    'image',
    _$image,
    opt: true,
  );
  static String? _$branch(ProductDto v) => v.branch;
  static const Field<ProductDto, String> _f$branch = Field(
    'branch',
    _$branch,
    opt: true,
  );
  static num? _$stockThreshold(ProductDto v) => v.stockThreshold;
  static const Field<ProductDto, num> _f$stockThreshold = Field(
    'stockThreshold',
    _$stockThreshold,
    opt: true,
  );
  static num _$price(ProductDto v) => v.price;
  static const Field<ProductDto, num> _f$price = Field(
    'price',
    _$price,
    opt: true,
    def: 0,
  );
  static bool _$forSale(ProductDto v) => v.forSale;
  static const Field<ProductDto, bool> _f$forSale = Field(
    'forSale',
    _$forSale,
    opt: true,
    def: true,
  );
  static bool _$trackStock(ProductDto v) => v.trackStock;
  static const Field<ProductDto, bool> _f$trackStock = Field(
    'trackStock',
    _$trackStock,
    opt: true,
    def: false,
  );
  static bool _$requireStock(ProductDto v) => v.requireStock;
  static const Field<ProductDto, bool> _f$requireStock = Field(
    'requireStock',
    _$requireStock,
    opt: true,
    def: false,
  );
  static num? _$quantity(ProductDto v) => v.quantity;
  static const Field<ProductDto, num> _f$quantity = Field(
    'quantity',
    _$quantity,
    opt: true,
  );
  static String? _$expiration(ProductDto v) => v.expiration;
  static const Field<ProductDto, String> _f$expiration = Field(
    'expiration',
    _$expiration,
    opt: true,
  );
  static bool _$trackByLot(ProductDto v) => v.trackByLot;
  static const Field<ProductDto, bool> _f$trackByLot = Field(
    'trackByLot',
    _$trackByLot,
    opt: true,
    def: false,
  );
  static String? _$quantityUnit(ProductDto v) => v.quantityUnit;
  static const Field<ProductDto, String> _f$quantityUnit = Field(
    'quantityUnit',
    _$quantityUnit,
    opt: true,
  );
  static QuantityUnit? _$quantityUnitExpanded(ProductDto v) =>
      v.quantityUnitExpanded;
  static const Field<ProductDto, QuantityUnit> _f$quantityUnitExpanded = Field(
    'quantityUnitExpanded',
    _$quantityUnitExpanded,
    opt: true,
  );
  static bool _$isDeleted(ProductDto v) => v.isDeleted;
  static const Field<ProductDto, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static String? _$created(ProductDto v) => v.created;
  static const Field<ProductDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(ProductDto v) => v.updated;
  static const Field<ProductDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<ProductDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #name: _f$name,
    #description: _f$description,
    #category: _f$category,
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
    #quantityUnit: _f$quantityUnit,
    #quantityUnitExpanded: _f$quantityUnitExpanded,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static ProductDto _instantiate(DecodingData data) {
    return ProductDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      name: data.dec(_f$name),
      description: data.dec(_f$description),
      category: data.dec(_f$category),
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
      quantityUnit: data.dec(_f$quantityUnit),
      quantityUnitExpanded: data.dec(_f$quantityUnitExpanded),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ProductDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ProductDto>(map);
  }

  static ProductDto fromJson(String json) {
    return ensureInitialized().decodeJson<ProductDto>(json);
  }
}

mixin ProductDtoMappable {
  String toJson() {
    return ProductDtoMapper.ensureInitialized().encodeJson<ProductDto>(
      this as ProductDto,
    );
  }

  Map<String, dynamic> toMap() {
    return ProductDtoMapper.ensureInitialized().encodeMap<ProductDto>(
      this as ProductDto,
    );
  }

  ProductDtoCopyWith<ProductDto, ProductDto, ProductDto> get copyWith =>
      _ProductDtoCopyWithImpl<ProductDto, ProductDto>(
        this as ProductDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ProductDtoMapper.ensureInitialized().stringifyValue(
      this as ProductDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return ProductDtoMapper.ensureInitialized().equalsValue(
      this as ProductDto,
      other,
    );
  }

  @override
  int get hashCode {
    return ProductDtoMapper.ensureInitialized().hashValue(this as ProductDto);
  }
}

extension ProductDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ProductDto, $Out> {
  ProductDtoCopyWith<$R, ProductDto, $Out> get $asProductDto =>
      $base.as((v, t, t2) => _ProductDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ProductDtoCopyWith<$R, $In extends ProductDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  QuantityUnitCopyWith<$R, QuantityUnit, QuantityUnit>?
  get quantityUnitExpanded;
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    String? description,
    String? category,
    String? categoryName,
    String? image,
    String? branch,
    num? stockThreshold,
    num? price,
    bool? forSale,
    bool? trackStock,
    bool? requireStock,
    num? quantity,
    String? expiration,
    bool? trackByLot,
    String? quantityUnit,
    QuantityUnit? quantityUnitExpanded,
    bool? isDeleted,
    String? created,
    String? updated,
  });
  ProductDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ProductDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ProductDto, $Out>
    implements ProductDtoCopyWith<$R, ProductDto, $Out> {
  _ProductDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ProductDto> $mapper =
      ProductDtoMapper.ensureInitialized();
  @override
  QuantityUnitCopyWith<$R, QuantityUnit, QuantityUnit>?
  get quantityUnitExpanded => $value.quantityUnitExpanded?.copyWith.$chain(
    (v) => call(quantityUnitExpanded: v),
  );
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    Object? description = $none,
    Object? category = $none,
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
    Object? quantityUnit = $none,
    Object? quantityUnitExpanded = $none,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (name != null) #name: name,
      if (description != $none) #description: description,
      if (category != $none) #category: category,
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
      if (quantityUnit != $none) #quantityUnit: quantityUnit,
      if (quantityUnitExpanded != $none)
        #quantityUnitExpanded: quantityUnitExpanded,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  ProductDto $make(CopyWithData data) => ProductDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    name: data.get(#name, or: $value.name),
    description: data.get(#description, or: $value.description),
    category: data.get(#category, or: $value.category),
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
    quantityUnit: data.get(#quantityUnit, or: $value.quantityUnit),
    quantityUnitExpanded: data.get(
      #quantityUnitExpanded,
      or: $value.quantityUnitExpanded,
    ),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  ProductDtoCopyWith<$R2, ProductDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ProductDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

