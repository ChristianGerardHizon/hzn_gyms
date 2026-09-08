// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'auth_dto.dart';

class AuthDtoMapper extends ClassMapperBase<AuthDto> {
  AuthDtoMapper._();

  static AuthDtoMapper? _instance;
  static AuthDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AuthDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'AuthDto';

  static String _$token(AuthDto v) => v.token;
  static const Field<AuthDto, String> _f$token = Field('token', _$token);
  static String _$id(AuthDto v) => v.id;
  static const Field<AuthDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(AuthDto v) => v.collectionId;
  static const Field<AuthDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(AuthDto v) => v.collectionName;
  static const Field<AuthDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$name(AuthDto v) => v.name;
  static const Field<AuthDto, String> _f$name = Field('name', _$name);
  static String _$email(AuthDto v) => v.email;
  static const Field<AuthDto, String> _f$email = Field('email', _$email);
  static String _$avatar(AuthDto v) => v.avatar;
  static const Field<AuthDto, String> _f$avatar = Field(
    'avatar',
    _$avatar,
    opt: true,
    def: '',
  );
  static bool _$verified(AuthDto v) => v.verified;
  static const Field<AuthDto, bool> _f$verified = Field(
    'verified',
    _$verified,
    opt: true,
    def: false,
  );
  static String? _$role(AuthDto v) => v.role;
  static const Field<AuthDto, String> _f$role = Field(
    'role',
    _$role,
    opt: true,
  );
  static String? _$branch(AuthDto v) => v.branch;
  static const Field<AuthDto, String> _f$branch = Field(
    'branch',
    _$branch,
    opt: true,
  );
  static List<String> _$allowedBranches(AuthDto v) => v.allowedBranches;
  static const Field<AuthDto, List<String>> _f$allowedBranches = Field(
    'allowedBranches',
    _$allowedBranches,
    opt: true,
    def: const [],
  );
  static String? _$organization(AuthDto v) => v.organization;
  static const Field<AuthDto, String> _f$organization = Field(
    'organization',
    _$organization,
    opt: true,
  );
  static bool _$superAdmin(AuthDto v) => v.superAdmin;
  static const Field<AuthDto, bool> _f$superAdmin = Field(
    'superAdmin',
    _$superAdmin,
    opt: true,
    def: false,
  );

  @override
  final MappableFields<AuthDto> fields = const {
    #token: _f$token,
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #name: _f$name,
    #email: _f$email,
    #avatar: _f$avatar,
    #verified: _f$verified,
    #role: _f$role,
    #branch: _f$branch,
    #allowedBranches: _f$allowedBranches,
    #organization: _f$organization,
    #superAdmin: _f$superAdmin,
  };

  static AuthDto _instantiate(DecodingData data) {
    return AuthDto(
      token: data.dec(_f$token),
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      name: data.dec(_f$name),
      email: data.dec(_f$email),
      avatar: data.dec(_f$avatar),
      verified: data.dec(_f$verified),
      role: data.dec(_f$role),
      branch: data.dec(_f$branch),
      allowedBranches: data.dec(_f$allowedBranches),
      organization: data.dec(_f$organization),
      superAdmin: data.dec(_f$superAdmin),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static AuthDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AuthDto>(map);
  }

  static AuthDto fromJson(String json) {
    return ensureInitialized().decodeJson<AuthDto>(json);
  }
}

mixin AuthDtoMappable {
  String toJson() {
    return AuthDtoMapper.ensureInitialized().encodeJson<AuthDto>(
      this as AuthDto,
    );
  }

  Map<String, dynamic> toMap() {
    return AuthDtoMapper.ensureInitialized().encodeMap<AuthDto>(
      this as AuthDto,
    );
  }

  AuthDtoCopyWith<AuthDto, AuthDto, AuthDto> get copyWith =>
      _AuthDtoCopyWithImpl<AuthDto, AuthDto>(
        this as AuthDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AuthDtoMapper.ensureInitialized().stringifyValue(this as AuthDto);
  }

  @override
  bool operator ==(Object other) {
    return AuthDtoMapper.ensureInitialized().equalsValue(
      this as AuthDto,
      other,
    );
  }

  @override
  int get hashCode {
    return AuthDtoMapper.ensureInitialized().hashValue(this as AuthDto);
  }
}

extension AuthDtoValueCopy<$R, $Out> on ObjectCopyWith<$R, AuthDto, $Out> {
  AuthDtoCopyWith<$R, AuthDto, $Out> get $asAuthDto =>
      $base.as((v, t, t2) => _AuthDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AuthDtoCopyWith<$R, $In extends AuthDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get allowedBranches;
  $R call({
    String? token,
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    String? email,
    String? avatar,
    bool? verified,
    String? role,
    String? branch,
    List<String>? allowedBranches,
    String? organization,
    bool? superAdmin,
  });
  AuthDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AuthDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AuthDto, $Out>
    implements AuthDtoCopyWith<$R, AuthDto, $Out> {
  _AuthDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AuthDto> $mapper =
      AuthDtoMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get allowedBranches => ListCopyWith(
    $value.allowedBranches,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(allowedBranches: v),
  );
  @override
  $R call({
    String? token,
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    String? email,
    String? avatar,
    bool? verified,
    Object? role = $none,
    Object? branch = $none,
    List<String>? allowedBranches,
    Object? organization = $none,
    bool? superAdmin,
  }) => $apply(
    FieldCopyWithData({
      if (token != null) #token: token,
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (name != null) #name: name,
      if (email != null) #email: email,
      if (avatar != null) #avatar: avatar,
      if (verified != null) #verified: verified,
      if (role != $none) #role: role,
      if (branch != $none) #branch: branch,
      if (allowedBranches != null) #allowedBranches: allowedBranches,
      if (organization != $none) #organization: organization,
      if (superAdmin != null) #superAdmin: superAdmin,
    }),
  );
  @override
  AuthDto $make(CopyWithData data) => AuthDto(
    token: data.get(#token, or: $value.token),
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    name: data.get(#name, or: $value.name),
    email: data.get(#email, or: $value.email),
    avatar: data.get(#avatar, or: $value.avatar),
    verified: data.get(#verified, or: $value.verified),
    role: data.get(#role, or: $value.role),
    branch: data.get(#branch, or: $value.branch),
    allowedBranches: data.get(#allowedBranches, or: $value.allowedBranches),
    organization: data.get(#organization, or: $value.organization),
    superAdmin: data.get(#superAdmin, or: $value.superAdmin),
  );

  @override
  AuthDtoCopyWith<$R2, AuthDto, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _AuthDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

