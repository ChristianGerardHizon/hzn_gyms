// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'membership_add_on.dart';

class MembershipAddOnMapper extends ClassMapperBase<MembershipAddOn> {
  MembershipAddOnMapper._();

  static MembershipAddOnMapper? _instance;
  static MembershipAddOnMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MembershipAddOnMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'MembershipAddOn';

  static String _$id(MembershipAddOn v) => v.id;
  static const Field<MembershipAddOn, String> _f$id = Field('id', _$id);
  static String _$membershipId(MembershipAddOn v) => v.membershipId;
  static const Field<MembershipAddOn, String> _f$membershipId = Field(
    'membershipId',
    _$membershipId,
  );
  static String _$name(MembershipAddOn v) => v.name;
  static const Field<MembershipAddOn, String> _f$name = Field('name', _$name);
  static num _$price(MembershipAddOn v) => v.price;
  static const Field<MembershipAddOn, num> _f$price = Field('price', _$price);
  static String? _$description(MembershipAddOn v) => v.description;
  static const Field<MembershipAddOn, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );
  static bool _$isActive(MembershipAddOn v) => v.isActive;
  static const Field<MembershipAddOn, bool> _f$isActive = Field(
    'isActive',
    _$isActive,
    opt: true,
    def: true,
  );
  static DateTime? _$created(MembershipAddOn v) => v.created;
  static const Field<MembershipAddOn, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(MembershipAddOn v) => v.updated;
  static const Field<MembershipAddOn, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<MembershipAddOn> fields = const {
    #id: _f$id,
    #membershipId: _f$membershipId,
    #name: _f$name,
    #price: _f$price,
    #description: _f$description,
    #isActive: _f$isActive,
    #created: _f$created,
    #updated: _f$updated,
  };

  static MembershipAddOn _instantiate(DecodingData data) {
    return MembershipAddOn(
      id: data.dec(_f$id),
      membershipId: data.dec(_f$membershipId),
      name: data.dec(_f$name),
      price: data.dec(_f$price),
      description: data.dec(_f$description),
      isActive: data.dec(_f$isActive),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MembershipAddOn fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MembershipAddOn>(map);
  }

  static MembershipAddOn fromJson(String json) {
    return ensureInitialized().decodeJson<MembershipAddOn>(json);
  }
}

mixin MembershipAddOnMappable {
  String toJson() {
    return MembershipAddOnMapper.ensureInitialized()
        .encodeJson<MembershipAddOn>(this as MembershipAddOn);
  }

  Map<String, dynamic> toMap() {
    return MembershipAddOnMapper.ensureInitialized().encodeMap<MembershipAddOn>(
      this as MembershipAddOn,
    );
  }

  MembershipAddOnCopyWith<MembershipAddOn, MembershipAddOn, MembershipAddOn>
  get copyWith =>
      _MembershipAddOnCopyWithImpl<MembershipAddOn, MembershipAddOn>(
        this as MembershipAddOn,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return MembershipAddOnMapper.ensureInitialized().stringifyValue(
      this as MembershipAddOn,
    );
  }

  @override
  bool operator ==(Object other) {
    return MembershipAddOnMapper.ensureInitialized().equalsValue(
      this as MembershipAddOn,
      other,
    );
  }

  @override
  int get hashCode {
    return MembershipAddOnMapper.ensureInitialized().hashValue(
      this as MembershipAddOn,
    );
  }
}

extension MembershipAddOnValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MembershipAddOn, $Out> {
  MembershipAddOnCopyWith<$R, MembershipAddOn, $Out> get $asMembershipAddOn =>
      $base.as((v, t, t2) => _MembershipAddOnCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MembershipAddOnCopyWith<$R, $In extends MembershipAddOn, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? membershipId,
    String? name,
    num? price,
    String? description,
    bool? isActive,
    DateTime? created,
    DateTime? updated,
  });
  MembershipAddOnCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _MembershipAddOnCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MembershipAddOn, $Out>
    implements MembershipAddOnCopyWith<$R, MembershipAddOn, $Out> {
  _MembershipAddOnCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MembershipAddOn> $mapper =
      MembershipAddOnMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? membershipId,
    String? name,
    num? price,
    Object? description = $none,
    bool? isActive,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (membershipId != null) #membershipId: membershipId,
      if (name != null) #name: name,
      if (price != null) #price: price,
      if (description != $none) #description: description,
      if (isActive != null) #isActive: isActive,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  MembershipAddOn $make(CopyWithData data) => MembershipAddOn(
    id: data.get(#id, or: $value.id),
    membershipId: data.get(#membershipId, or: $value.membershipId),
    name: data.get(#name, or: $value.name),
    price: data.get(#price, or: $value.price),
    description: data.get(#description, or: $value.description),
    isActive: data.get(#isActive, or: $value.isActive),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  MembershipAddOnCopyWith<$R2, MembershipAddOn, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MembershipAddOnCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

