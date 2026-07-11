// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'user_role_dto.dart';

class UserRoleDtoMapper extends ClassMapperBase<UserRoleDto> {
  UserRoleDtoMapper._();

  static UserRoleDtoMapper? _instance;
  static UserRoleDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UserRoleDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'UserRoleDto';

  static String _$id(UserRoleDto v) => v.id;
  static const Field<UserRoleDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(UserRoleDto v) => v.collectionId;
  static const Field<UserRoleDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(UserRoleDto v) => v.collectionName;
  static const Field<UserRoleDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$name(UserRoleDto v) => v.name;
  static const Field<UserRoleDto, String> _f$name = Field('name', _$name);
  static String? _$description(UserRoleDto v) => v.description;
  static const Field<UserRoleDto, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );
  static List<String> _$permissions(UserRoleDto v) => v.permissions;
  static const Field<UserRoleDto, List<String>> _f$permissions = Field(
    'permissions',
    _$permissions,
    opt: true,
    def: const [],
  );
  static bool _$isSystem(UserRoleDto v) => v.isSystem;
  static const Field<UserRoleDto, bool> _f$isSystem = Field(
    'isSystem',
    _$isSystem,
    opt: true,
    def: false,
  );
  static bool _$isDeleted(UserRoleDto v) => v.isDeleted;
  static const Field<UserRoleDto, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static String? _$created(UserRoleDto v) => v.created;
  static const Field<UserRoleDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(UserRoleDto v) => v.updated;
  static const Field<UserRoleDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<UserRoleDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #name: _f$name,
    #description: _f$description,
    #permissions: _f$permissions,
    #isSystem: _f$isSystem,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static UserRoleDto _instantiate(DecodingData data) {
    return UserRoleDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
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

  static UserRoleDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<UserRoleDto>(map);
  }

  static UserRoleDto fromJson(String json) {
    return ensureInitialized().decodeJson<UserRoleDto>(json);
  }
}

mixin UserRoleDtoMappable {
  String toJson() {
    return UserRoleDtoMapper.ensureInitialized().encodeJson<UserRoleDto>(
      this as UserRoleDto,
    );
  }

  Map<String, dynamic> toMap() {
    return UserRoleDtoMapper.ensureInitialized().encodeMap<UserRoleDto>(
      this as UserRoleDto,
    );
  }

  UserRoleDtoCopyWith<UserRoleDto, UserRoleDto, UserRoleDto> get copyWith =>
      _UserRoleDtoCopyWithImpl<UserRoleDto, UserRoleDto>(
        this as UserRoleDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return UserRoleDtoMapper.ensureInitialized().stringifyValue(
      this as UserRoleDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return UserRoleDtoMapper.ensureInitialized().equalsValue(
      this as UserRoleDto,
      other,
    );
  }

  @override
  int get hashCode {
    return UserRoleDtoMapper.ensureInitialized().hashValue(this as UserRoleDto);
  }
}

extension UserRoleDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, UserRoleDto, $Out> {
  UserRoleDtoCopyWith<$R, UserRoleDto, $Out> get $asUserRoleDto =>
      $base.as((v, t, t2) => _UserRoleDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class UserRoleDtoCopyWith<$R, $In extends UserRoleDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get permissions;
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    String? description,
    List<String>? permissions,
    bool? isSystem,
    bool? isDeleted,
    String? created,
    String? updated,
  });
  UserRoleDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _UserRoleDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, UserRoleDto, $Out>
    implements UserRoleDtoCopyWith<$R, UserRoleDto, $Out> {
  _UserRoleDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<UserRoleDto> $mapper =
      UserRoleDtoMapper.ensureInitialized();
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
    String? collectionId,
    String? collectionName,
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
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
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
  UserRoleDto $make(CopyWithData data) => UserRoleDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    name: data.get(#name, or: $value.name),
    description: data.get(#description, or: $value.description),
    permissions: data.get(#permissions, or: $value.permissions),
    isSystem: data.get(#isSystem, or: $value.isSystem),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  UserRoleDtoCopyWith<$R2, UserRoleDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _UserRoleDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

