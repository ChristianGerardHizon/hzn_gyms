// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'member_card_dto.dart';

class MemberCardDtoMapper extends ClassMapperBase<MemberCardDto> {
  MemberCardDtoMapper._();

  static MemberCardDtoMapper? _instance;
  static MemberCardDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MemberCardDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'MemberCardDto';

  static String _$id(MemberCardDto v) => v.id;
  static const Field<MemberCardDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(MemberCardDto v) => v.collectionId;
  static const Field<MemberCardDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(MemberCardDto v) => v.collectionName;
  static const Field<MemberCardDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$member(MemberCardDto v) => v.member;
  static const Field<MemberCardDto, String> _f$member = Field(
    'member',
    _$member,
  );
  static String _$cardValue(MemberCardDto v) => v.cardValue;
  static const Field<MemberCardDto, String> _f$cardValue = Field(
    'cardValue',
    _$cardValue,
  );
  static String _$status(MemberCardDto v) => v.status;
  static const Field<MemberCardDto, String> _f$status = Field(
    'status',
    _$status,
  );
  static String? _$label(MemberCardDto v) => v.label;
  static const Field<MemberCardDto, String> _f$label = Field(
    'label',
    _$label,
    opt: true,
  );
  static String? _$deactivatedAt(MemberCardDto v) => v.deactivatedAt;
  static const Field<MemberCardDto, String> _f$deactivatedAt = Field(
    'deactivatedAt',
    _$deactivatedAt,
    opt: true,
  );
  static String? _$notes(MemberCardDto v) => v.notes;
  static const Field<MemberCardDto, String> _f$notes = Field(
    'notes',
    _$notes,
    opt: true,
  );
  static String? _$created(MemberCardDto v) => v.created;
  static const Field<MemberCardDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(MemberCardDto v) => v.updated;
  static const Field<MemberCardDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );
  static String? _$memberName(MemberCardDto v) => v.memberName;
  static const Field<MemberCardDto, String> _f$memberName = Field(
    'memberName',
    _$memberName,
    opt: true,
  );

  @override
  final MappableFields<MemberCardDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #member: _f$member,
    #cardValue: _f$cardValue,
    #status: _f$status,
    #label: _f$label,
    #deactivatedAt: _f$deactivatedAt,
    #notes: _f$notes,
    #created: _f$created,
    #updated: _f$updated,
    #memberName: _f$memberName,
  };

  static MemberCardDto _instantiate(DecodingData data) {
    return MemberCardDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      member: data.dec(_f$member),
      cardValue: data.dec(_f$cardValue),
      status: data.dec(_f$status),
      label: data.dec(_f$label),
      deactivatedAt: data.dec(_f$deactivatedAt),
      notes: data.dec(_f$notes),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
      memberName: data.dec(_f$memberName),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MemberCardDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MemberCardDto>(map);
  }

  static MemberCardDto fromJson(String json) {
    return ensureInitialized().decodeJson<MemberCardDto>(json);
  }
}

mixin MemberCardDtoMappable {
  String toJson() {
    return MemberCardDtoMapper.ensureInitialized().encodeJson<MemberCardDto>(
      this as MemberCardDto,
    );
  }

  Map<String, dynamic> toMap() {
    return MemberCardDtoMapper.ensureInitialized().encodeMap<MemberCardDto>(
      this as MemberCardDto,
    );
  }

  MemberCardDtoCopyWith<MemberCardDto, MemberCardDto, MemberCardDto>
  get copyWith => _MemberCardDtoCopyWithImpl<MemberCardDto, MemberCardDto>(
    this as MemberCardDto,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return MemberCardDtoMapper.ensureInitialized().stringifyValue(
      this as MemberCardDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return MemberCardDtoMapper.ensureInitialized().equalsValue(
      this as MemberCardDto,
      other,
    );
  }

  @override
  int get hashCode {
    return MemberCardDtoMapper.ensureInitialized().hashValue(
      this as MemberCardDto,
    );
  }
}

extension MemberCardDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MemberCardDto, $Out> {
  MemberCardDtoCopyWith<$R, MemberCardDto, $Out> get $asMemberCardDto =>
      $base.as((v, t, t2) => _MemberCardDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MemberCardDtoCopyWith<$R, $In extends MemberCardDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? member,
    String? cardValue,
    String? status,
    String? label,
    String? deactivatedAt,
    String? notes,
    String? created,
    String? updated,
    String? memberName,
  });
  MemberCardDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MemberCardDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MemberCardDto, $Out>
    implements MemberCardDtoCopyWith<$R, MemberCardDto, $Out> {
  _MemberCardDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MemberCardDto> $mapper =
      MemberCardDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? member,
    String? cardValue,
    String? status,
    Object? label = $none,
    Object? deactivatedAt = $none,
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
      if (cardValue != null) #cardValue: cardValue,
      if (status != null) #status: status,
      if (label != $none) #label: label,
      if (deactivatedAt != $none) #deactivatedAt: deactivatedAt,
      if (notes != $none) #notes: notes,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
      if (memberName != $none) #memberName: memberName,
    }),
  );
  @override
  MemberCardDto $make(CopyWithData data) => MemberCardDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    member: data.get(#member, or: $value.member),
    cardValue: data.get(#cardValue, or: $value.cardValue),
    status: data.get(#status, or: $value.status),
    label: data.get(#label, or: $value.label),
    deactivatedAt: data.get(#deactivatedAt, or: $value.deactivatedAt),
    notes: data.get(#notes, or: $value.notes),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
    memberName: data.get(#memberName, or: $value.memberName),
  );

  @override
  MemberCardDtoCopyWith<$R2, MemberCardDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MemberCardDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

