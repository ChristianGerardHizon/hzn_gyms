// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'member_membership_add_on_dto.dart';

class MemberMembershipAddOnDtoMapper
    extends ClassMapperBase<MemberMembershipAddOnDto> {
  MemberMembershipAddOnDtoMapper._();

  static MemberMembershipAddOnDtoMapper? _instance;
  static MemberMembershipAddOnDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = MemberMembershipAddOnDtoMapper._(),
      );
    }
    return _instance!;
  }

  @override
  final String id = 'MemberMembershipAddOnDto';

  static String _$id(MemberMembershipAddOnDto v) => v.id;
  static const Field<MemberMembershipAddOnDto, String> _f$id = Field(
    'id',
    _$id,
  );
  static String _$collectionId(MemberMembershipAddOnDto v) => v.collectionId;
  static const Field<MemberMembershipAddOnDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(MemberMembershipAddOnDto v) =>
      v.collectionName;
  static const Field<MemberMembershipAddOnDto, String> _f$collectionName =
      Field('collectionName', _$collectionName);
  static String _$memberMembership(MemberMembershipAddOnDto v) =>
      v.memberMembership;
  static const Field<MemberMembershipAddOnDto, String> _f$memberMembership =
      Field('memberMembership', _$memberMembership);
  static String _$membershipAddOn(MemberMembershipAddOnDto v) =>
      v.membershipAddOn;
  static const Field<MemberMembershipAddOnDto, String> _f$membershipAddOn =
      Field('membershipAddOn', _$membershipAddOn);
  static String _$addOnName(MemberMembershipAddOnDto v) => v.addOnName;
  static const Field<MemberMembershipAddOnDto, String> _f$addOnName = Field(
    'addOnName',
    _$addOnName,
  );
  static num _$price(MemberMembershipAddOnDto v) => v.price;
  static const Field<MemberMembershipAddOnDto, num> _f$price = Field(
    'price',
    _$price,
  );
  static String? _$created(MemberMembershipAddOnDto v) => v.created;
  static const Field<MemberMembershipAddOnDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(MemberMembershipAddOnDto v) => v.updated;
  static const Field<MemberMembershipAddOnDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<MemberMembershipAddOnDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #memberMembership: _f$memberMembership,
    #membershipAddOn: _f$membershipAddOn,
    #addOnName: _f$addOnName,
    #price: _f$price,
    #created: _f$created,
    #updated: _f$updated,
  };

  static MemberMembershipAddOnDto _instantiate(DecodingData data) {
    return MemberMembershipAddOnDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      memberMembership: data.dec(_f$memberMembership),
      membershipAddOn: data.dec(_f$membershipAddOn),
      addOnName: data.dec(_f$addOnName),
      price: data.dec(_f$price),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MemberMembershipAddOnDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MemberMembershipAddOnDto>(map);
  }

  static MemberMembershipAddOnDto fromJson(String json) {
    return ensureInitialized().decodeJson<MemberMembershipAddOnDto>(json);
  }
}

mixin MemberMembershipAddOnDtoMappable {
  String toJson() {
    return MemberMembershipAddOnDtoMapper.ensureInitialized()
        .encodeJson<MemberMembershipAddOnDto>(this as MemberMembershipAddOnDto);
  }

  Map<String, dynamic> toMap() {
    return MemberMembershipAddOnDtoMapper.ensureInitialized()
        .encodeMap<MemberMembershipAddOnDto>(this as MemberMembershipAddOnDto);
  }

  MemberMembershipAddOnDtoCopyWith<
    MemberMembershipAddOnDto,
    MemberMembershipAddOnDto,
    MemberMembershipAddOnDto
  >
  get copyWith =>
      _MemberMembershipAddOnDtoCopyWithImpl<
        MemberMembershipAddOnDto,
        MemberMembershipAddOnDto
      >(this as MemberMembershipAddOnDto, $identity, $identity);
  @override
  String toString() {
    return MemberMembershipAddOnDtoMapper.ensureInitialized().stringifyValue(
      this as MemberMembershipAddOnDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return MemberMembershipAddOnDtoMapper.ensureInitialized().equalsValue(
      this as MemberMembershipAddOnDto,
      other,
    );
  }

  @override
  int get hashCode {
    return MemberMembershipAddOnDtoMapper.ensureInitialized().hashValue(
      this as MemberMembershipAddOnDto,
    );
  }
}

extension MemberMembershipAddOnDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MemberMembershipAddOnDto, $Out> {
  MemberMembershipAddOnDtoCopyWith<$R, MemberMembershipAddOnDto, $Out>
  get $asMemberMembershipAddOnDto => $base.as(
    (v, t, t2) => _MemberMembershipAddOnDtoCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class MemberMembershipAddOnDtoCopyWith<
  $R,
  $In extends MemberMembershipAddOnDto,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? memberMembership,
    String? membershipAddOn,
    String? addOnName,
    num? price,
    String? created,
    String? updated,
  });
  MemberMembershipAddOnDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _MemberMembershipAddOnDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MemberMembershipAddOnDto, $Out>
    implements
        MemberMembershipAddOnDtoCopyWith<$R, MemberMembershipAddOnDto, $Out> {
  _MemberMembershipAddOnDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MemberMembershipAddOnDto> $mapper =
      MemberMembershipAddOnDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? memberMembership,
    String? membershipAddOn,
    String? addOnName,
    num? price,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (memberMembership != null) #memberMembership: memberMembership,
      if (membershipAddOn != null) #membershipAddOn: membershipAddOn,
      if (addOnName != null) #addOnName: addOnName,
      if (price != null) #price: price,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  MemberMembershipAddOnDto $make(CopyWithData data) => MemberMembershipAddOnDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    memberMembership: data.get(#memberMembership, or: $value.memberMembership),
    membershipAddOn: data.get(#membershipAddOn, or: $value.membershipAddOn),
    addOnName: data.get(#addOnName, or: $value.addOnName),
    price: data.get(#price, or: $value.price),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  MemberMembershipAddOnDtoCopyWith<$R2, MemberMembershipAddOnDto, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _MemberMembershipAddOnDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

