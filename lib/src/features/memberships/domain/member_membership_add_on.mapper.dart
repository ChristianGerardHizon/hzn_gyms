// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'member_membership_add_on.dart';

class MemberMembershipAddOnMapper
    extends ClassMapperBase<MemberMembershipAddOn> {
  MemberMembershipAddOnMapper._();

  static MemberMembershipAddOnMapper? _instance;
  static MemberMembershipAddOnMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MemberMembershipAddOnMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'MemberMembershipAddOn';

  static String _$id(MemberMembershipAddOn v) => v.id;
  static const Field<MemberMembershipAddOn, String> _f$id = Field('id', _$id);
  static String _$memberMembershipId(MemberMembershipAddOn v) =>
      v.memberMembershipId;
  static const Field<MemberMembershipAddOn, String> _f$memberMembershipId =
      Field('memberMembershipId', _$memberMembershipId);
  static String _$membershipAddOnId(MemberMembershipAddOn v) =>
      v.membershipAddOnId;
  static const Field<MemberMembershipAddOn, String> _f$membershipAddOnId =
      Field('membershipAddOnId', _$membershipAddOnId);
  static String _$addOnName(MemberMembershipAddOn v) => v.addOnName;
  static const Field<MemberMembershipAddOn, String> _f$addOnName = Field(
    'addOnName',
    _$addOnName,
  );
  static num _$price(MemberMembershipAddOn v) => v.price;
  static const Field<MemberMembershipAddOn, num> _f$price = Field(
    'price',
    _$price,
  );
  static DateTime? _$created(MemberMembershipAddOn v) => v.created;
  static const Field<MemberMembershipAddOn, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(MemberMembershipAddOn v) => v.updated;
  static const Field<MemberMembershipAddOn, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<MemberMembershipAddOn> fields = const {
    #id: _f$id,
    #memberMembershipId: _f$memberMembershipId,
    #membershipAddOnId: _f$membershipAddOnId,
    #addOnName: _f$addOnName,
    #price: _f$price,
    #created: _f$created,
    #updated: _f$updated,
  };

  static MemberMembershipAddOn _instantiate(DecodingData data) {
    return MemberMembershipAddOn(
      id: data.dec(_f$id),
      memberMembershipId: data.dec(_f$memberMembershipId),
      membershipAddOnId: data.dec(_f$membershipAddOnId),
      addOnName: data.dec(_f$addOnName),
      price: data.dec(_f$price),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MemberMembershipAddOn fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MemberMembershipAddOn>(map);
  }

  static MemberMembershipAddOn fromJson(String json) {
    return ensureInitialized().decodeJson<MemberMembershipAddOn>(json);
  }
}

mixin MemberMembershipAddOnMappable {
  String toJson() {
    return MemberMembershipAddOnMapper.ensureInitialized()
        .encodeJson<MemberMembershipAddOn>(this as MemberMembershipAddOn);
  }

  Map<String, dynamic> toMap() {
    return MemberMembershipAddOnMapper.ensureInitialized()
        .encodeMap<MemberMembershipAddOn>(this as MemberMembershipAddOn);
  }

  MemberMembershipAddOnCopyWith<
    MemberMembershipAddOn,
    MemberMembershipAddOn,
    MemberMembershipAddOn
  >
  get copyWith =>
      _MemberMembershipAddOnCopyWithImpl<
        MemberMembershipAddOn,
        MemberMembershipAddOn
      >(this as MemberMembershipAddOn, $identity, $identity);
  @override
  String toString() {
    return MemberMembershipAddOnMapper.ensureInitialized().stringifyValue(
      this as MemberMembershipAddOn,
    );
  }

  @override
  bool operator ==(Object other) {
    return MemberMembershipAddOnMapper.ensureInitialized().equalsValue(
      this as MemberMembershipAddOn,
      other,
    );
  }

  @override
  int get hashCode {
    return MemberMembershipAddOnMapper.ensureInitialized().hashValue(
      this as MemberMembershipAddOn,
    );
  }
}

extension MemberMembershipAddOnValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MemberMembershipAddOn, $Out> {
  MemberMembershipAddOnCopyWith<$R, MemberMembershipAddOn, $Out>
  get $asMemberMembershipAddOn => $base.as(
    (v, t, t2) => _MemberMembershipAddOnCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class MemberMembershipAddOnCopyWith<
  $R,
  $In extends MemberMembershipAddOn,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? memberMembershipId,
    String? membershipAddOnId,
    String? addOnName,
    num? price,
    DateTime? created,
    DateTime? updated,
  });
  MemberMembershipAddOnCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _MemberMembershipAddOnCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MemberMembershipAddOn, $Out>
    implements MemberMembershipAddOnCopyWith<$R, MemberMembershipAddOn, $Out> {
  _MemberMembershipAddOnCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MemberMembershipAddOn> $mapper =
      MemberMembershipAddOnMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? memberMembershipId,
    String? membershipAddOnId,
    String? addOnName,
    num? price,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (memberMembershipId != null) #memberMembershipId: memberMembershipId,
      if (membershipAddOnId != null) #membershipAddOnId: membershipAddOnId,
      if (addOnName != null) #addOnName: addOnName,
      if (price != null) #price: price,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  MemberMembershipAddOn $make(CopyWithData data) => MemberMembershipAddOn(
    id: data.get(#id, or: $value.id),
    memberMembershipId: data.get(
      #memberMembershipId,
      or: $value.memberMembershipId,
    ),
    membershipAddOnId: data.get(
      #membershipAddOnId,
      or: $value.membershipAddOnId,
    ),
    addOnName: data.get(#addOnName, or: $value.addOnName),
    price: data.get(#price, or: $value.price),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  MemberMembershipAddOnCopyWith<$R2, MemberMembershipAddOn, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _MemberMembershipAddOnCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

