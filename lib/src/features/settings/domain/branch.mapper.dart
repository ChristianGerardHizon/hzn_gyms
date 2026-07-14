// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'branch.dart';

class BranchMapper extends ClassMapperBase<Branch> {
  BranchMapper._();

  static BranchMapper? _instance;
  static BranchMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = BranchMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Branch';

  static String _$id(Branch v) => v.id;
  static const Field<Branch, String> _f$id = Field('id', _$id);
  static String _$name(Branch v) => v.name;
  static const Field<Branch, String> _f$name = Field('name', _$name);
  static String _$address(Branch v) => v.address;
  static const Field<Branch, String> _f$address = Field('address', _$address);
  static String _$contactNumber(Branch v) => v.contactNumber;
  static const Field<Branch, String> _f$contactNumber = Field(
    'contactNumber',
    _$contactNumber,
  );
  static String? _$operatingHours(Branch v) => v.operatingHours;
  static const Field<Branch, String> _f$operatingHours = Field(
    'operatingHours',
    _$operatingHours,
    opt: true,
  );
  static String? _$cutOffTime(Branch v) => v.cutOffTime;
  static const Field<Branch, String> _f$cutOffTime = Field(
    'cutOffTime',
    _$cutOffTime,
    opt: true,
  );
  static bool _$isDeleted(Branch v) => v.isDeleted;
  static const Field<Branch, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static DateTime? _$created(Branch v) => v.created;
  static const Field<Branch, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(Branch v) => v.updated;
  static const Field<Branch, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<Branch> fields = const {
    #id: _f$id,
    #name: _f$name,
    #address: _f$address,
    #contactNumber: _f$contactNumber,
    #operatingHours: _f$operatingHours,
    #cutOffTime: _f$cutOffTime,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static Branch _instantiate(DecodingData data) {
    return Branch(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      address: data.dec(_f$address),
      contactNumber: data.dec(_f$contactNumber),
      operatingHours: data.dec(_f$operatingHours),
      cutOffTime: data.dec(_f$cutOffTime),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Branch fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Branch>(map);
  }

  static Branch fromJson(String json) {
    return ensureInitialized().decodeJson<Branch>(json);
  }
}

mixin BranchMappable {
  String toJson() {
    return BranchMapper.ensureInitialized().encodeJson<Branch>(this as Branch);
  }

  Map<String, dynamic> toMap() {
    return BranchMapper.ensureInitialized().encodeMap<Branch>(this as Branch);
  }

  BranchCopyWith<Branch, Branch, Branch> get copyWith =>
      _BranchCopyWithImpl<Branch, Branch>(this as Branch, $identity, $identity);
  @override
  String toString() {
    return BranchMapper.ensureInitialized().stringifyValue(this as Branch);
  }

  @override
  bool operator ==(Object other) {
    return BranchMapper.ensureInitialized().equalsValue(this as Branch, other);
  }

  @override
  int get hashCode {
    return BranchMapper.ensureInitialized().hashValue(this as Branch);
  }
}

extension BranchValueCopy<$R, $Out> on ObjectCopyWith<$R, Branch, $Out> {
  BranchCopyWith<$R, Branch, $Out> get $asBranch =>
      $base.as((v, t, t2) => _BranchCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class BranchCopyWith<$R, $In extends Branch, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    String? address,
    String? contactNumber,
    String? operatingHours,
    String? cutOffTime,
    bool? isDeleted,
    DateTime? created,
    DateTime? updated,
  });
  BranchCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _BranchCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Branch, $Out>
    implements BranchCopyWith<$R, Branch, $Out> {
  _BranchCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Branch> $mapper = BranchMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? name,
    String? address,
    String? contactNumber,
    Object? operatingHours = $none,
    Object? cutOffTime = $none,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (address != null) #address: address,
      if (contactNumber != null) #contactNumber: contactNumber,
      if (operatingHours != $none) #operatingHours: operatingHours,
      if (cutOffTime != $none) #cutOffTime: cutOffTime,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  Branch $make(CopyWithData data) => Branch(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    address: data.get(#address, or: $value.address),
    contactNumber: data.get(#contactNumber, or: $value.contactNumber),
    operatingHours: data.get(#operatingHours, or: $value.operatingHours),
    cutOffTime: data.get(#cutOffTime, or: $value.cutOffTime),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  BranchCopyWith<$R2, Branch, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _BranchCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

