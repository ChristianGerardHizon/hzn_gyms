// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'member_dto.dart';

class MemberDtoMapper extends ClassMapperBase<MemberDto> {
  MemberDtoMapper._();

  static MemberDtoMapper? _instance;
  static MemberDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MemberDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'MemberDto';

  static String _$id(MemberDto v) => v.id;
  static const Field<MemberDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(MemberDto v) => v.collectionId;
  static const Field<MemberDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(MemberDto v) => v.collectionName;
  static const Field<MemberDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$name(MemberDto v) => v.name;
  static const Field<MemberDto, String> _f$name = Field('name', _$name);
  static String? _$photo(MemberDto v) => v.photo;
  static const Field<MemberDto, String> _f$photo = Field(
    'photo',
    _$photo,
    opt: true,
  );
  static String? _$mobileNumber(MemberDto v) => v.mobileNumber;
  static const Field<MemberDto, String> _f$mobileNumber = Field(
    'mobileNumber',
    _$mobileNumber,
    opt: true,
  );
  static String? _$dateOfBirth(MemberDto v) => v.dateOfBirth;
  static const Field<MemberDto, String> _f$dateOfBirth = Field(
    'dateOfBirth',
    _$dateOfBirth,
    opt: true,
  );
  static String? _$address(MemberDto v) => v.address;
  static const Field<MemberDto, String> _f$address = Field(
    'address',
    _$address,
    opt: true,
  );
  static String? _$sex(MemberDto v) => v.sex;
  static const Field<MemberDto, String> _f$sex = Field('sex', _$sex, opt: true);
  static String? _$remarks(MemberDto v) => v.remarks;
  static const Field<MemberDto, String> _f$remarks = Field(
    'remarks',
    _$remarks,
    opt: true,
  );
  static String? _$addedBy(MemberDto v) => v.addedBy;
  static const Field<MemberDto, String> _f$addedBy = Field(
    'addedBy',
    _$addedBy,
    opt: true,
  );
  static String? _$rfidCardId(MemberDto v) => v.rfidCardId;
  static const Field<MemberDto, String> _f$rfidCardId = Field(
    'rfidCardId',
    _$rfidCardId,
    opt: true,
  );
  static String? _$email(MemberDto v) => v.email;
  static const Field<MemberDto, String> _f$email = Field(
    'email',
    _$email,
    opt: true,
  );
  static String? _$emergencyContact(MemberDto v) => v.emergencyContact;
  static const Field<MemberDto, String> _f$emergencyContact = Field(
    'emergencyContact',
    _$emergencyContact,
    opt: true,
  );
  static String? _$created(MemberDto v) => v.created;
  static const Field<MemberDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(MemberDto v) => v.updated;
  static const Field<MemberDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<MemberDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #name: _f$name,
    #photo: _f$photo,
    #mobileNumber: _f$mobileNumber,
    #dateOfBirth: _f$dateOfBirth,
    #address: _f$address,
    #sex: _f$sex,
    #remarks: _f$remarks,
    #addedBy: _f$addedBy,
    #rfidCardId: _f$rfidCardId,
    #email: _f$email,
    #emergencyContact: _f$emergencyContact,
    #created: _f$created,
    #updated: _f$updated,
  };

  static MemberDto _instantiate(DecodingData data) {
    return MemberDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      name: data.dec(_f$name),
      photo: data.dec(_f$photo),
      mobileNumber: data.dec(_f$mobileNumber),
      dateOfBirth: data.dec(_f$dateOfBirth),
      address: data.dec(_f$address),
      sex: data.dec(_f$sex),
      remarks: data.dec(_f$remarks),
      addedBy: data.dec(_f$addedBy),
      rfidCardId: data.dec(_f$rfidCardId),
      email: data.dec(_f$email),
      emergencyContact: data.dec(_f$emergencyContact),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MemberDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MemberDto>(map);
  }

  static MemberDto fromJson(String json) {
    return ensureInitialized().decodeJson<MemberDto>(json);
  }
}

mixin MemberDtoMappable {
  String toJson() {
    return MemberDtoMapper.ensureInitialized().encodeJson<MemberDto>(
      this as MemberDto,
    );
  }

  Map<String, dynamic> toMap() {
    return MemberDtoMapper.ensureInitialized().encodeMap<MemberDto>(
      this as MemberDto,
    );
  }

  MemberDtoCopyWith<MemberDto, MemberDto, MemberDto> get copyWith =>
      _MemberDtoCopyWithImpl<MemberDto, MemberDto>(
        this as MemberDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return MemberDtoMapper.ensureInitialized().stringifyValue(
      this as MemberDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return MemberDtoMapper.ensureInitialized().equalsValue(
      this as MemberDto,
      other,
    );
  }

  @override
  int get hashCode {
    return MemberDtoMapper.ensureInitialized().hashValue(this as MemberDto);
  }
}

extension MemberDtoValueCopy<$R, $Out> on ObjectCopyWith<$R, MemberDto, $Out> {
  MemberDtoCopyWith<$R, MemberDto, $Out> get $asMemberDto =>
      $base.as((v, t, t2) => _MemberDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MemberDtoCopyWith<$R, $In extends MemberDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    String? photo,
    String? mobileNumber,
    String? dateOfBirth,
    String? address,
    String? sex,
    String? remarks,
    String? addedBy,
    String? rfidCardId,
    String? email,
    String? emergencyContact,
    String? created,
    String? updated,
  });
  MemberDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MemberDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MemberDto, $Out>
    implements MemberDtoCopyWith<$R, MemberDto, $Out> {
  _MemberDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MemberDto> $mapper =
      MemberDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    Object? photo = $none,
    Object? mobileNumber = $none,
    Object? dateOfBirth = $none,
    Object? address = $none,
    Object? sex = $none,
    Object? remarks = $none,
    Object? addedBy = $none,
    Object? rfidCardId = $none,
    Object? email = $none,
    Object? emergencyContact = $none,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (name != null) #name: name,
      if (photo != $none) #photo: photo,
      if (mobileNumber != $none) #mobileNumber: mobileNumber,
      if (dateOfBirth != $none) #dateOfBirth: dateOfBirth,
      if (address != $none) #address: address,
      if (sex != $none) #sex: sex,
      if (remarks != $none) #remarks: remarks,
      if (addedBy != $none) #addedBy: addedBy,
      if (rfidCardId != $none) #rfidCardId: rfidCardId,
      if (email != $none) #email: email,
      if (emergencyContact != $none) #emergencyContact: emergencyContact,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  MemberDto $make(CopyWithData data) => MemberDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    name: data.get(#name, or: $value.name),
    photo: data.get(#photo, or: $value.photo),
    mobileNumber: data.get(#mobileNumber, or: $value.mobileNumber),
    dateOfBirth: data.get(#dateOfBirth, or: $value.dateOfBirth),
    address: data.get(#address, or: $value.address),
    sex: data.get(#sex, or: $value.sex),
    remarks: data.get(#remarks, or: $value.remarks),
    addedBy: data.get(#addedBy, or: $value.addedBy),
    rfidCardId: data.get(#rfidCardId, or: $value.rfidCardId),
    email: data.get(#email, or: $value.email),
    emergencyContact: data.get(#emergencyContact, or: $value.emergencyContact),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  MemberDtoCopyWith<$R2, MemberDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MemberDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

