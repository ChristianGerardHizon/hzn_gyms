// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'member_membership.dart';

class MemberMembershipStatusMapper extends EnumMapper<MemberMembershipStatus> {
  MemberMembershipStatusMapper._();

  static MemberMembershipStatusMapper? _instance;
  static MemberMembershipStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MemberMembershipStatusMapper._());
    }
    return _instance!;
  }

  static MemberMembershipStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  MemberMembershipStatus decode(dynamic value) {
    switch (value) {
      case r'active':
        return MemberMembershipStatus.active;
      case r'expired':
        return MemberMembershipStatus.expired;
      case r'cancelled':
        return MemberMembershipStatus.cancelled;
      case r'voided':
        return MemberMembershipStatus.voided;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(MemberMembershipStatus self) {
    switch (self) {
      case MemberMembershipStatus.active:
        return r'active';
      case MemberMembershipStatus.expired:
        return r'expired';
      case MemberMembershipStatus.cancelled:
        return r'cancelled';
      case MemberMembershipStatus.voided:
        return r'voided';
    }
  }
}

extension MemberMembershipStatusMapperExtension on MemberMembershipStatus {
  String toValue() {
    MemberMembershipStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<MemberMembershipStatus>(this)
        as String;
  }
}

class MemberMembershipMapper extends ClassMapperBase<MemberMembership> {
  MemberMembershipMapper._();

  static MemberMembershipMapper? _instance;
  static MemberMembershipMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MemberMembershipMapper._());
      MemberMembershipStatusMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'MemberMembership';

  static String _$id(MemberMembership v) => v.id;
  static const Field<MemberMembership, String> _f$id = Field('id', _$id);
  static String _$memberId(MemberMembership v) => v.memberId;
  static const Field<MemberMembership, String> _f$memberId = Field(
    'memberId',
    _$memberId,
  );
  static String _$membershipId(MemberMembership v) => v.membershipId;
  static const Field<MemberMembership, String> _f$membershipId = Field(
    'membershipId',
    _$membershipId,
  );
  static DateTime _$startDate(MemberMembership v) => v.startDate;
  static const Field<MemberMembership, DateTime> _f$startDate = Field(
    'startDate',
    _$startDate,
  );
  static DateTime _$endDate(MemberMembership v) => v.endDate;
  static const Field<MemberMembership, DateTime> _f$endDate = Field(
    'endDate',
    _$endDate,
  );
  static MemberMembershipStatus _$status(MemberMembership v) => v.status;
  static const Field<MemberMembership, MemberMembershipStatus> _f$status =
      Field('status', _$status);
  static String _$branchId(MemberMembership v) => v.branchId;
  static const Field<MemberMembership, String> _f$branchId = Field(
    'branchId',
    _$branchId,
  );
  static String? _$memberName(MemberMembership v) => v.memberName;
  static const Field<MemberMembership, String> _f$memberName = Field(
    'memberName',
    _$memberName,
    opt: true,
  );
  static String? _$membershipName(MemberMembership v) => v.membershipName;
  static const Field<MemberMembership, String> _f$membershipName = Field(
    'membershipName',
    _$membershipName,
    opt: true,
  );
  static String? _$saleId(MemberMembership v) => v.saleId;
  static const Field<MemberMembership, String> _f$saleId = Field(
    'saleId',
    _$saleId,
    opt: true,
  );
  static String? _$soldBy(MemberMembership v) => v.soldBy;
  static const Field<MemberMembership, String> _f$soldBy = Field(
    'soldBy',
    _$soldBy,
    opt: true,
  );
  static String? _$notes(MemberMembership v) => v.notes;
  static const Field<MemberMembership, String> _f$notes = Field(
    'notes',
    _$notes,
    opt: true,
  );
  static DateTime? _$created(MemberMembership v) => v.created;
  static const Field<MemberMembership, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(MemberMembership v) => v.updated;
  static const Field<MemberMembership, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<MemberMembership> fields = const {
    #id: _f$id,
    #memberId: _f$memberId,
    #membershipId: _f$membershipId,
    #startDate: _f$startDate,
    #endDate: _f$endDate,
    #status: _f$status,
    #branchId: _f$branchId,
    #memberName: _f$memberName,
    #membershipName: _f$membershipName,
    #saleId: _f$saleId,
    #soldBy: _f$soldBy,
    #notes: _f$notes,
    #created: _f$created,
    #updated: _f$updated,
  };

  static MemberMembership _instantiate(DecodingData data) {
    return MemberMembership(
      id: data.dec(_f$id),
      memberId: data.dec(_f$memberId),
      membershipId: data.dec(_f$membershipId),
      startDate: data.dec(_f$startDate),
      endDate: data.dec(_f$endDate),
      status: data.dec(_f$status),
      branchId: data.dec(_f$branchId),
      memberName: data.dec(_f$memberName),
      membershipName: data.dec(_f$membershipName),
      saleId: data.dec(_f$saleId),
      soldBy: data.dec(_f$soldBy),
      notes: data.dec(_f$notes),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MemberMembership fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MemberMembership>(map);
  }

  static MemberMembership fromJson(String json) {
    return ensureInitialized().decodeJson<MemberMembership>(json);
  }
}

mixin MemberMembershipMappable {
  String toJson() {
    return MemberMembershipMapper.ensureInitialized()
        .encodeJson<MemberMembership>(this as MemberMembership);
  }

  Map<String, dynamic> toMap() {
    return MemberMembershipMapper.ensureInitialized()
        .encodeMap<MemberMembership>(this as MemberMembership);
  }

  MemberMembershipCopyWith<MemberMembership, MemberMembership, MemberMembership>
  get copyWith =>
      _MemberMembershipCopyWithImpl<MemberMembership, MemberMembership>(
        this as MemberMembership,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return MemberMembershipMapper.ensureInitialized().stringifyValue(
      this as MemberMembership,
    );
  }

  @override
  bool operator ==(Object other) {
    return MemberMembershipMapper.ensureInitialized().equalsValue(
      this as MemberMembership,
      other,
    );
  }

  @override
  int get hashCode {
    return MemberMembershipMapper.ensureInitialized().hashValue(
      this as MemberMembership,
    );
  }
}

extension MemberMembershipValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MemberMembership, $Out> {
  MemberMembershipCopyWith<$R, MemberMembership, $Out>
  get $asMemberMembership =>
      $base.as((v, t, t2) => _MemberMembershipCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MemberMembershipCopyWith<$R, $In extends MemberMembership, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? memberId,
    String? membershipId,
    DateTime? startDate,
    DateTime? endDate,
    MemberMembershipStatus? status,
    String? branchId,
    String? memberName,
    String? membershipName,
    String? saleId,
    String? soldBy,
    String? notes,
    DateTime? created,
    DateTime? updated,
  });
  MemberMembershipCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _MemberMembershipCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MemberMembership, $Out>
    implements MemberMembershipCopyWith<$R, MemberMembership, $Out> {
  _MemberMembershipCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MemberMembership> $mapper =
      MemberMembershipMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? memberId,
    String? membershipId,
    DateTime? startDate,
    DateTime? endDate,
    MemberMembershipStatus? status,
    String? branchId,
    Object? memberName = $none,
    Object? membershipName = $none,
    Object? saleId = $none,
    Object? soldBy = $none,
    Object? notes = $none,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (memberId != null) #memberId: memberId,
      if (membershipId != null) #membershipId: membershipId,
      if (startDate != null) #startDate: startDate,
      if (endDate != null) #endDate: endDate,
      if (status != null) #status: status,
      if (branchId != null) #branchId: branchId,
      if (memberName != $none) #memberName: memberName,
      if (membershipName != $none) #membershipName: membershipName,
      if (saleId != $none) #saleId: saleId,
      if (soldBy != $none) #soldBy: soldBy,
      if (notes != $none) #notes: notes,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  MemberMembership $make(CopyWithData data) => MemberMembership(
    id: data.get(#id, or: $value.id),
    memberId: data.get(#memberId, or: $value.memberId),
    membershipId: data.get(#membershipId, or: $value.membershipId),
    startDate: data.get(#startDate, or: $value.startDate),
    endDate: data.get(#endDate, or: $value.endDate),
    status: data.get(#status, or: $value.status),
    branchId: data.get(#branchId, or: $value.branchId),
    memberName: data.get(#memberName, or: $value.memberName),
    membershipName: data.get(#membershipName, or: $value.membershipName),
    saleId: data.get(#saleId, or: $value.saleId),
    soldBy: data.get(#soldBy, or: $value.soldBy),
    notes: data.get(#notes, or: $value.notes),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  MemberMembershipCopyWith<$R2, MemberMembership, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MemberMembershipCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

