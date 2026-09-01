// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'organization_dto.dart';

class OrganizationDtoMapper extends ClassMapperBase<OrganizationDto> {
  OrganizationDtoMapper._();

  static OrganizationDtoMapper? _instance;
  static OrganizationDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrganizationDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'OrganizationDto';

  static String _$id(OrganizationDto v) => v.id;
  static const Field<OrganizationDto, String> _f$id = Field('id', _$id);
  static String _$collectionId(OrganizationDto v) => v.collectionId;
  static const Field<OrganizationDto, String> _f$collectionId = Field(
    'collectionId',
    _$collectionId,
  );
  static String _$collectionName(OrganizationDto v) => v.collectionName;
  static const Field<OrganizationDto, String> _f$collectionName = Field(
    'collectionName',
    _$collectionName,
  );
  static String _$name(OrganizationDto v) => v.name;
  static const Field<OrganizationDto, String> _f$name = Field('name', _$name);
  static String _$slug(OrganizationDto v) => v.slug;
  static const Field<OrganizationDto, String> _f$slug = Field('slug', _$slug);
  static String? _$displayName(OrganizationDto v) => v.displayName;
  static const Field<OrganizationDto, String> _f$displayName = Field(
    'displayName',
    _$displayName,
    opt: true,
  );
  static String? _$seedColor(OrganizationDto v) => v.seedColor;
  static const Field<OrganizationDto, String> _f$seedColor = Field(
    'seedColor',
    _$seedColor,
    opt: true,
  );
  static String _$logoLight(OrganizationDto v) => v.logoLight;
  static const Field<OrganizationDto, String> _f$logoLight = Field(
    'logoLight',
    _$logoLight,
    opt: true,
    def: '',
  );
  static String _$logoTransparent(OrganizationDto v) => v.logoTransparent;
  static const Field<OrganizationDto, String> _f$logoTransparent = Field(
    'logoTransparent',
    _$logoTransparent,
    opt: true,
    def: '',
  );
  static String? _$splashBackgroundColor(OrganizationDto v) =>
      v.splashBackgroundColor;
  static const Field<OrganizationDto, String> _f$splashBackgroundColor = Field(
    'splashBackgroundColor',
    _$splashBackgroundColor,
    opt: true,
  );
  static String? _$subdomain(OrganizationDto v) => v.subdomain;
  static const Field<OrganizationDto, String> _f$subdomain = Field(
    'subdomain',
    _$subdomain,
    opt: true,
  );
  static String? _$dnsStatus(OrganizationDto v) => v.dnsStatus;
  static const Field<OrganizationDto, String> _f$dnsStatus = Field(
    'dnsStatus',
    _$dnsStatus,
    opt: true,
  );
  static String? _$dnsError(OrganizationDto v) => v.dnsError;
  static const Field<OrganizationDto, String> _f$dnsError = Field(
    'dnsError',
    _$dnsError,
    opt: true,
  );
  static String? _$dnsLastAttempt(OrganizationDto v) => v.dnsLastAttempt;
  static const Field<OrganizationDto, String> _f$dnsLastAttempt = Field(
    'dnsLastAttempt',
    _$dnsLastAttempt,
    opt: true,
  );
  static bool _$isDeleted(OrganizationDto v) => v.isDeleted;
  static const Field<OrganizationDto, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static String? _$created(OrganizationDto v) => v.created;
  static const Field<OrganizationDto, String> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static String? _$updated(OrganizationDto v) => v.updated;
  static const Field<OrganizationDto, String> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<OrganizationDto> fields = const {
    #id: _f$id,
    #collectionId: _f$collectionId,
    #collectionName: _f$collectionName,
    #name: _f$name,
    #slug: _f$slug,
    #displayName: _f$displayName,
    #seedColor: _f$seedColor,
    #logoLight: _f$logoLight,
    #logoTransparent: _f$logoTransparent,
    #splashBackgroundColor: _f$splashBackgroundColor,
    #subdomain: _f$subdomain,
    #dnsStatus: _f$dnsStatus,
    #dnsError: _f$dnsError,
    #dnsLastAttempt: _f$dnsLastAttempt,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static OrganizationDto _instantiate(DecodingData data) {
    return OrganizationDto(
      id: data.dec(_f$id),
      collectionId: data.dec(_f$collectionId),
      collectionName: data.dec(_f$collectionName),
      name: data.dec(_f$name),
      slug: data.dec(_f$slug),
      displayName: data.dec(_f$displayName),
      seedColor: data.dec(_f$seedColor),
      logoLight: data.dec(_f$logoLight),
      logoTransparent: data.dec(_f$logoTransparent),
      splashBackgroundColor: data.dec(_f$splashBackgroundColor),
      subdomain: data.dec(_f$subdomain),
      dnsStatus: data.dec(_f$dnsStatus),
      dnsError: data.dec(_f$dnsError),
      dnsLastAttempt: data.dec(_f$dnsLastAttempt),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static OrganizationDto fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<OrganizationDto>(map);
  }

  static OrganizationDto fromJson(String json) {
    return ensureInitialized().decodeJson<OrganizationDto>(json);
  }
}

mixin OrganizationDtoMappable {
  String toJson() {
    return OrganizationDtoMapper.ensureInitialized()
        .encodeJson<OrganizationDto>(this as OrganizationDto);
  }

  Map<String, dynamic> toMap() {
    return OrganizationDtoMapper.ensureInitialized().encodeMap<OrganizationDto>(
      this as OrganizationDto,
    );
  }

  OrganizationDtoCopyWith<OrganizationDto, OrganizationDto, OrganizationDto>
  get copyWith =>
      _OrganizationDtoCopyWithImpl<OrganizationDto, OrganizationDto>(
        this as OrganizationDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return OrganizationDtoMapper.ensureInitialized().stringifyValue(
      this as OrganizationDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return OrganizationDtoMapper.ensureInitialized().equalsValue(
      this as OrganizationDto,
      other,
    );
  }

  @override
  int get hashCode {
    return OrganizationDtoMapper.ensureInitialized().hashValue(
      this as OrganizationDto,
    );
  }
}

extension OrganizationDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, OrganizationDto, $Out> {
  OrganizationDtoCopyWith<$R, OrganizationDto, $Out> get $asOrganizationDto =>
      $base.as((v, t, t2) => _OrganizationDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class OrganizationDtoCopyWith<$R, $In extends OrganizationDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    String? slug,
    String? displayName,
    String? seedColor,
    String? logoLight,
    String? logoTransparent,
    String? splashBackgroundColor,
    String? subdomain,
    String? dnsStatus,
    String? dnsError,
    String? dnsLastAttempt,
    bool? isDeleted,
    String? created,
    String? updated,
  });
  OrganizationDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _OrganizationDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, OrganizationDto, $Out>
    implements OrganizationDtoCopyWith<$R, OrganizationDto, $Out> {
  _OrganizationDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<OrganizationDto> $mapper =
      OrganizationDtoMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? collectionId,
    String? collectionName,
    String? name,
    String? slug,
    Object? displayName = $none,
    Object? seedColor = $none,
    String? logoLight,
    String? logoTransparent,
    Object? splashBackgroundColor = $none,
    Object? subdomain = $none,
    Object? dnsStatus = $none,
    Object? dnsError = $none,
    Object? dnsLastAttempt = $none,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (collectionId != null) #collectionId: collectionId,
      if (collectionName != null) #collectionName: collectionName,
      if (name != null) #name: name,
      if (slug != null) #slug: slug,
      if (displayName != $none) #displayName: displayName,
      if (seedColor != $none) #seedColor: seedColor,
      if (logoLight != null) #logoLight: logoLight,
      if (logoTransparent != null) #logoTransparent: logoTransparent,
      if (splashBackgroundColor != $none)
        #splashBackgroundColor: splashBackgroundColor,
      if (subdomain != $none) #subdomain: subdomain,
      if (dnsStatus != $none) #dnsStatus: dnsStatus,
      if (dnsError != $none) #dnsError: dnsError,
      if (dnsLastAttempt != $none) #dnsLastAttempt: dnsLastAttempt,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  OrganizationDto $make(CopyWithData data) => OrganizationDto(
    id: data.get(#id, or: $value.id),
    collectionId: data.get(#collectionId, or: $value.collectionId),
    collectionName: data.get(#collectionName, or: $value.collectionName),
    name: data.get(#name, or: $value.name),
    slug: data.get(#slug, or: $value.slug),
    displayName: data.get(#displayName, or: $value.displayName),
    seedColor: data.get(#seedColor, or: $value.seedColor),
    logoLight: data.get(#logoLight, or: $value.logoLight),
    logoTransparent: data.get(#logoTransparent, or: $value.logoTransparent),
    splashBackgroundColor: data.get(
      #splashBackgroundColor,
      or: $value.splashBackgroundColor,
    ),
    subdomain: data.get(#subdomain, or: $value.subdomain),
    dnsStatus: data.get(#dnsStatus, or: $value.dnsStatus),
    dnsError: data.get(#dnsError, or: $value.dnsError),
    dnsLastAttempt: data.get(#dnsLastAttempt, or: $value.dnsLastAttempt),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  OrganizationDtoCopyWith<$R2, OrganizationDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _OrganizationDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

