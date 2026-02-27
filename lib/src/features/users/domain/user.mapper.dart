// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'user.dart';

class UserMapper extends ClassMapperBase<User> {
  UserMapper._();

  static UserMapper? _instance;
  static UserMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UserMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'User';

  static String _$id(User v) => v.id;
  static const Field<User, String> _f$id = Field('id', _$id);
  static String _$name(User v) => v.name;
  static const Field<User, String> _f$name = Field('name', _$name);
  static String _$username(User v) => v.username;
  static const Field<User, String> _f$username = Field('username', _$username);
  static String? _$avatar(User v) => v.avatar;
  static const Field<User, String> _f$avatar = Field(
    'avatar',
    _$avatar,
    opt: true,
  );
  static bool _$verified(User v) => v.verified;
  static const Field<User, bool> _f$verified = Field(
    'verified',
    _$verified,
    opt: true,
    def: false,
  );
  static String? _$roleId(User v) => v.roleId;
  static const Field<User, String> _f$roleId = Field(
    'roleId',
    _$roleId,
    opt: true,
  );
  static String? _$roleName(User v) => v.roleName;
  static const Field<User, String> _f$roleName = Field(
    'roleName',
    _$roleName,
    opt: true,
  );
  static String? _$branchId(User v) => v.branchId;
  static const Field<User, String> _f$branchId = Field(
    'branchId',
    _$branchId,
    opt: true,
  );
  static String? _$branchName(User v) => v.branchName;
  static const Field<User, String> _f$branchName = Field(
    'branchName',
    _$branchName,
    opt: true,
  );
  static bool _$isDeleted(User v) => v.isDeleted;
  static const Field<User, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static DateTime? _$created(User v) => v.created;
  static const Field<User, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(User v) => v.updated;
  static const Field<User, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<User> fields = const {
    #id: _f$id,
    #name: _f$name,
    #username: _f$username,
    #avatar: _f$avatar,
    #verified: _f$verified,
    #roleId: _f$roleId,
    #roleName: _f$roleName,
    #branchId: _f$branchId,
    #branchName: _f$branchName,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static User _instantiate(DecodingData data) {
    return User(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      username: data.dec(_f$username),
      avatar: data.dec(_f$avatar),
      verified: data.dec(_f$verified),
      roleId: data.dec(_f$roleId),
      roleName: data.dec(_f$roleName),
      branchId: data.dec(_f$branchId),
      branchName: data.dec(_f$branchName),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static User fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<User>(map);
  }

  static User fromJson(String json) {
    return ensureInitialized().decodeJson<User>(json);
  }
}

mixin UserMappable {
  String toJson() {
    return UserMapper.ensureInitialized().encodeJson<User>(this as User);
  }

  Map<String, dynamic> toMap() {
    return UserMapper.ensureInitialized().encodeMap<User>(this as User);
  }

  UserCopyWith<User, User, User> get copyWith =>
      _UserCopyWithImpl<User, User>(this as User, $identity, $identity);
  @override
  String toString() {
    return UserMapper.ensureInitialized().stringifyValue(this as User);
  }

  @override
  bool operator ==(Object other) {
    return UserMapper.ensureInitialized().equalsValue(this as User, other);
  }

  @override
  int get hashCode {
    return UserMapper.ensureInitialized().hashValue(this as User);
  }
}

extension UserValueCopy<$R, $Out> on ObjectCopyWith<$R, User, $Out> {
  UserCopyWith<$R, User, $Out> get $asUser =>
      $base.as((v, t, t2) => _UserCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class UserCopyWith<$R, $In extends User, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    String? username,
    String? avatar,
    bool? verified,
    String? roleId,
    String? roleName,
    String? branchId,
    String? branchName,
    bool? isDeleted,
    DateTime? created,
    DateTime? updated,
  });
  UserCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _UserCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, User, $Out>
    implements UserCopyWith<$R, User, $Out> {
  _UserCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<User> $mapper = UserMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? name,
    String? username,
    Object? avatar = $none,
    bool? verified,
    Object? roleId = $none,
    Object? roleName = $none,
    Object? branchId = $none,
    Object? branchName = $none,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (username != null) #username: username,
      if (avatar != $none) #avatar: avatar,
      if (verified != null) #verified: verified,
      if (roleId != $none) #roleId: roleId,
      if (roleName != $none) #roleName: roleName,
      if (branchId != $none) #branchId: branchId,
      if (branchName != $none) #branchName: branchName,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  User $make(CopyWithData data) => User(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    username: data.get(#username, or: $value.username),
    avatar: data.get(#avatar, or: $value.avatar),
    verified: data.get(#verified, or: $value.verified),
    roleId: data.get(#roleId, or: $value.roleId),
    roleName: data.get(#roleName, or: $value.roleName),
    branchId: data.get(#branchId, or: $value.branchId),
    branchName: data.get(#branchName, or: $value.branchName),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  UserCopyWith<$R2, User, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _UserCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

