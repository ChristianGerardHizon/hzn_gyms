// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'member_card.dart';

class MemberCardStatusMapper extends EnumMapper<MemberCardStatus> {
  MemberCardStatusMapper._();

  static MemberCardStatusMapper? _instance;
  static MemberCardStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MemberCardStatusMapper._());
    }
    return _instance!;
  }

  static MemberCardStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  MemberCardStatus decode(dynamic value) {
    switch (value) {
      case r'active':
        return MemberCardStatus.active;
      case r'lost':
        return MemberCardStatus.lost;
      case r'deactivated':
        return MemberCardStatus.deactivated;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(MemberCardStatus self) {
    switch (self) {
      case MemberCardStatus.active:
        return r'active';
      case MemberCardStatus.lost:
        return r'lost';
      case MemberCardStatus.deactivated:
        return r'deactivated';
    }
  }
}

extension MemberCardStatusMapperExtension on MemberCardStatus {
  String toValue() {
    MemberCardStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<MemberCardStatus>(this) as String;
  }
}

class MemberCardMapper extends ClassMapperBase<MemberCard> {
  MemberCardMapper._();

  static MemberCardMapper? _instance;
  static MemberCardMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MemberCardMapper._());
      MemberCardStatusMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'MemberCard';

  static String _$id(MemberCard v) => v.id;
  static const Field<MemberCard, String> _f$id = Field('id', _$id);
  static String _$memberId(MemberCard v) => v.memberId;
  static const Field<MemberCard, String> _f$memberId = Field(
    'memberId',
    _$memberId,
  );
  static String _$cardValue(MemberCard v) => v.cardValue;
  static const Field<MemberCard, String> _f$cardValue = Field(
    'cardValue',
    _$cardValue,
  );
  static MemberCardStatus _$status(MemberCard v) => v.status;
  static const Field<MemberCard, MemberCardStatus> _f$status = Field(
    'status',
    _$status,
  );
  static String? _$label(MemberCard v) => v.label;
  static const Field<MemberCard, String> _f$label = Field(
    'label',
    _$label,
    opt: true,
  );
  static DateTime? _$deactivatedAt(MemberCard v) => v.deactivatedAt;
  static const Field<MemberCard, DateTime> _f$deactivatedAt = Field(
    'deactivatedAt',
    _$deactivatedAt,
    opt: true,
  );
  static String? _$notes(MemberCard v) => v.notes;
  static const Field<MemberCard, String> _f$notes = Field(
    'notes',
    _$notes,
    opt: true,
  );
  static String? _$memberName(MemberCard v) => v.memberName;
  static const Field<MemberCard, String> _f$memberName = Field(
    'memberName',
    _$memberName,
    opt: true,
  );
  static DateTime? _$created(MemberCard v) => v.created;
  static const Field<MemberCard, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(MemberCard v) => v.updated;
  static const Field<MemberCard, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<MemberCard> fields = const {
    #id: _f$id,
    #memberId: _f$memberId,
    #cardValue: _f$cardValue,
    #status: _f$status,
    #label: _f$label,
    #deactivatedAt: _f$deactivatedAt,
    #notes: _f$notes,
    #memberName: _f$memberName,
    #created: _f$created,
    #updated: _f$updated,
  };

  static MemberCard _instantiate(DecodingData data) {
    return MemberCard(
      id: data.dec(_f$id),
      memberId: data.dec(_f$memberId),
      cardValue: data.dec(_f$cardValue),
      status: data.dec(_f$status),
      label: data.dec(_f$label),
      deactivatedAt: data.dec(_f$deactivatedAt),
      notes: data.dec(_f$notes),
      memberName: data.dec(_f$memberName),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MemberCard fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MemberCard>(map);
  }

  static MemberCard fromJson(String json) {
    return ensureInitialized().decodeJson<MemberCard>(json);
  }
}

mixin MemberCardMappable {
  String toJson() {
    return MemberCardMapper.ensureInitialized().encodeJson<MemberCard>(
      this as MemberCard,
    );
  }

  Map<String, dynamic> toMap() {
    return MemberCardMapper.ensureInitialized().encodeMap<MemberCard>(
      this as MemberCard,
    );
  }

  MemberCardCopyWith<MemberCard, MemberCard, MemberCard> get copyWith =>
      _MemberCardCopyWithImpl<MemberCard, MemberCard>(
        this as MemberCard,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return MemberCardMapper.ensureInitialized().stringifyValue(
      this as MemberCard,
    );
  }

  @override
  bool operator ==(Object other) {
    return MemberCardMapper.ensureInitialized().equalsValue(
      this as MemberCard,
      other,
    );
  }

  @override
  int get hashCode {
    return MemberCardMapper.ensureInitialized().hashValue(this as MemberCard);
  }
}

extension MemberCardValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MemberCard, $Out> {
  MemberCardCopyWith<$R, MemberCard, $Out> get $asMemberCard =>
      $base.as((v, t, t2) => _MemberCardCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MemberCardCopyWith<$R, $In extends MemberCard, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? memberId,
    String? cardValue,
    MemberCardStatus? status,
    String? label,
    DateTime? deactivatedAt,
    String? notes,
    String? memberName,
    DateTime? created,
    DateTime? updated,
  });
  MemberCardCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MemberCardCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MemberCard, $Out>
    implements MemberCardCopyWith<$R, MemberCard, $Out> {
  _MemberCardCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MemberCard> $mapper =
      MemberCardMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? memberId,
    String? cardValue,
    MemberCardStatus? status,
    Object? label = $none,
    Object? deactivatedAt = $none,
    Object? notes = $none,
    Object? memberName = $none,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (memberId != null) #memberId: memberId,
      if (cardValue != null) #cardValue: cardValue,
      if (status != null) #status: status,
      if (label != $none) #label: label,
      if (deactivatedAt != $none) #deactivatedAt: deactivatedAt,
      if (notes != $none) #notes: notes,
      if (memberName != $none) #memberName: memberName,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  MemberCard $make(CopyWithData data) => MemberCard(
    id: data.get(#id, or: $value.id),
    memberId: data.get(#memberId, or: $value.memberId),
    cardValue: data.get(#cardValue, or: $value.cardValue),
    status: data.get(#status, or: $value.status),
    label: data.get(#label, or: $value.label),
    deactivatedAt: data.get(#deactivatedAt, or: $value.deactivatedAt),
    notes: data.get(#notes, or: $value.notes),
    memberName: data.get(#memberName, or: $value.memberName),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  MemberCardCopyWith<$R2, MemberCard, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MemberCardCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

