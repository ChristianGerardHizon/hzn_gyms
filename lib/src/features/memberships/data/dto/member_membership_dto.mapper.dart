// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'member_membership_dto.dart';

class MemberMembershipDtoMapper extends ClassMapperBase<MemberMembershipDto> {
  MemberMembershipDtoMapper._();

  static MemberMembershipDtoMapper? _instance;
  static MemberMembershipDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MemberMembershipDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'MemberMembershipDto';

  static String _$id(MemberMembershipDto v) => v.id;
  static const Field<MemberMembershipDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(MemberMembershipDto v) => v.collectionId;
  static const Field<MemberMembershipDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(MemberMembershipDto v) => v.collectionName;
  static const Field<MemberMembershipDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$member(MemberMembershipDto v) => v.member;
  static const Field<MemberMembershipDto, String> _f$member = Field(
    'member',
    _$member,
  );
  static String _$membership(MemberMembershipDto v) => v.membership;
  static const Field<MemberMembershipDto, String> _f$membership = Field(
    'membership',
    _$membership,
  );
  static String? _$startDate(MemberMembershipDto v) => v.startDate;
  static const Field<MemberMembershipDto, String> _f$startDate = Field(
    'startDate',
    _$startDate,
    opt: true,
  );
  static String? _$endDate(MemberMembershipDto v) => v.endDate;
  static const Field<MemberMembershipDto, String> _f$endDate = Field(
    'endDate',
    _$endDate,
    opt: true,
  );
  static String _$status(MemberMembershipDto v) => v.status;
  static const Field<MemberMembershipDto, String> _f$status = Field(
    'status',
    _$status,
  );
  static String _$branch(MemberMembershipDto v) => v.branch;
  static const Field<MemberMembershipDto, String> _f$branch = Field(
    'branch',
    _$branch,
  );
  static String? _$sale(MemberMembershipDto v) => v.sale;
  static const Field<MemberMembershipDto, String> _f$sale = Field(
    'sale',
    _$sale,
    opt: true,
  );
  static String? _$soldBy(MemberMembershipDto v) => v.soldBy;
  static const Field<MemberMembershipDto, String> _f$soldBy = Field(
    'soldBy',
    _$soldBy,
    opt: true,
  );
  static String? _$notes(MemberMembershipDto v) => v.notes;
  static const Field<MemberMembershipDto, String> _f$notes = Field(
    'notes',
    _$notes,
    opt: true,
  );
  static String? _$created(MemberMembershipDto v) => v.created;
  static const Field<MemberMembershipDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(MemberMembershipDto v) => v.updated;
  static const Field<MemberMembershipDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );
  static String? _$memberName(MemberMembershipDto v) => v.memberName;
  static const Field<MemberMembershipDto, String> _f$memberName = Field(
    'memberName',
    _$memberName,
    opt: true,
  );
  static String? _$membershipName(MemberMembershipDto v) => v.membershipName;
  static const Field<MemberMembershipDto, String> _f$membershipName = Field(
    'membershipName',
    _$membershipName,
    opt: true,
  );

  @override
  final MappableFields<MemberMembershipDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #member: _f$member,
    #membership: _f$membership,
    #startDate: _f$startDate,
    #endDate: _f$endDate,
    #status: _f$status,
    #branch: _f$branch,
    #sale: _f$sale,
    #soldBy: _f$soldBy,
    #notes: _f$notes,
    #created: _f$created,
    #updated: _f$updated,
    #memberName: _f$memberName,
    #membershipName: _f$membershipName,
  };

  static MemberMembershipDto _instantiate(DecodingData data) {
    return MemberMembershipDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      member: data.dec(_f$member),
      membership: data.dec(_f$membership),
      startDate: data.dec(_f$startDate),
      endDate: data.dec(_f$endDate),
      status: data.dec(_f$status),
      branch: data.dec(_f$branch),
      sale: data.dec(_f$sale),
      soldBy: data.dec(_f$soldBy),
      notes: data.dec(_f$notes),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
      memberName: data.dec(_f$memberName),
      membershipName: data.dec(_f$membershipName),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MemberMembershipDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MemberMembershipDto>(map);
  }

  static MemberMembershipDto fromJson(String json) {
    return ensureInitialized().decodeJson<MemberMembershipDto>(json);
  }
}

