// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'permission.dart';

class PermissionMapper extends ClassMapperBase<Permission> {
  PermissionMapper._();

  static PermissionMapper? _instance;
  static PermissionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PermissionMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Permission';

  static String _$key(Permission v) => v.key;
  static const Field<Permission, String> _f$key = Field('key', _$key);
  static String _$name(Permission v) => v.name;
  static const Field<Permission, String> _f$name = Field('name', _$name);
  static String _$category(Permission v) => v.category;
  static const Field<Permission, String> _f$category = Field(
    'category',
    _$category,
  );
  static String? _$description(Permission v) => v.description;
  static const Field<Permission, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );
  static IconData? _$icon(Permission v) => v.icon;
  static const Field<Permission, IconData> _f$icon = Field(
    'icon',
    _$icon,
    opt: true,
    hook: IconDataHook(),
  );

  @override
  final MappableFields<Permission> fields = const {
    #key: _f$key,
    #name: _f$name,
    #category: _f$category,
    #description: _f$description,
    #icon: _f$icon,
  };

  static Permission _instantiate(DecodingData data) {
    return Permission(
      key: data.dec(_f$key),
      name: data.dec(_f$name),
      category: data.dec(_f$category),
      description: data.dec(_f$description),
      icon: data.dec(_f$icon),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Permission fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Permission>(map);
  }

  static Permission fromJson(String json) {
    return ensureInitialized().decodeJson<Permission>(json);
  }
}

mixin PermissionMappable {
  String toJson() {
    return PermissionMapper.ensureInitialized().encodeJson<Permission>(
      this as Permission,
    );
  }

  Map<String, dynamic> toMap() {
    return PermissionMapper.ensureInitialized().encodeMap<Permission>(
      this as Permission,
    );
  }

  PermissionCopyWith<Permission, Permission, Permission> get copyWith =>
      _PermissionCopyWithImpl<Permission, Permission>(
        this as Permission,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PermissionMapper.ensureInitialized().stringifyValue(
      this as Permission,
    );
  }

  @override
  bool operator ==(Object other) {
    return PermissionMapper.ensureInitialized().equalsValue(
      this as Permission,
      other,
    );
  }

  @override
  int get hashCode {
    return PermissionMapper.ensureInitialized().hashValue(this as Permission);
  }
}

extension PermissionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, Permission, $Out> {
  PermissionCopyWith<$R, Permission, $Out> get $asPermission =>
      $base.as((v, t, t2) => _PermissionCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PermissionCopyWith<$R, $In extends Permission, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? key,
    String? name,
    String? category,
    String? description,
    IconData? icon,
  });
  PermissionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PermissionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Permission, $Out>
    implements PermissionCopyWith<$R, Permission, $Out> {
  _PermissionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Permission> $mapper =
      PermissionMapper.ensureInitialized();
  @override
  $R call({
    String? key,
    String? name,
    String? category,
    Object? description = $none,
    Object? icon = $none,
  }) => $apply(
    FieldCopyWithData({
      if (key != null) #key: key,
      if (name != null) #name: name,
      if (category != null) #category: category,
      if (description != $none) #description: description,
      if (icon != $none) #icon: icon,
    }),
  );
  @override
  Permission $make(CopyWithData data) => Permission(
    key: data.get(#key, or: $value.key),
    name: data.get(#name, or: $value.name),
    category: data.get(#category, or: $value.category),
    description: data.get(#description, or: $value.description),
    icon: data.get(#icon, or: $value.icon),
  );

  @override
  PermissionCopyWith<$R2, Permission, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PermissionCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

