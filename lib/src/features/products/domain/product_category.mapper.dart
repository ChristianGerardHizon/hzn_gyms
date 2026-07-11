// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'product_category.dart';

class ProductCategoryMapper extends ClassMapperBase<ProductCategory> {
  ProductCategoryMapper._();

  static ProductCategoryMapper? _instance;
  static ProductCategoryMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ProductCategoryMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ProductCategory';

  static String _$id(ProductCategory v) => v.id;
  static const Field<ProductCategory, String> _f$id = Field('id', _$id);
  static String _$name(ProductCategory v) => v.name;
  static const Field<ProductCategory, String> _f$name = Field('name', _$name);
  static String? _$parentId(ProductCategory v) => v.parentId;
  static const Field<ProductCategory, String> _f$parentId = Field(
    'parentId',
    _$parentId,
    opt: true,
  );
  static String? _$parentName(ProductCategory v) => v.parentName;
  static const Field<ProductCategory, String> _f$parentName = Field(
    'parentName',
    _$parentName,
    opt: true,
  );
  static bool _$isDeleted(ProductCategory v) => v.isDeleted;
  static const Field<ProductCategory, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static DateTime? _$created(ProductCategory v) => v.created;
  static const Field<ProductCategory, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(ProductCategory v) => v.updated;
  static const Field<ProductCategory, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<ProductCategory> fields = const {
    #id: _f$id,
    #name: _f$name,
    #parentId: _f$parentId,
    #parentName: _f$parentName,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static ProductCategory _instantiate(DecodingData data) {
    return ProductCategory(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      parentId: data.dec(_f$parentId),
      parentName: data.dec(_f$parentName),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ProductCategory fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ProductCategory>(map);
  }

  static ProductCategory fromJson(String json) {
    return ensureInitialized().decodeJson<ProductCategory>(json);
  }
}

mixin ProductCategoryMappable {
  String toJson() {
    return ProductCategoryMapper.ensureInitialized()
        .encodeJson<ProductCategory>(this as ProductCategory);
  }

  Map<String, dynamic> toMap() {
    return ProductCategoryMapper.ensureInitialized().encodeMap<ProductCategory>(
      this as ProductCategory,
    );
  }

  ProductCategoryCopyWith<ProductCategory, ProductCategory, ProductCategory>
  get copyWith =>
      _ProductCategoryCopyWithImpl<ProductCategory, ProductCategory>(
        this as ProductCategory,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ProductCategoryMapper.ensureInitialized().stringifyValue(
      this as ProductCategory,
    );
  }

  @override
  bool operator ==(Object other) {
    return ProductCategoryMapper.ensureInitialized().equalsValue(
      this as ProductCategory,
      other,
    );
  }

  @override
  int get hashCode {
    return ProductCategoryMapper.ensureInitialized().hashValue(
      this as ProductCategory,
    );
  }
}

extension ProductCategoryValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ProductCategory, $Out> {
  ProductCategoryCopyWith<$R, ProductCategory, $Out> get $asProductCategory =>
      $base.as((v, t, t2) => _ProductCategoryCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ProductCategoryCopyWith<$R, $In extends ProductCategory, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    String? parentId,
    String? parentName,
    bool? isDeleted,
    DateTime? created,
    DateTime? updated,
  });
  ProductCategoryCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ProductCategoryCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ProductCategory, $Out>
    implements ProductCategoryCopyWith<$R, ProductCategory, $Out> {
  _ProductCategoryCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ProductCategory> $mapper =
      ProductCategoryMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? name,
    Object? parentId = $none,
    Object? parentName = $none,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (parentId != $none) #parentId: parentId,
      if (parentName != $none) #parentName: parentName,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  ProductCategory $make(CopyWithData data) => ProductCategory(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    parentId: data.get(#parentId, or: $value.parentId),
    parentName: data.get(#parentName, or: $value.parentName),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  ProductCategoryCopyWith<$R2, ProductCategory, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ProductCategoryCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

