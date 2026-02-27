// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'check_in_dto.dart';

class CheckInDtoMapper extends ClassMapperBase<CheckInDto> {
  CheckInDtoMapper._();

  static CheckInDtoMapper? _instance;
  static CheckInDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CheckInDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'CheckInDto';

  static String _$id(CheckInDto v) => v.id;
  static const Field<CheckInDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(CheckInDto v) => v.collectionId;
  static const Field<CheckInDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(CheckInDto v) => v.collectionName;
  static const Field<CheckInDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$member(CheckInDto v) => v.member;
  static const Field<CheckInDto, String> _f$member = Field('member', _$member);
  static String _$branch(CheckInDto v) => v.branch;
  static const Field<CheckInDto, String> _f$branch = Field('branch', _$branch);
  static String? _$checkInTime(CheckInDto v) => v.checkInTime;
  static const Field<CheckInDto, String> _f$checkInTime = Field(
    'checkInTime',
    _$checkInTime,
    opt: true,
  );
  static String _$method(CheckInDto v) => v.method;
  static const Field<CheckInDto, String> _f$method = Field('method', _$method);
  static String? _$checkedInBy(CheckInDto v) => v.checkedInBy;
  static const Field<CheckInDto, String> _f$checkedInBy = Field(
    'checkedInBy',
    _$checkedInBy,
    opt: true,
  );
  static String? _$memberMembership(CheckInDto v) => v.memberMembership;
  static const Field<CheckInDto, String> _f$memberMembership = Field(
    'memberMembership',
    _$memberMembership,
    opt: true,
  );
  static String? _$notes(CheckInDto v) => v.notes;
  static const Field<CheckInDto, String> _f$notes = Field(
    'notes',
    _$notes,
    opt: true,
  );
  static String? _$created(CheckInDto v) => v.created;
  static const Field<CheckInDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(CheckInDto v) => v.updated;
  static const Field<CheckInDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );
  static String? _$memberName(CheckInDto v) => v.memberName;
  static const Field<CheckInDto, String> _f$memberName = Field(
    'memberName',
    _$memberName,
    opt: true,
  );

  @override
  final MappableFields<CheckInDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #member: _f$member,
    #branch: _f$branch,
    #checkInTime: _f$checkInTime,
    #method: _f$method,
    #checkedInBy: _f$checkedInBy,
    #memberMembership: _f$memberMembership,
    #notes: _f$notes,
    #created: _f$created,
    #updated: _f$updated,
    #memberName: _f$memberName,
  };

  static CheckInDto _instantiate(DecodingData data) {
    return CheckInDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      member: data.dec(_f$member),
      branch: data.dec(_f$branch),
      checkInTime: data.dec(_f$checkInTime),
      method: data.dec(_f$method),
      checkedInBy: data.dec(_f$checkedInBy),
      memberMembership: data.dec(_f$memberMembership),
      notes: data.dec(_f$notes),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
      memberName: data.dec(_f$memberName),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CheckInDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CheckInDto>(map);
  }

  static CheckInDto fromJson(String json) {
    return ensureInitialized().decodeJson<CheckInDto>(json);
  }
}

mixin CheckInDtoMappable {
  String toJson() {
    return CheckInDtoMapper.ensureInitialized().encodeJson<CheckInDto>(
      this as CheckInDto,
    );
  }

  Map<String, dynamic> toMap() {
    return CheckInDtoMapper.ensureInitialized().encodeMap<CheckInDto>(
      this as CheckInDto,
    );
  }

  CheckInDtoCopyWith<CheckInDto, CheckInDto, CheckInDto> get copyWith =>
      _CheckInDtoCopyWithImpl<CheckInDto, CheckInDto>(
        this as CheckInDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CheckInDtoMapper.ensureInitialized().stringifyValue(
      this as CheckInDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return CheckInDtoMapper.ensureInitialized().equalsValue(
      this as CheckInDto,
      other,
    );
  }

  @override
  int get hashCode {
    return CheckInDtoMapper.ensureInitialized().hashValue(this as CheckInDto);
  }
}

extension CheckInDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CheckInDto, $Out> {
  CheckInDtoCopyWith<$R, CheckInDto, $Out> get $asCheckInDto =>
      $base.as((v, t, t2) => _CheckInDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CheckInDtoCopyWith<$R, $In extends CheckInDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? member,
    String? branch,
    String? checkInTime,
    String? method,
    String? checkedInBy,
    String? memberMembership,
    String? notes,
    String? created,
    String? updated,
    String? memberName,
  });
  CheckInDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CheckInDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CheckInDto, $Out>
    implements CheckInDtoCopyWith<$R, CheckInDto, $Out> {
  _CheckInDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CheckInDto> $mapper =
      CheckInDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? member,
    String? branch,
    Object? checkInTime = $none,
    String? method,
    Object? checkedInBy = $none,
    Object? memberMembership = $none,
    Object? notes = $none,
    Object? created = $none,
    Object? updated = $none,
    Object? memberName = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (member != null) #member: member,
      if (branch != null) #branch: branch,
      if (checkInTime != $none) #checkInTime: checkInTime,
      if (method != null) #method: method,
      if (checkedInBy != $none) #checkedInBy: checkedInBy,
      if (memberMembership != $none) #memberMembership: memberMembership,
      if (notes != $none) #notes: notes,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
      if (memberName != $none) #memberName: memberName,
    }),
  );
  @override
  CheckInDto $make(CopyWithData data) => CheckInDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    member: data.get(#member, or: $value.member),
    branch: data.get(#branch, or: $value.branch),
    checkInTime: data.get(#checkInTime, or: $value.checkInTime),
    method: data.get(#method, or: $value.method),
    checkedInBy: data.get(#checkedInBy, or: $value.checkedInBy),
    memberMembership: data.get(#memberMembership, or: $value.memberMembership),
    notes: data.get(#notes, or: $value.notes),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
    memberName: data.get(#memberName, or: $value.memberName),
  );

  @override
  CheckInDtoCopyWith<$R2, CheckInDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CheckInDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

