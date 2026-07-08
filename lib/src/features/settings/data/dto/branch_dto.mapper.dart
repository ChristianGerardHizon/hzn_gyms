// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'branch_dto.dart';

class BranchDtoMapper extends ClassMapperBase<BranchDto> {
  BranchDtoMapper._();

  static BranchDtoMapper? _instance;
  static BranchDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = BranchDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'BranchDto';

  static String _$id(BranchDto v) => v.id;
  static const Field<BranchDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(BranchDto v) => v.collectionId;
  static const Field<BranchDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(BranchDto v) => v.collectionName;
  static const Field<BranchDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$name(BranchDto v) => v.name;
  static const Field<BranchDto, String> _f$name = Field('name', _$name);
  static String _$address(BranchDto v) => v.address;
  static const Field<BranchDto, String> _f$address = Field(
    'address',
    _$address,
  );
  static String _$contactNumber(BranchDto v) => v.contactNumber;
  static const Field<BranchDto, String> _f$contactNumber = Field(
    'contactNumber',
    _$contactNumber,
  );
  static String? _$operatingHours(BranchDto v) => v.operatingHours;
  static const Field<BranchDto, String> _f$operatingHours = Field(
    'operatingHours',
    _$operatingHours,
    opt: true,
  );
  static String? _$cutOffTime(BranchDto v) => v.cutOffTime;
  static const Field<BranchDto, String> _f$cutOffTime = Field(
    'cutOffTime',
    _$cutOffTime,
    opt: true,
  );
  static bool _$isDeleted(BranchDto v) => v.isDeleted;
  static const Field<BranchDto, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static String? _$created(BranchDto v) => v.created;
  static const Field<BranchDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(BranchDto v) => v.updated;
  static const Field<BranchDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<BranchDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #name: _f$name,
    #address: _f$address,
    #contactNumber: _f$contactNumber,
    #operatingHours: _f$operatingHours,
    #cutOffTime: _f$cutOffTime,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static BranchDto _instantiate(DecodingData data) {
    return BranchDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
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

  static BranchDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<BranchDto>(map);
  }

  static BranchDto fromJson(String json) {
    return ensureInitialized().decodeJson<BranchDto>(json);
  }
}

mixin BranchDtoMappable {
  String toJson() {
    return BranchDtoMapper.ensureInitialized().encodeJson<BranchDto>(
      this as BranchDto,
    );
  }

  Map<String, dynamic> toMap() {
    return BranchDtoMapper.ensureInitialized().encodeMap<BranchDto>(
      this as BranchDto,
    );
  }

  BranchDtoCopyWith<BranchDto, BranchDto, BranchDto> get copyWith =>
      _BranchDtoCopyWithImpl<BranchDto, BranchDto>(
        this as BranchDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return BranchDtoMapper.ensureInitialized().stringifyValue(
      this as BranchDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return BranchDtoMapper.ensureInitialized().equalsValue(
      this as BranchDto,
      other,
    );
  }

  @override
  int get hashCode {
    return BranchDtoMapper.ensureInitialized().hashValue(this as BranchDto);
  }
}

extension BranchDtoValueCopy<$R, $Out> on ObjectCopyWith<$R, BranchDto, $Out> {
  BranchDtoCopyWith<$R, BranchDto, $Out> get $asBranchDto =>
      $base.as((v, t, t2) => _BranchDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class BranchDtoCopyWith<$R, $In extends BranchDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    String? address,
    String? contactNumber,
    String? operatingHours,
    String? cutOffTime,
    bool? isDeleted,
    String? created,
    String? updated,
  });
  BranchDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _BranchDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, BranchDto, $Out>
    implements BranchDtoCopyWith<$R, BranchDto, $Out> {
  _BranchDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<BranchDto> $mapper =
      BranchDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
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
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
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
  BranchDto $make(CopyWithData data) => BranchDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
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
  BranchDtoCopyWith<$R2, BranchDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _BranchDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

