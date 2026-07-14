// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'pos_group_dto.dart';

class PosGroupDtoMapper extends ClassMapperBase<PosGroupDto> {
  PosGroupDtoMapper._();

  static PosGroupDtoMapper? _instance;
  static PosGroupDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PosGroupDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'PosGroupDto';

  static String _$id(PosGroupDto v) => v.id;
  static const Field<PosGroupDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(PosGroupDto v) => v.collectionId;
  static const Field<PosGroupDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(PosGroupDto v) => v.collectionName;
  static const Field<PosGroupDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$name(PosGroupDto v) => v.name;
  static const Field<PosGroupDto, String> _f$name = Field('name', _$name);
  static String _$branch(PosGroupDto v) => v.branch;
  static const Field<PosGroupDto, String> _f$branch = Field('branch', _$branch);
  static int _$sortOrder(PosGroupDto v) => v.sortOrder;
  static const Field<PosGroupDto, int> _f$sortOrder = Field(
    'sortOrder',
    _$sortOrder,
    opt: true,
    def: 0,
  );
  static bool _$isDeleted(PosGroupDto v) => v.isDeleted;
  static const Field<PosGroupDto, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static String? _$created(PosGroupDto v) => v.created;
  static const Field<PosGroupDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(PosGroupDto v) => v.updated;
  static const Field<PosGroupDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<PosGroupDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #name: _f$name,
    #branch: _f$branch,
    #sortOrder: _f$sortOrder,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static PosGroupDto _instantiate(DecodingData data) {
    return PosGroupDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      name: data.dec(_f$name),
      branch: data.dec(_f$branch),
      sortOrder: data.dec(_f$sortOrder),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static PosGroupDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PosGroupDto>(map);
  }

  static PosGroupDto fromJson(String json) {
    return ensureInitialized().decodeJson<PosGroupDto>(json);
  }
}

mixin PosGroupDtoMappable {
  String toJson() {
    return PosGroupDtoMapper.ensureInitialized().encodeJson<PosGroupDto>(
      this as PosGroupDto,
    );
  }

  Map<String, dynamic> toMap() {
    return PosGroupDtoMapper.ensureInitialized().encodeMap<PosGroupDto>(
      this as PosGroupDto,
    );
  }

  PosGroupDtoCopyWith<PosGroupDto, PosGroupDto, PosGroupDto> get copyWith =>
      _PosGroupDtoCopyWithImpl<PosGroupDto, PosGroupDto>(
        this as PosGroupDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PosGroupDtoMapper.ensureInitialized().stringifyValue(
      this as PosGroupDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return PosGroupDtoMapper.ensureInitialized().equalsValue(
      this as PosGroupDto,
      other,
    );
  }

  @override
  int get hashCode {
    return PosGroupDtoMapper.ensureInitialized().hashValue(this as PosGroupDto);
  }
}

extension PosGroupDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PosGroupDto, $Out> {
  PosGroupDtoCopyWith<$R, PosGroupDto, $Out> get $asPosGroupDto =>
      $base.as((v, t, t2) => _PosGroupDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PosGroupDtoCopyWith<$R, $In extends PosGroupDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    String? branch,
    int? sortOrder,
    bool? isDeleted,
    String? created,
    String? updated,
  });
  PosGroupDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PosGroupDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PosGroupDto, $Out>
    implements PosGroupDtoCopyWith<$R, PosGroupDto, $Out> {
  _PosGroupDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PosGroupDto> $mapper =
      PosGroupDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    String? branch,
    int? sortOrder,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (name != null) #name: name,
      if (branch != null) #branch: branch,
      if (sortOrder != null) #sortOrder: sortOrder,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  PosGroupDto $make(CopyWithData data) => PosGroupDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    name: data.get(#name, or: $value.name),
    branch: data.get(#branch, or: $value.branch),
    sortOrder: data.get(#sortOrder, or: $value.sortOrder),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  PosGroupDtoCopyWith<$R2, PosGroupDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PosGroupDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

