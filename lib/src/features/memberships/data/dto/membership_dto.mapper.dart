// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'membership_dto.dart';

class MembershipDtoMapper extends ClassMapperBase<MembershipDto> {
  MembershipDtoMapper._();

  static MembershipDtoMapper? _instance;
  static MembershipDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MembershipDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'MembershipDto';

  static String _$id(MembershipDto v) => v.id;
  static const Field<MembershipDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(MembershipDto v) => v.collectionId;
  static const Field<MembershipDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(MembershipDto v) => v.collectionName;
  static const Field<MembershipDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$name(MembershipDto v) => v.name;
  static const Field<MembershipDto, String> _f$name = Field('name', _$name);
  static String? _$description(MembershipDto v) => v.description;
  static const Field<MembershipDto, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );
  static int _$durationDays(MembershipDto v) => v.durationDays;
  static const Field<MembershipDto, int> _f$durationDays = Field(
    'durationDays',
    _$durationDays,
  );
  static num _$price(MembershipDto v) => v.price;
  static const Field<MembershipDto, num> _f$price = Field('price', _$price);
  static String _$branch(MembershipDto v) => v.branch;
  static const Field<MembershipDto, String> _f$branch = Field(
    'branch',
    _$branch,
  );
  static bool _$isActive(MembershipDto v) => v.isActive;
  static const Field<MembershipDto, bool> _f$isActive = Field(
    'isActive',
    _$isActive,
    opt: true,
    def: true,
  );
  static String? _$created(MembershipDto v) => v.created;
  static const Field<MembershipDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(MembershipDto v) => v.updated;
  static const Field<MembershipDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<MembershipDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #name: _f$name,
    #description: _f$description,
    #durationDays: _f$durationDays,
    #price: _f$price,
    #branch: _f$branch,
    #isActive: _f$isActive,
    #created: _f$created,
    #updated: _f$updated,
  };

  static MembershipDto _instantiate(DecodingData data) {
    return MembershipDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      name: data.dec(_f$name),
      description: data.dec(_f$description),
      durationDays: data.dec(_f$durationDays),
      price: data.dec(_f$price),
      branch: data.dec(_f$branch),
      isActive: data.dec(_f$isActive),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MembershipDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MembershipDto>(map);
  }

  static MembershipDto fromJson(String json) {
    return ensureInitialized().decodeJson<MembershipDto>(json);
  }
}

mixin MembershipDtoMappable {
  String toJson() {
    return MembershipDtoMapper.ensureInitialized().encodeJson<MembershipDto>(
      this as MembershipDto,
    );
  }

  Map<String, dynamic> toMap() {
    return MembershipDtoMapper.ensureInitialized().encodeMap<MembershipDto>(
      this as MembershipDto,
    );
  }

  MembershipDtoCopyWith<MembershipDto, MembershipDto, MembershipDto>
  get copyWith => _MembershipDtoCopyWithImpl<MembershipDto, MembershipDto>(
    this as MembershipDto,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return MembershipDtoMapper.ensureInitialized().stringifyValue(
      this as MembershipDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return MembershipDtoMapper.ensureInitialized().equalsValue(
      this as MembershipDto,
      other,
    );
  }

  @override
  int get hashCode {
    return MembershipDtoMapper.ensureInitialized().hashValue(
      this as MembershipDto,
    );
  }
}

extension MembershipDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MembershipDto, $Out> {
  MembershipDtoCopyWith<$R, MembershipDto, $Out> get $asMembershipDto =>
      $base.as((v, t, t2) => _MembershipDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MembershipDtoCopyWith<$R, $In extends MembershipDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    String? description,
    int? durationDays,
    num? price,
    String? branch,
    bool? isActive,
    String? created,
    String? updated,
  });
  MembershipDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MembershipDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MembershipDto, $Out>
    implements MembershipDtoCopyWith<$R, MembershipDto, $Out> {
  _MembershipDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MembershipDto> $mapper =
      MembershipDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    Object? description = $none,
    int? durationDays,
    num? price,
    String? branch,
    bool? isActive,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (name != null) #name: name,
      if (description != $none) #description: description,
      if (durationDays != null) #durationDays: durationDays,
      if (price != null) #price: price,
      if (branch != null) #branch: branch,
      if (isActive != null) #isActive: isActive,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  MembershipDto $make(CopyWithData data) => MembershipDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    name: data.get(#name, or: $value.name),
    description: data.get(#description, or: $value.description),
    durationDays: data.get(#durationDays, or: $value.durationDays),
    price: data.get(#price, or: $value.price),
    branch: data.get(#branch, or: $value.branch),
    isActive: data.get(#isActive, or: $value.isActive),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  MembershipDtoCopyWith<$R2, MembershipDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MembershipDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

