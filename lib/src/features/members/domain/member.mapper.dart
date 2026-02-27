// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'member.dart';

class MemberSexMapper extends EnumMapper<MemberSex> {
  MemberSexMapper._();

  static MemberSexMapper? _instance;
  static MemberSexMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MemberSexMapper._());
    }
    return _instance!;
  }

  static MemberSex fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  MemberSex decode(dynamic value) {
    switch (value) {
      case r'male':
        return MemberSex.male;
      case r'female':
        return MemberSex.female;
      case r'other':
        return MemberSex.other;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(MemberSex self) {
    switch (self) {
      case MemberSex.male:
        return r'male';
      case MemberSex.female:
        return r'female';
      case MemberSex.other:
        return r'other';
    }
  }
}

extension MemberSexMapperExtension on MemberSex {
  String toValue() {
    MemberSexMapper.ensureInitialized();
    return MapperContainer.globals.toValue<MemberSex>(this) as String;
  }
}

class MemberMapper extends ClassMapperBase<Member> {
  MemberMapper._();

  static MemberMapper? _instance;
  static MemberMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MemberMapper._());
      MemberSexMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Member';

  static String _$id(Member v) => v.id;
  static const Field<Member, String> _f$id = Field('id', _$id);
  static String _$name(Member v) => v.name;
  static const Field<Member, String> _f$name = Field('name', _$name);
  static String? _$photo(Member v) => v.photo;
  static const Field<Member, String> _f$photo = Field(
    'photo',
    _$photo,
    opt: true,
  );
  static String? _$mobileNumber(Member v) => v.mobileNumber;
  static const Field<Member, String> _f$mobileNumber = Field(
    'mobileNumber',
    _$mobileNumber,
    opt: true,
  );
  static DateTime? _$dateOfBirth(Member v) => v.dateOfBirth;
  static const Field<Member, DateTime> _f$dateOfBirth = Field(
    'dateOfBirth',
    _$dateOfBirth,
    opt: true,
  );
  static String? _$address(Member v) => v.address;
  static const Field<Member, String> _f$address = Field(
    'address',
    _$address,
    opt: true,
  );
  static MemberSex? _$sex(Member v) => v.sex;
  static const Field<Member, MemberSex> _f$sex = Field('sex', _$sex, opt: true);
  static String? _$remarks(Member v) => v.remarks;
  static const Field<Member, String> _f$remarks = Field(
    'remarks',
    _$remarks,
    opt: true,
  );
  static String? _$addedBy(Member v) => v.addedBy;
  static const Field<Member, String> _f$addedBy = Field(
    'addedBy',
    _$addedBy,
    opt: true,
  );
  static String? _$rfidCardId(Member v) => v.rfidCardId;
  static const Field<Member, String> _f$rfidCardId = Field(
    'rfidCardId',
    _$rfidCardId,
    opt: true,
  );
  static String? _$email(Member v) => v.email;
  static const Field<Member, String> _f$email = Field(
    'email',
    _$email,
    opt: true,
  );
  static String? _$emergencyContact(Member v) => v.emergencyContact;
  static const Field<Member, String> _f$emergencyContact = Field(
    'emergencyContact',
    _$emergencyContact,
    opt: true,
  );
  static DateTime? _$created(Member v) => v.created;
  static const Field<Member, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(Member v) => v.updated;
  static const Field<Member, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<Member> fields = const {
    #id: _f$id,
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

  static Member _instantiate(DecodingData data) {
    return Member(
      id: data.dec(_f$id),
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

  static Member fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Member>(map);
  }

  static Member fromJson(String json) {
    return ensureInitialized().decodeJson<Member>(json);
  }
}

mixin MemberMappable {
  String toJson() {
    return MemberMapper.ensureInitialized().encodeJson<Member>(this as Member);
  }

  Map<String, dynamic> toMap() {
    return MemberMapper.ensureInitialized().encodeMap<Member>(this as Member);
  }

  MemberCopyWith<Member, Member, Member> get copyWith =>
      _MemberCopyWithImpl<Member, Member>(this as Member, $identity, $identity);
  @override
  String toString() {
    return MemberMapper.ensureInitialized().stringifyValue(this as Member);
  }

  @override
  bool operator ==(Object other) {
    return MemberMapper.ensureInitialized().equalsValue(this as Member, other);
  }

  @override
  int get hashCode {
    return MemberMapper.ensureInitialized().hashValue(this as Member);
  }
}

extension MemberValueCopy<$R, $Out> on ObjectCopyWith<$R, Member, $Out> {
  MemberCopyWith<$R, Member, $Out> get $asMember =>
      $base.as((v, t, t2) => _MemberCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MemberCopyWith<$R, $In extends Member, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    String? photo,
    String? mobileNumber,
    DateTime? dateOfBirth,
    String? address,
    MemberSex? sex,
    String? remarks,
    String? addedBy,
    String? rfidCardId,
    String? email,
    String? emergencyContact,
    DateTime? created,
    DateTime? updated,
  });
  MemberCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MemberCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Member, $Out>
    implements MemberCopyWith<$R, Member, $Out> {
  _MemberCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Member> $mapper = MemberMapper.ensureInitialized();
  @override
  $R call({
    String? id,
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
  Member $make(CopyWithData data) => Member(
    id: data.get(#id, or: $value.id),
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
  MemberCopyWith<$R2, Member, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _MemberCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

