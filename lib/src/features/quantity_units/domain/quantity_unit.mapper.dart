// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'quantity_unit.dart';

class QuantityUnitMapper extends ClassMapperBase<QuantityUnit> {
  QuantityUnitMapper._();

  static QuantityUnitMapper? _instance;
  static QuantityUnitMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = QuantityUnitMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'QuantityUnit';

  static String _$id(QuantityUnit v) => v.id;
  static const Field<QuantityUnit, String> _f$id = Field('id', _$id);
  static String _$name(QuantityUnit v) => v.name;
  static const Field<QuantityUnit, String> _f$name = Field('name', _$name);
  static String _$shortSingular(QuantityUnit v) => v.shortSingular;
  static const Field<QuantityUnit, String> _f$shortSingular = Field(
    'shortSingular',
    _$shortSingular,
  );
  static String _$shortPlural(QuantityUnit v) => v.shortPlural;
  static const Field<QuantityUnit, String> _f$shortPlural = Field(
    'shortPlural',
    _$shortPlural,
  );
  static String _$longSingular(QuantityUnit v) => v.longSingular;
  static const Field<QuantityUnit, String> _f$longSingular = Field(
    'longSingular',
    _$longSingular,
  );
  static String _$longPlural(QuantityUnit v) => v.longPlural;
  static const Field<QuantityUnit, String> _f$longPlural = Field(
    'longPlural',
    _$longPlural,
  );
  static bool _$isDeleted(QuantityUnit v) => v.isDeleted;
  static const Field<QuantityUnit, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static DateTime? _$created(QuantityUnit v) => v.created;
  static const Field<QuantityUnit, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(QuantityUnit v) => v.updated;
  static const Field<QuantityUnit, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<QuantityUnit> fields = const {
    #id: _f$id,
    #name: _f$name,
    #shortSingular: _f$shortSingular,
    #shortPlural: _f$shortPlural,
    #longSingular: _f$longSingular,
    #longPlural: _f$longPlural,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static QuantityUnit _instantiate(DecodingData data) {
    return QuantityUnit(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      shortSingular: data.dec(_f$shortSingular),
      shortPlural: data.dec(_f$shortPlural),
      longSingular: data.dec(_f$longSingular),
      longPlural: data.dec(_f$longPlural),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static QuantityUnit fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<QuantityUnit>(map);
  }

  static QuantityUnit fromJson(String json) {
    return ensureInitialized().decodeJson<QuantityUnit>(json);
  }
}

mixin QuantityUnitMappable {
  String toJson() {
    return QuantityUnitMapper.ensureInitialized().encodeJson<QuantityUnit>(
      this as QuantityUnit,
    );
  }

  Map<String, dynamic> toMap() {
    return QuantityUnitMapper.ensureInitialized().encodeMap<QuantityUnit>(
      this as QuantityUnit,
    );
  }

  QuantityUnitCopyWith<QuantityUnit, QuantityUnit, QuantityUnit> get copyWith =>
      _QuantityUnitCopyWithImpl<QuantityUnit, QuantityUnit>(
        this as QuantityUnit,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return QuantityUnitMapper.ensureInitialized().stringifyValue(
      this as QuantityUnit,
    );
  }

  @override
  bool operator ==(Object other) {
    return QuantityUnitMapper.ensureInitialized().equalsValue(
      this as QuantityUnit,
      other,
    );
  }

  @override
  int get hashCode {
    return QuantityUnitMapper.ensureInitialized().hashValue(
      this as QuantityUnit,
    );
  }
}

extension QuantityUnitValueCopy<$R, $Out>
    on ObjectCopyWith<$R, QuantityUnit, $Out> {
  QuantityUnitCopyWith<$R, QuantityUnit, $Out> get $asQuantityUnit =>
      $base.as((v, t, t2) => _QuantityUnitCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class QuantityUnitCopyWith<$R, $In extends QuantityUnit, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    String? shortSingular,
    String? shortPlural,
    String? longSingular,
    String? longPlural,
    bool? isDeleted,
    DateTime? created,
    DateTime? updated,
  });
  QuantityUnitCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _QuantityUnitCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, QuantityUnit, $Out>
    implements QuantityUnitCopyWith<$R, QuantityUnit, $Out> {
  _QuantityUnitCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<QuantityUnit> $mapper =
      QuantityUnitMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? name,
    String? shortSingular,
    String? shortPlural,
    String? longSingular,
    String? longPlural,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (shortSingular != null) #shortSingular: shortSingular,
      if (shortPlural != null) #shortPlural: shortPlural,
      if (longSingular != null) #longSingular: longSingular,
      if (longPlural != null) #longPlural: longPlural,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  QuantityUnit $make(CopyWithData data) => QuantityUnit(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    shortSingular: data.get(#shortSingular, or: $value.shortSingular),
    shortPlural: data.get(#shortPlural, or: $value.shortPlural),
    longSingular: data.get(#longSingular, or: $value.longSingular),
    longPlural: data.get(#longPlural, or: $value.longPlural),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  QuantityUnitCopyWith<$R2, QuantityUnit, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _QuantityUnitCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

