// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'quantity_unit_dto.dart';

class QuantityUnitDtoMapper extends ClassMapperBase<QuantityUnitDto> {
  QuantityUnitDtoMapper._();

  static QuantityUnitDtoMapper? _instance;
  static QuantityUnitDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = QuantityUnitDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'QuantityUnitDto';

  static String _$id(QuantityUnitDto v) => v.id;
  static const Field<QuantityUnitDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(QuantityUnitDto v) => v.collectionId;
  static const Field<QuantityUnitDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(QuantityUnitDto v) => v.collectionName;
  static const Field<QuantityUnitDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$name(QuantityUnitDto v) => v.name;
  static const Field<QuantityUnitDto, String> _f$name = Field('name', _$name);
  static String _$shortSingular(QuantityUnitDto v) => v.shortSingular;
  static const Field<QuantityUnitDto, String> _f$shortSingular = Field(
    'shortSingular',
    _$shortSingular,
  );
  static String _$shortPlural(QuantityUnitDto v) => v.shortPlural;
  static const Field<QuantityUnitDto, String> _f$shortPlural = Field(
    'shortPlural',
    _$shortPlural,
  );
  static String _$longSingular(QuantityUnitDto v) => v.longSingular;
  static const Field<QuantityUnitDto, String> _f$longSingular = Field(
    'longSingular',
    _$longSingular,
  );
  static String _$longPlural(QuantityUnitDto v) => v.longPlural;
  static const Field<QuantityUnitDto, String> _f$longPlural = Field(
    'longPlural',
    _$longPlural,
  );
  static bool _$isDeleted(QuantityUnitDto v) => v.isDeleted;
  static const Field<QuantityUnitDto, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static String? _$created(QuantityUnitDto v) => v.created;
  static const Field<QuantityUnitDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(QuantityUnitDto v) => v.updated;
  static const Field<QuantityUnitDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<QuantityUnitDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #name: _f$name,
    #shortSingular: _f$shortSingular,
    #shortPlural: _f$shortPlural,
    #longSingular: _f$longSingular,
    #longPlural: _f$longPlural,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static QuantityUnitDto _instantiate(DecodingData data) {
    return QuantityUnitDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
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

  static QuantityUnitDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<QuantityUnitDto>(map);
  }

  static QuantityUnitDto fromJson(String json) {
    return ensureInitialized().decodeJson<QuantityUnitDto>(json);
  }
}

mixin QuantityUnitDtoMappable {
  String toJson() {
    return QuantityUnitDtoMapper.ensureInitialized()
        .encodeJson<QuantityUnitDto>(this as QuantityUnitDto);
  }

  Map<String, dynamic> toMap() {
    return QuantityUnitDtoMapper.ensureInitialized().encodeMap<QuantityUnitDto>(
      this as QuantityUnitDto,
    );
  }

  QuantityUnitDtoCopyWith<QuantityUnitDto, QuantityUnitDto, QuantityUnitDto>
  get copyWith =>
      _QuantityUnitDtoCopyWithImpl<QuantityUnitDto, QuantityUnitDto>(
        this as QuantityUnitDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return QuantityUnitDtoMapper.ensureInitialized().stringifyValue(
      this as QuantityUnitDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return QuantityUnitDtoMapper.ensureInitialized().equalsValue(
      this as QuantityUnitDto,
      other,
    );
  }

  @override
  int get hashCode {
    return QuantityUnitDtoMapper.ensureInitialized().hashValue(
      this as QuantityUnitDto,
    );
  }
}

extension QuantityUnitDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, QuantityUnitDto, $Out> {
  QuantityUnitDtoCopyWith<$R, QuantityUnitDto, $Out> get $asQuantityUnitDto =>
      $base.as((v, t, t2) => _QuantityUnitDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class QuantityUnitDtoCopyWith<$R, $In extends QuantityUnitDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    String? shortSingular,
    String? shortPlural,
    String? longSingular,
    String? longPlural,
    bool? isDeleted,
    String? created,
    String? updated,
  });
  QuantityUnitDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _QuantityUnitDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, QuantityUnitDto, $Out>
    implements QuantityUnitDtoCopyWith<$R, QuantityUnitDto, $Out> {
  _QuantityUnitDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<QuantityUnitDto> $mapper =
      QuantityUnitDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
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
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
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
  QuantityUnitDto $make(CopyWithData data) => QuantityUnitDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
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
  QuantityUnitDtoCopyWith<$R2, QuantityUnitDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _QuantityUnitDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

