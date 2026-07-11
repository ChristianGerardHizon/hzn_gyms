// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'user_role.dart';

class UserRoleMapper extends ClassMapperBase<UserRole> {
  UserRoleMapper._();

  static UserRoleMapper? _instance;
  static UserRoleMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UserRoleMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'UserRole';

  static String _$id(UserRole v) => v.id;
  static const Field<UserRole, String> _f$id = Field('id', _$id);
  static String _$name(UserRole v) => v.name;
  static const Field<UserRole, String> _f$name = Field('name', _$name);
  static String? _$description(UserRole v) => v.description;
  static const Field<UserRole, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );
  static List<String> _$permissions(UserRole v) => v.permissions;
  static const Field<UserRole, List<String>> _f$permissions = Field(
    'permissions',
    _$permissions,
    opt: true,
    def: const [],
  );
  static bool _$isSystem(UserRole v) => v.isSystem;
  static const Field<UserRole, bool> _f$isSystem = Field(
    'isSystem',
    _$isSystem,
    opt: true,
    def: false,
  );
  static bool _$isDeleted(UserRole v) => v.isDeleted;
  static const Field<UserRole, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static DateTime? _$created(UserRole v) => v.created;
  static const Field<UserRole, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(UserRole v) => v.updated;
  static const Field<UserRole, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<UserRole> fields = const {
    #id: _f$id,
    #name: _f$name,
    #description: _f$description,
    #permissions: _f$permissions,
    #isSystem: _f$isSystem,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static UserRole _instantiate(DecodingData data) {
    return UserRole(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      description: data.dec(_f$description),
      permissions: data.dec(_f$permissions),
      isSystem: data.dec(_f$isSystem),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static UserRole fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<UserRole>(map);
  }

  static UserRole fromJson(String json) {
    return ensureInitialized().decodeJson<UserRole>(json);
  }
}

mixin UserRoleMappable {
  String toJson() {
    return UserRoleMapper.ensureInitialized().encodeJson<UserRole>(
      this as UserRole,
    );
  }

  Map<String, dynamic> toMap() {
    return UserRoleMapper.ensureInitialized().encodeMap<UserRole>(
      this as UserRole,
    );
  }

  UserRoleCopyWith<UserRole, UserRole, UserRole> get copyWith =>
      _UserRoleCopyWithImpl<UserRole, UserRole>(
        this as UserRole,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return UserRoleMapper.ensureInitialized().stringifyValue(this as UserRole);
  }

  @override
  bool operator ==(Object other) {
    return UserRoleMapper.ensureInitialized().equalsValue(
      this as UserRole,
      other,
    );
  }

  @override
  int get hashCode {
    return UserRoleMapper.ensureInitialized().hashValue(this as UserRole);
  }
}

extension UserRoleValueCopy<$R, $Out> on ObjectCopyWith<$R, UserRole, $Out> {
  UserRoleCopyWith<$R, UserRole, $Out> get $asUserRole =>
      $base.as((v, t, t2) => _UserRoleCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class UserRoleCopyWith<$R, $In extends UserRole, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get permissions;
  $R call({
    String? id,
    String? name,
    String? description,
    List<String>? permissions,
    bool? isSystem,
    bool? isDeleted,
    DateTime? created,
    DateTime? updated,
  });
  UserRoleCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _UserRoleCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, UserRole, $Out>
    implements UserRoleCopyWith<$R, UserRole, $Out> {
  _UserRoleCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<UserRole> $mapper =
      UserRoleMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get permissions => ListCopyWith(
    $value.permissions,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(permissions: v),
  );
  @override
  $R call({
    String? id,
    String? name,
    Object? description = $none,
    List<String>? permissions,
    bool? isSystem,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (description != $none) #description: description,
      if (permissions != null) #permissions: permissions,
      if (isSystem != null) #isSystem: isSystem,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  UserRole $make(CopyWithData data) => UserRole(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    description: data.get(#description, or: $value.description),
    permissions: data.get(#permissions, or: $value.permissions),
    isSystem: data.get(#isSystem, or: $value.isSystem),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  UserRoleCopyWith<$R2, UserRole, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _UserRoleCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

