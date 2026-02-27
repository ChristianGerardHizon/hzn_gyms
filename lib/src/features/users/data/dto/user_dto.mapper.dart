// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'user_dto.dart';

class UserDtoMapper extends ClassMapperBase<UserDto> {
  UserDtoMapper._();

  static UserDtoMapper? _instance;
  static UserDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UserDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'UserDto';

  static String _$id(UserDto v) => v.id;
  static const Field<UserDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(UserDto v) => v.collectionId;
  static const Field<UserDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(UserDto v) => v.collectionName;
  static const Field<UserDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$name(UserDto v) => v.name;
  static const Field<UserDto, String> _f$name = Field('name', _$name);
  static String _$username(UserDto v) => v.username;
  static const Field<UserDto, String> _f$username = Field(
    'username',
    _$username,
  );
  static String _$email(UserDto v) => v.email;
  static const Field<UserDto, String> _f$email = Field('email', _$email);
  static String? _$avatar(UserDto v) => v.avatar;
  static const Field<UserDto, String> _f$avatar = Field(
    'avatar',
    _$avatar,
    opt: true,
  );
  static bool _$verified(UserDto v) => v.verified;
  static const Field<UserDto, bool> _f$verified = Field(
    'verified',
    _$verified,
    opt: true,
    def: false,
  );
  static String? _$role(UserDto v) => v.role;
  static const Field<UserDto, String> _f$role = Field(
    'role',
    _$role,
    opt: true,
  );
  static String? _$branch(UserDto v) => v.branch;
  static const Field<UserDto, String> _f$branch = Field(
    'branch',
    _$branch,
    opt: true,
  );
  static bool _$isDeleted(UserDto v) => v.isDeleted;
  static const Field<UserDto, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static String? _$created(UserDto v) => v.created;
  static const Field<UserDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(UserDto v) => v.updated;
  static const Field<UserDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );
  static String? _$roleName(UserDto v) => v.roleName;
  static const Field<UserDto, String> _f$roleName = Field(
    'roleName',
    _$roleName,
    opt: true,
  );
  static String? _$branchName(UserDto v) => v.branchName;
  static const Field<UserDto, String> _f$branchName = Field(
    'branchName',
    _$branchName,
    opt: true,
  );

  @override
  final MappableFields<UserDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #name: _f$name,
    #username: _f$username,
    #email: _f$email,
    #avatar: _f$avatar,
    #verified: _f$verified,
    #role: _f$role,
    #branch: _f$branch,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
    #roleName: _f$roleName,
    #branchName: _f$branchName,
  };

  static UserDto _instantiate(DecodingData data) {
    return UserDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      name: data.dec(_f$name),
      username: data.dec(_f$username),
      email: data.dec(_f$email),
      avatar: data.dec(_f$avatar),
      verified: data.dec(_f$verified),
      role: data.dec(_f$role),
      branch: data.dec(_f$branch),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
      roleName: data.dec(_f$roleName),
      branchName: data.dec(_f$branchName),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static UserDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<UserDto>(map);
  }

  static UserDto fromJson(String json) {
    return ensureInitialized().decodeJson<UserDto>(json);
  }
}

mixin UserDtoMappable {
  String toJson() {
    return UserDtoMapper.ensureInitialized().encodeJson<UserDto>(
      this as UserDto,
    );
  }

  Map<String, dynamic> toMap() {
    return UserDtoMapper.ensureInitialized().encodeMap<UserDto>(
      this as UserDto,
    );
  }

  UserDtoCopyWith<UserDto, UserDto, UserDto> get copyWith =>
      _UserDtoCopyWithImpl<UserDto, UserDto>(
        this as UserDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return UserDtoMapper.ensureInitialized().stringifyValue(this as UserDto);
  }

  @override
  bool operator ==(Object other) {
    return UserDtoMapper.ensureInitialized().equalsValue(
      this as UserDto,
      other,
    );
  }

  @override
  int get hashCode {
    return UserDtoMapper.ensureInitialized().hashValue(this as UserDto);
  }
}

extension UserDtoValueCopy<$R, $Out> on ObjectCopyWith<$R, UserDto, $Out> {
  UserDtoCopyWith<$R, UserDto, $Out> get $asUserDto =>
      $base.as((v, t, t2) => _UserDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class UserDtoCopyWith<$R, $In extends UserDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    String? username,
    String? email,
    String? avatar,
    bool? verified,
    String? role,
    String? branch,
    bool? isDeleted,
    String? created,
    String? updated,
    String? roleName,
    String? branchName,
  });
  UserDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _UserDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, UserDto, $Out>
    implements UserDtoCopyWith<$R, UserDto, $Out> {
  _UserDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<UserDto> $mapper =
      UserDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    String? username,
    String? email,
    Object? avatar = $none,
    bool? verified,
    Object? role = $none,
    Object? branch = $none,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
    Object? roleName = $none,
    Object? branchName = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (name != null) #name: name,
      if (username != null) #username: username,
      if (email != null) #email: email,
      if (avatar != $none) #avatar: avatar,
      if (verified != null) #verified: verified,
      if (role != $none) #role: role,
      if (branch != $none) #branch: branch,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
      if (roleName != $none) #roleName: roleName,
      if (branchName != $none) #branchName: branchName,
    }),
  );
  @override
  UserDto $make(CopyWithData data) => UserDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    name: data.get(#name, or: $value.name),
    username: data.get(#username, or: $value.username),
    email: data.get(#email, or: $value.email),
    avatar: data.get(#avatar, or: $value.avatar),
    verified: data.get(#verified, or: $value.verified),
    role: data.get(#role, or: $value.role),
    branch: data.get(#branch, or: $value.branch),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
    roleName: data.get(#roleName, or: $value.roleName),
    branchName: data.get(#branchName, or: $value.branchName),
  );

  @override
  UserDtoCopyWith<$R2, UserDto, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _UserDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

