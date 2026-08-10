// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'check_in.dart';

class CheckInMethodMapper extends EnumMapper<CheckInMethod> {
  CheckInMethodMapper._();

  static CheckInMethodMapper? _instance;
  static CheckInMethodMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CheckInMethodMapper._());
    }
    return _instance!;
  }

  static CheckInMethod fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  CheckInMethod decode(dynamic value) {
    switch (value) {
      case r'manual':
        return CheckInMethod.manual;
      case r'rfid':
        return CheckInMethod.rfid;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(CheckInMethod self) {
    switch (self) {
      case CheckInMethod.manual:
        return r'manual';
      case CheckInMethod.rfid:
        return r'rfid';
    }
  }
}

extension CheckInMethodMapperExtension on CheckInMethod {
  String toValue() {
    CheckInMethodMapper.ensureInitialized();
    return MapperContainer.globals.toValue<CheckInMethod>(this) as String;
  }
}

class CheckInMapper extends ClassMapperBase<CheckIn> {
  CheckInMapper._();

  static CheckInMapper? _instance;
  static CheckInMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CheckInMapper._());
      CheckInMethodMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CheckIn';

  static String _$id(CheckIn v) => v.id;
  static const Field<CheckIn, String> _f$id = Field('id', _$id);
  static String _$memberId(CheckIn v) => v.memberId;
  static const Field<CheckIn, String> _f$memberId = Field(
    'memberId',
    _$memberId,
  );
  static String _$branchId(CheckIn v) => v.branchId;
  static const Field<CheckIn, String> _f$branchId = Field(
    'branchId',
    _$branchId,
  );
  static DateTime _$checkInTime(CheckIn v) => v.checkInTime;
  static const Field<CheckIn, DateTime> _f$checkInTime = Field(
    'checkInTime',
    _$checkInTime,
  );
  static CheckInMethod _$method(CheckIn v) => v.method;
  static const Field<CheckIn, CheckInMethod> _f$method = Field(
    'method',
    _$method,
  );
  static String? _$checkedInBy(CheckIn v) => v.checkedInBy;
  static const Field<CheckIn, String> _f$checkedInBy = Field(
    'checkedInBy',
    _$checkedInBy,
    opt: true,
  );
  static String? _$memberMembershipId(CheckIn v) => v.memberMembershipId;
  static const Field<CheckIn, String> _f$memberMembershipId = Field(
    'memberMembershipId',
    _$memberMembershipId,
    opt: true,
  );
  static String? _$memberName(CheckIn v) => v.memberName;
  static const Field<CheckIn, String> _f$memberName = Field(
    'memberName',
    _$memberName,
    opt: true,
  );
  static String? _$notes(CheckIn v) => v.notes;
  static const Field<CheckIn, String> _f$notes = Field(
    'notes',
    _$notes,
    opt: true,
  );
  static bool _$isVoided(CheckIn v) => v.isVoided;
  static const Field<CheckIn, bool> _f$isVoided = Field(
    'isVoided',
    _$isVoided,
    opt: true,
    def: false,
  );
  static DateTime? _$voidedAt(CheckIn v) => v.voidedAt;
  static const Field<CheckIn, DateTime> _f$voidedAt = Field(
    'voidedAt',
    _$voidedAt,
    opt: true,
  );
  static String? _$voidedBy(CheckIn v) => v.voidedBy;
  static const Field<CheckIn, String> _f$voidedBy = Field(
    'voidedBy',
    _$voidedBy,
    opt: true,
  );
  static String? _$voidReason(CheckIn v) => v.voidReason;
  static const Field<CheckIn, String> _f$voidReason = Field(
    'voidReason',
    _$voidReason,
    opt: true,
  );
  static DateTime? _$created(CheckIn v) => v.created;
  static const Field<CheckIn, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(CheckIn v) => v.updated;
  static const Field<CheckIn, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<CheckIn> fields = const {
    #id: _f$id,
    #memberId: _f$memberId,
    #branchId: _f$branchId,
    #checkInTime: _f$checkInTime,
    #method: _f$method,
    #checkedInBy: _f$checkedInBy,
    #memberMembershipId: _f$memberMembershipId,
    #memberName: _f$memberName,
    #notes: _f$notes,
    #isVoided: _f$isVoided,
    #voidedAt: _f$voidedAt,
    #voidedBy: _f$voidedBy,
    #voidReason: _f$voidReason,
    #created: _f$created,
    #updated: _f$updated,
  };

  static CheckIn _instantiate(DecodingData data) {
    return CheckIn(
      id: data.dec(_f$id),
      memberId: data.dec(_f$memberId),
      branchId: data.dec(_f$branchId),
      checkInTime: data.dec(_f$checkInTime),
      method: data.dec(_f$method),
      checkedInBy: data.dec(_f$checkedInBy),
      memberMembershipId: data.dec(_f$memberMembershipId),
      memberName: data.dec(_f$memberName),
      notes: data.dec(_f$notes),
      isVoided: data.dec(_f$isVoided),
      voidedAt: data.dec(_f$voidedAt),
      voidedBy: data.dec(_f$voidedBy),
      voidReason: data.dec(_f$voidReason),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CheckIn fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CheckIn>(map);
  }

  static CheckIn fromJson(String json) {
    return ensureInitialized().decodeJson<CheckIn>(json);
  }
}

mixin CheckInMappable {
  String toJson() {
    return CheckInMapper.ensureInitialized().encodeJson<CheckIn>(
      this as CheckIn,
    );
  }

  Map<String, dynamic> toMap() {
    return CheckInMapper.ensureInitialized().encodeMap<CheckIn>(
      this as CheckIn,
    );
  }

  CheckInCopyWith<CheckIn, CheckIn, CheckIn> get copyWith =>
      _CheckInCopyWithImpl<CheckIn, CheckIn>(
        this as CheckIn,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CheckInMapper.ensureInitialized().stringifyValue(this as CheckIn);
  }

  @override
  bool operator ==(Object other) {
    return CheckInMapper.ensureInitialized().equalsValue(
      this as CheckIn,
      other,
    );
  }

  @override
  int get hashCode {
    return CheckInMapper.ensureInitialized().hashValue(this as CheckIn);
  }
}

extension CheckInValueCopy<$R, $Out> on ObjectCopyWith<$R, CheckIn, $Out> {
  CheckInCopyWith<$R, CheckIn, $Out> get $asCheckIn =>
      $base.as((v, t, t2) => _CheckInCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CheckInCopyWith<$R, $In extends CheckIn, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? memberId,
    String? branchId,
    DateTime? checkInTime,
    CheckInMethod? method,
    String? checkedInBy,
    String? memberMembershipId,
    String? memberName,
    String? notes,
    bool? isVoided,
    DateTime? voidedAt,
    String? voidedBy,
    String? voidReason,
    DateTime? created,
    DateTime? updated,
  });
  CheckInCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CheckInCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CheckIn, $Out>
    implements CheckInCopyWith<$R, CheckIn, $Out> {
  _CheckInCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CheckIn> $mapper =
      CheckInMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? memberId,
    String? branchId,
    DateTime? checkInTime,
    CheckInMethod? method,
    Object? checkedInBy = $none,
    Object? memberMembershipId = $none,
    Object? memberName = $none,
    Object? notes = $none,
    bool? isVoided,
    Object? voidedAt = $none,
    Object? voidedBy = $none,
    Object? voidReason = $none,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (memberId != null) #memberId: memberId,
      if (branchId != null) #branchId: branchId,
      if (checkInTime != null) #checkInTime: checkInTime,
      if (method != null) #method: method,
      if (checkedInBy != $none) #checkedInBy: checkedInBy,
      if (memberMembershipId != $none) #memberMembershipId: memberMembershipId,
      if (memberName != $none) #memberName: memberName,
      if (notes != $none) #notes: notes,
      if (isVoided != null) #isVoided: isVoided,
      if (voidedAt != $none) #voidedAt: voidedAt,
      if (voidedBy != $none) #voidedBy: voidedBy,
      if (voidReason != $none) #voidReason: voidReason,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  CheckIn $make(CopyWithData data) => CheckIn(
    id: data.get(#id, or: $value.id),
    memberId: data.get(#memberId, or: $value.memberId),
    branchId: data.get(#branchId, or: $value.branchId),
    checkInTime: data.get(#checkInTime, or: $value.checkInTime),
    method: data.get(#method, or: $value.method),
    checkedInBy: data.get(#checkedInBy, or: $value.checkedInBy),
    memberMembershipId: data.get(
      #memberMembershipId,
      or: $value.memberMembershipId,
    ),
    memberName: data.get(#memberName, or: $value.memberName),
    notes: data.get(#notes, or: $value.notes),
    isVoided: data.get(#isVoided, or: $value.isVoided),
    voidedAt: data.get(#voidedAt, or: $value.voidedAt),
    voidedBy: data.get(#voidedBy, or: $value.voidedBy),
    voidReason: data.get(#voidReason, or: $value.voidReason),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  CheckInCopyWith<$R2, CheckIn, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _CheckInCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

