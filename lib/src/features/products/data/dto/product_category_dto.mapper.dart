// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'product_category_dto.dart';

class ProductCategoryDtoMapper extends ClassMapperBase<ProductCategoryDto> {
  ProductCategoryDtoMapper._();

  static ProductCategoryDtoMapper? _instance;
  static ProductCategoryDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ProductCategoryDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ProductCategoryDto';

  static String _$id(ProductCategoryDto v) => v.id;
  static const Field<ProductCategoryDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(ProductCategoryDto v) => v.collectionId;
  static const Field<ProductCategoryDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(ProductCategoryDto v) => v.collectionName;
  static const Field<ProductCategoryDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$name(ProductCategoryDto v) => v.name;
  static const Field<ProductCategoryDto, String> _f$name = Field(
    'name',
    _$name,
  );
  static String? _$parent(ProductCategoryDto v) => v.parent;
  static const Field<ProductCategoryDto, String> _f$parent = Field(
    'parent',
    _$parent,
    opt: true,
  );
  static bool _$isDeleted(ProductCategoryDto v) => v.isDeleted;
  static const Field<ProductCategoryDto, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static String? _$created(ProductCategoryDto v) => v.created;
  static const Field<ProductCategoryDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(ProductCategoryDto v) => v.updated;
  static const Field<ProductCategoryDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<ProductCategoryDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #name: _f$name,
    #parent: _f$parent,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static ProductCategoryDto _instantiate(DecodingData data) {
    return ProductCategoryDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      name: data.dec(_f$name),
      parent: data.dec(_f$parent),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ProductCategoryDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ProductCategoryDto>(map);
  }

  static ProductCategoryDto fromJson(String json) {
    return ensureInitialized().decodeJson<ProductCategoryDto>(json);
  }
}

mixin ProductCategoryDtoMappable {
  String toJson() {
    return ProductCategoryDtoMapper.ensureInitialized()
        .encodeJson<ProductCategoryDto>(this as ProductCategoryDto);
  }

  Map<String, dynamic> toMap() {
    return ProductCategoryDtoMapper.ensureInitialized()
        .encodeMap<ProductCategoryDto>(this as ProductCategoryDto);
  }

  ProductCategoryDtoCopyWith<
    ProductCategoryDto,
    ProductCategoryDto,
    ProductCategoryDto
  >
  get copyWith =>
      _ProductCategoryDtoCopyWithImpl<ProductCategoryDto, ProductCategoryDto>(
        this as ProductCategoryDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ProductCategoryDtoMapper.ensureInitialized().stringifyValue(
      this as ProductCategoryDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return ProductCategoryDtoMapper.ensureInitialized().equalsValue(
      this as ProductCategoryDto,
      other,
    );
  }

  @override
  int get hashCode {
    return ProductCategoryDtoMapper.ensureInitialized().hashValue(
      this as ProductCategoryDto,
    );
  }
}

extension ProductCategoryDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ProductCategoryDto, $Out> {
  ProductCategoryDtoCopyWith<$R, ProductCategoryDto, $Out>
  get $asProductCategoryDto => $base.as(
    (v, t, t2) => _ProductCategoryDtoCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class ProductCategoryDtoCopyWith<
  $R,
  $In extends ProductCategoryDto,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    String? parent,
    bool? isDeleted,
    String? created,
    String? updated,
  });
  ProductCategoryDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ProductCategoryDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ProductCategoryDto, $Out>
    implements ProductCategoryDtoCopyWith<$R, ProductCategoryDto, $Out> {
  _ProductCategoryDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ProductCategoryDto> $mapper =
      ProductCategoryDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    Object? parent = $none,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (name != null) #name: name,
      if (parent != $none) #parent: parent,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  ProductCategoryDto $make(CopyWithData data) => ProductCategoryDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    name: data.get(#name, or: $value.name),
    parent: data.get(#parent, or: $value.parent),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  ProductCategoryDtoCopyWith<$R2, ProductCategoryDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ProductCategoryDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

