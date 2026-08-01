// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'membership.dart';

class MembershipMapper extends ClassMapperBase<Membership> {
  MembershipMapper._();

  static MembershipMapper? _instance;
  static MembershipMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MembershipMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Membership';

  static String _$id(Membership v) => v.id;
  static const Field<Membership, String> _f$id = Field('id', _$id);
  static String _$name(Membership v) => v.name;
  static const Field<Membership, String> _f$name = Field('name', _$name);
  static int _$durationValue(Membership v) => v.durationValue;
  static const Field<Membership, int> _f$durationValue = Field(
    'durationValue',
    _$durationValue,
  );
  static MembershipDurationUnit _$durationUnit(Membership v) => v.durationUnit;
  static const Field<Membership, MembershipDurationUnit> _f$durationUnit =
      Field(
        'durationUnit',
        _$durationUnit,
        opt: true,
        def: MembershipDurationUnit.days,
      );
  static num _$price(Membership v) => v.price;
  static const Field<Membership, num> _f$price = Field('price', _$price);
  static String _$branchId(Membership v) => v.branchId;
  static const Field<Membership, String> _f$branchId = Field(
    'branchId',
    _$branchId,
  );
  static List<String> _$validBranches(Membership v) => v.validBranches;
  static const Field<Membership, List<String>> _f$validBranches = Field(
    'validBranches',
    _$validBranches,
    opt: true,
    def: const [],
  );
  static String? _$description(Membership v) => v.description;
  static const Field<Membership, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );
  static bool _$isActive(Membership v) => v.isActive;
  static const Field<Membership, bool> _f$isActive = Field(
    'isActive',
    _$isActive,
    opt: true,
    def: true,
  );
  static bool _$isFavorite(Membership v) => v.isFavorite;
  static const Field<Membership, bool> _f$isFavorite = Field(
    'isFavorite',
    _$isFavorite,
    opt: true,
    def: false,
  );
  static bool _$memberNotRequired(Membership v) => v.memberNotRequired;
  static const Field<Membership, bool> _f$memberNotRequired = Field(
    'memberNotRequired',
    _$memberNotRequired,
    opt: true,
    def: false,
  );
  static DateTime? _$created(Membership v) => v.created;
  static const Field<Membership, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(Membership v) => v.updated;
  static const Field<Membership, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<Membership> fields = const {
    #id: _f$id,
    #name: _f$name,
    #durationValue: _f$durationValue,
    #durationUnit: _f$durationUnit,
    #price: _f$price,
    #branchId: _f$branchId,
    #validBranches: _f$validBranches,
    #description: _f$description,
    #isActive: _f$isActive,
    #isFavorite: _f$isFavorite,
    #memberNotRequired: _f$memberNotRequired,
    #created: _f$created,
    #updated: _f$updated,
  };

  static Membership _instantiate(DecodingData data) {
    return Membership(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      durationValue: data.dec(_f$durationValue),
      durationUnit: data.dec(_f$durationUnit),
      price: data.dec(_f$price),
      branchId: data.dec(_f$branchId),
      validBranches: data.dec(_f$validBranches),
      description: data.dec(_f$description),
      isActive: data.dec(_f$isActive),
      isFavorite: data.dec(_f$isFavorite),
      memberNotRequired: data.dec(_f$memberNotRequired),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Membership fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Membership>(map);
  }

  static Membership fromJson(String json) {
    return ensureInitialized().decodeJson<Membership>(json);
  }
}

mixin MembershipMappable {
  String toJson() {
    return MembershipMapper.ensureInitialized().encodeJson<Membership>(
      this as Membership,
    );
  }

  Map<String, dynamic> toMap() {
    return MembershipMapper.ensureInitialized().encodeMap<Membership>(
      this as Membership,
    );
  }

  MembershipCopyWith<Membership, Membership, Membership> get copyWith =>
      _MembershipCopyWithImpl<Membership, Membership>(
        this as Membership,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return MembershipMapper.ensureInitialized().stringifyValue(
      this as Membership,
    );
  }

  @override
  bool operator ==(Object other) {
    return MembershipMapper.ensureInitialized().equalsValue(
      this as Membership,
      other,
    );
  }

  @override
  int get hashCode {
    return MembershipMapper.ensureInitialized().hashValue(this as Membership);
  }
}

extension MembershipValueCopy<$R, $Out>
    on ObjectCopyWith<$R, Membership, $Out> {
  MembershipCopyWith<$R, Membership, $Out> get $asMembership =>
      $base.as((v, t, t2) => _MembershipCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MembershipCopyWith<$R, $In extends Membership, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get validBranches;
  $R call({
    String? id,
    String? name,
    int? durationValue,
    MembershipDurationUnit? durationUnit,
    num? price,
    String? branchId,
    List<String>? validBranches,
    String? description,
    bool? isActive,
    bool? isFavorite,
    bool? memberNotRequired,
    DateTime? created,
    DateTime? updated,
  });
  MembershipCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MembershipCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Membership, $Out>
    implements MembershipCopyWith<$R, Membership, $Out> {
  _MembershipCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Membership> $mapper =
      MembershipMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get validBranches => ListCopyWith(
    $value.validBranches,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(validBranches: v),
  );
  @override
  $R call({
    String? id,
    String? name,
    int? durationValue,
    MembershipDurationUnit? durationUnit,
    num? price,
    String? branchId,
    List<String>? validBranches,
    Object? description = $none,
    bool? isActive,
    bool? isFavorite,
    bool? memberNotRequired,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (durationValue != null) #durationValue: durationValue,
      if (durationUnit != null) #durationUnit: durationUnit,
      if (price != null) #price: price,
      if (branchId != null) #branchId: branchId,
      if (validBranches != null) #validBranches: validBranches,
      if (description != $none) #description: description,
      if (isActive != null) #isActive: isActive,
      if (isFavorite != null) #isFavorite: isFavorite,
      if (memberNotRequired != null) #memberNotRequired: memberNotRequired,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  Membership $make(CopyWithData data) => Membership(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    durationValue: data.get(#durationValue, or: $value.durationValue),
    durationUnit: data.get(#durationUnit, or: $value.durationUnit),
    price: data.get(#price, or: $value.price),
    branchId: data.get(#branchId, or: $value.branchId),
    validBranches: data.get(#validBranches, or: $value.validBranches),
    description: data.get(#description, or: $value.description),
    isActive: data.get(#isActive, or: $value.isActive),
    isFavorite: data.get(#isFavorite, or: $value.isFavorite),
    memberNotRequired: data.get(
      #memberNotRequired,
      or: $value.memberNotRequired,
    ),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  MembershipCopyWith<$R2, Membership, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MembershipCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