mixin MemberMembershipDtoMappable {
  String toJson() {
    return MemberMembershipDtoMapper.ensureInitialized()
        .encodeJson<MemberMembershipDto>(this as MemberMembershipDto);
  }

  Map<String, dynamic> toMap() {
    return MemberMembershipDtoMapper.ensureInitialized()
        .encodeMap<MemberMembershipDto>(this as MemberMembershipDto);
  }

  MemberMembershipDtoCopyWith<
    MemberMembershipDto,
    MemberMembershipDto,
    MemberMembershipDto
  >
  get copyWith =>
      _MemberMembershipDtoCopyWithImpl<
        MemberMembershipDto,
        MemberMembershipDto
      >(this as MemberMembershipDto, $identity, $identity);
  @override
  String toString() {
    return MemberMembershipDtoMapper.ensureInitialized().stringifyValue(
      this as MemberMembershipDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return MemberMembershipDtoMapper.ensureInitialized().equalsValue(
      this as MemberMembershipDto,
      other,
    );
  }

  @override
  int get hashCode {
    return MemberMembershipDtoMapper.ensureInitialized().hashValue(
      this as MemberMembershipDto,
    );
  }
}

extension MemberMembershipDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MemberMembershipDto, $Out> {
  MemberMembershipDtoCopyWith<$R, MemberMembershipDto, $Out>
  get $asMemberMembershipDto => $base.as(
    (v, t, t2) => _MemberMembershipDtoCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class MemberMembershipDtoCopyWith<
  $R,
  $In extends MemberMembershipDto,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? member,
    String? membership,
    String? startDate,
    String? endDate,
    String? status,
    String? branch,
    String? sale,
    String? soldBy,
    String? notes,
    String? created,
    String? updated,
    String? memberName,
    String? membershipName,
  });
  MemberMembershipDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _MemberMembershipDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MemberMembershipDto, $Out>
    implements MemberMembershipDtoCopyWith<$R, MemberMembershipDto, $Out> {
  _MemberMembershipDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MemberMembershipDto> $mapper =
      MemberMembershipDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? member,
    String? membership,
    Object? startDate = $none,
    Object? endDate = $none,
    String? status,
    String? branch,
    Object? sale = $none,
    Object? soldBy = $none,
    Object? notes = $none,
    Object? created = $none,
    Object? updated = $none,
    Object? memberName = $none,
    Object? membershipName = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (member != null) #member: member,
      if (membership != null) #membership: membership,
      if (startDate != $none) #startDate: startDate,
      if (endDate != $none) #endDate: endDate,
      if (status != null) #status: status,
      if (branch != null) #branch: branch,
      if (sale != $none) #sale: sale,
      if (soldBy != $none) #soldBy: soldBy,
      if (notes != $none) #notes: notes,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
      if (memberName != $none) #memberName: memberName,
      if (membershipName != $none) #membershipName: membershipName,
    }),
  );
  @override
  MemberMembershipDto $make(CopyWithData data) => MemberMembershipDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    member: data.get(#member, or: $value.member),
    membership: data.get(#membership, or: $value.membership),
    startDate: data.get(#startDate, or: $value.startDate),
    endDate: data.get(#endDate, or: $value.endDate),
    status: data.get(#status, or: $value.status),
    branch: data.get(#branch, or: $value.branch),
    sale: data.get(#sale, or: $value.sale),
    soldBy: data.get(#soldBy, or: $value.soldBy),
    notes: data.get(#notes, or: $value.notes),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
    memberName: data.get(#memberName, or: $value.memberName),
    membershipName: data.get(#membershipName, or: $value.membershipName),
  );

  @override
  MemberMembershipDtoCopyWith<$R2, MemberMembershipDto, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _MemberMembershipDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

