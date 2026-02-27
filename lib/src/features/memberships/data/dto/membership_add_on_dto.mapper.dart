// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'membership_add_on_dto.dart';

class MembershipAddOnDtoMapper extends ClassMapperBase<MembershipAddOnDto> {
  MembershipAddOnDtoMapper._();

  static MembershipAddOnDtoMapper? _instance;
  static MembershipAddOnDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MembershipAddOnDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'MembershipAddOnDto';

  static String _$id(MembershipAddOnDto v) => v.id;
  static const Field<MembershipAddOnDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(MembershipAddOnDto v) => v.collectionId;
  static const Field<MembershipAddOnDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(MembershipAddOnDto v) => v.collectionName;
  static const Field<MembershipAddOnDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$membership(MembershipAddOnDto v) => v.membership;
  static const Field<MembershipAddOnDto, String> _f$membership = Field(
    'membership',
    _$membership,
  );
  static String _$name(MembershipAddOnDto v) => v.name;
  static const Field<MembershipAddOnDto, String> _f$name = Field(
    'name',
    _$name,
  );
  static String? _$description(MembershipAddOnDto v) => v.description;
  static const Field<MembershipAddOnDto, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );
  static num _$price(MembershipAddOnDto v) => v.price;
  static const Field<MembershipAddOnDto, num> _f$price = Field(
    'price',
    _$price,
  );
  static bool _$isActive(MembershipAddOnDto v) => v.isActive;
  static const Field<MembershipAddOnDto, bool> _f$isActive = Field(
    'isActive',
    _$isActive,
    opt: true,
    def: true,
  );
  static String? _$created(MembershipAddOnDto v) => v.created;
  static const Field<MembershipAddOnDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(MembershipAddOnDto v) => v.updated;
  static const Field<MembershipAddOnDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<MembershipAddOnDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #membership: _f$membership,
    #name: _f$name,
    #description: _f$description,
    #price: _f$price,
    #isActive: _f$isActive,
    #created: _f$created,
    #updated: _f$updated,
  };

  static MembershipAddOnDto _instantiate(DecodingData data) {
    return MembershipAddOnDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      membership: data.dec(_f$membership),
      name: data.dec(_f$name),
      description: data.dec(_f$description),
      price: data.dec(_f$price),
      isActive: data.dec(_f$isActive),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MembershipAddOnDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MembershipAddOnDto>(map);
  }

  static MembershipAddOnDto fromJson(String json) {
    return ensureInitialized().decodeJson<MembershipAddOnDto>(json);
  }
}

mixin MembershipAddOnDtoMappable {
  String toJson() {
    return MembershipAddOnDtoMapper.ensureInitialized()
        .encodeJson<MembershipAddOnDto>(this as MembershipAddOnDto);
  }

  Map<String, dynamic> toMap() {
    return MembershipAddOnDtoMapper.ensureInitialized()
        .encodeMap<MembershipAddOnDto>(this as MembershipAddOnDto);
  }

  MembershipAddOnDtoCopyWith<
    MembershipAddOnDto,
    MembershipAddOnDto,
    MembershipAddOnDto
  >
  get copyWith =>
      _MembershipAddOnDtoCopyWithImpl<MembershipAddOnDto, MembershipAddOnDto>(
        this as MembershipAddOnDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return MembershipAddOnDtoMapper.ensureInitialized().stringifyValue(
      this as MembershipAddOnDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return MembershipAddOnDtoMapper.ensureInitialized().equalsValue(
      this as MembershipAddOnDto,
      other,
    );
  }

  @override
  int get hashCode {
    return MembershipAddOnDtoMapper.ensureInitialized().hashValue(
      this as MembershipAddOnDto,
    );
  }
}

extension MembershipAddOnDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MembershipAddOnDto, $Out> {
  MembershipAddOnDtoCopyWith<$R, MembershipAddOnDto, $Out>
  get $asMembershipAddOnDto => $base.as(
    (v, t, t2) => _MembershipAddOnDtoCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class MembershipAddOnDtoCopyWith<
  $R,
  $In extends MembershipAddOnDto,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? membership,
    String? name,
    String? description,
    num? price,
    bool? isActive,
    String? created,
    String? updated,
  });
  MembershipAddOnDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _MembershipAddOnDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MembershipAddOnDto, $Out>
    implements MembershipAddOnDtoCopyWith<$R, MembershipAddOnDto, $Out> {
  _MembershipAddOnDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MembershipAddOnDto> $mapper =
      MembershipAddOnDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? membership,
    String? name,
    Object? description = $none,
    num? price,
    bool? isActive,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (membership != null) #membership: membership,
      if (name != null) #name: name,
      if (description != $none) #description: description,
      if (price != null) #price: price,
      if (isActive != null) #isActive: isActive,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  MembershipAddOnDto $make(CopyWithData data) => MembershipAddOnDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    membership: data.get(#membership, or: $value.membership),
    name: data.get(#name, or: $value.name),
    description: data.get(#description, or: $value.description),
    price: data.get(#price, or: $value.price),
    isActive: data.get(#isActive, or: $value.isActive),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  MembershipAddOnDtoCopyWith<$R2, MembershipAddOnDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MembershipAddOnDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

