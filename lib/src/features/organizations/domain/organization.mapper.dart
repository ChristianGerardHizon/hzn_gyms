// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'organization.dart';

class OrganizationMapper extends ClassMapperBase<Organization> {
  OrganizationMapper._();

  static OrganizationMapper? _instance;
  static OrganizationMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = OrganizationMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Organization';

  static String _$id(Organization v) => v.id;
  static const Field<Organization, String> _f$id = Field('id', _$id);
  static String _$name(Organization v) => v.name;
  static const Field<Organization, String> _f$name = Field('name', _$name);
  static String _$slug(Organization v) => v.slug;
  static const Field<Organization, String> _f$slug = Field('slug', _$slug);
  static String? _$displayName(Organization v) => v.displayName;
  static const Field<Organization, String> _f$displayName = Field(
    'displayName',
    _$displayName,
    opt: true,
  );
  static String? _$seedColor(Organization v) => v.seedColor;
  static const Field<Organization, String> _f$seedColor = Field(
    'seedColor',
    _$seedColor,
    opt: true,
  );
  static String? _$logoLightUrl(Organization v) => v.logoLightUrl;
  static const Field<Organization, String> _f$logoLightUrl = Field(
    'logoLightUrl',
    _$logoLightUrl,
    opt: true,
  );
  static String? _$logoTransparentUrl(Organization v) => v.logoTransparentUrl;
  static const Field<Organization, String> _f$logoTransparentUrl = Field(
    'logoTransparentUrl',
    _$logoTransparentUrl,
    opt: true,
  );
  static String? _$splashBackgroundColor(Organization v) =>
      v.splashBackgroundColor;
  static const Field<Organization, String> _f$splashBackgroundColor = Field(
    'splashBackgroundColor',
    _$splashBackgroundColor,
    opt: true,
  );
  static String? _$subdomain(Organization v) => v.subdomain;
  static const Field<Organization, String> _f$subdomain = Field(
    'subdomain',
    _$subdomain,
    opt: true,
  );
  static OrganizationDnsStatus _$dnsStatus(Organization v) => v.dnsStatus;
  static const Field<Organization, OrganizationDnsStatus> _f$dnsStatus = Field(
    'dnsStatus',
    _$dnsStatus,
    opt: true,
    def: OrganizationDnsStatus.pending,
  );
  static String? _$dnsError(Organization v) => v.dnsError;
  static const Field<Organization, String> _f$dnsError = Field(
    'dnsError',
    _$dnsError,
    opt: true,
  );
  static DateTime? _$dnsLastAttempt(Organization v) => v.dnsLastAttempt;
  static const Field<Organization, DateTime> _f$dnsLastAttempt = Field(
    'dnsLastAttempt',
    _$dnsLastAttempt,
    opt: true,
  );
  static OrganizationSetupStatus _$setupStatus(Organization v) => v.setupStatus;
  static const Field<Organization, OrganizationSetupStatus> _f$setupStatus =
      Field(
        'setupStatus',
        _$setupStatus,
        opt: true,
        def: OrganizationSetupStatus.pendingSetup,
      );
  static DateTime? _$setupCompletedAt(Organization v) => v.setupCompletedAt;
  static const Field<Organization, DateTime> _f$setupCompletedAt = Field(
    'setupCompletedAt',
    _$setupCompletedAt,
    opt: true,
  );
  static bool _$isDeleted(Organization v) => v.isDeleted;
  static const Field<Organization, bool> _f$isDeleted = Field(
    'isDeleted',
    _$isDeleted,
    opt: true,
    def: false,
  );
  static DateTime? _$created(Organization v) => v.created;
  static const Field<Organization, DateTime> _f$created = Field(
    'created',
    _$created,
    opt: true,
  );
  static DateTime? _$updated(Organization v) => v.updated;
  static const Field<Organization, DateTime> _f$updated = Field(
    'updated',
    _$updated,
    opt: true,
  );

  @override
  final MappableFields<Organization> fields = const {
    #id: _f$id,
    #name: _f$name,
    #slug: _f$slug,
    #displayName: _f$displayName,
    #seedColor: _f$seedColor,
    #logoLightUrl: _f$logoLightUrl,
    #logoTransparentUrl: _f$logoTransparentUrl,
    #splashBackgroundColor: _f$splashBackgroundColor,
    #subdomain: _f$subdomain,
    #dnsStatus: _f$dnsStatus,
    #dnsError: _f$dnsError,
    #dnsLastAttempt: _f$dnsLastAttempt,
    #setupStatus: _f$setupStatus,
    #setupCompletedAt: _f$setupCompletedAt,
    #isDeleted: _f$isDeleted,
    #created: _f$created,
    #updated: _f$updated,
  };

  static Organization _instantiate(DecodingData data) {
    return Organization(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      slug: data.dec(_f$slug),
      displayName: data.dec(_f$displayName),
      seedColor: data.dec(_f$seedColor),
      logoLightUrl: data.dec(_f$logoLightUrl),
      logoTransparentUrl: data.dec(_f$logoTransparentUrl),
      splashBackgroundColor: data.dec(_f$splashBackgroundColor),
      subdomain: data.dec(_f$subdomain),
      dnsStatus: data.dec(_f$dnsStatus),
      dnsError: data.dec(_f$dnsError),
      dnsLastAttempt: data.dec(_f$dnsLastAttempt),
      setupStatus: data.dec(_f$setupStatus),
      setupCompletedAt: data.dec(_f$setupCompletedAt),
      isDeleted: data.dec(_f$isDeleted),
      created: data.dec(_f$created),
      updated: data.dec(_f$updated),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Organization fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Organization>(map);
  }

  static Organization fromJson(String json) {
    return ensureInitialized().decodeJson<Organization>(json);
  }
}

mixin OrganizationMappable {
  String toJson() {
    return OrganizationMapper.ensureInitialized().encodeJson<Organization>(
      this as Organization,
    );
  }

  Map<String, dynamic> toMap() {
    return OrganizationMapper.ensureInitialized().encodeMap<Organization>(
      this as Organization,
    );
  }

  OrganizationCopyWith<Organization, Organization, Organization> get copyWith =>
      _OrganizationCopyWithImpl<Organization, Organization>(
        this as Organization,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return OrganizationMapper.ensureInitialized().stringifyValue(
      this as Organization,
    );
  }

  @override
  bool operator ==(Object other) {
    return OrganizationMapper.ensureInitialized().equalsValue(
      this as Organization,
      other,
    );
  }

  @override
  int get hashCode {
    return OrganizationMapper.ensureInitialized().hashValue(
      this as Organization,
    );
  }
}

extension OrganizationValueCopy<$R, $Out>
    on ObjectCopyWith<$R, Organization, $Out> {
  OrganizationCopyWith<$R, Organization, $Out> get $asOrganization =>
      $base.as((v, t, t2) => _OrganizationCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class OrganizationCopyWith<$R, $In extends Organization, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    String? slug,
    String? displayName,
    String? seedColor,
    String? logoLightUrl,
    String? logoTransparentUrl,
    String? splashBackgroundColor,
    String? subdomain,
    OrganizationDnsStatus? dnsStatus,
    String? dnsError,
    DateTime? dnsLastAttempt,
    OrganizationSetupStatus? setupStatus,
    DateTime? setupCompletedAt,
    bool? isDeleted,
    DateTime? created,
    DateTime? updated,
  });
  OrganizationCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _OrganizationCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Organization, $Out>
    implements OrganizationCopyWith<$R, Organization, $Out> {
  _OrganizationCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Organization> $mapper =
      OrganizationMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? name,
    String? slug,
    Object? displayName = $none,
    Object? seedColor = $none,
    Object? logoLightUrl = $none,
    Object? logoTransparentUrl = $none,
    Object? splashBackgroundColor = $none,
    Object? subdomain = $none,
    OrganizationDnsStatus? dnsStatus,
    Object? dnsError = $none,
    Object? dnsLastAttempt = $none,
    OrganizationSetupStatus? setupStatus,
    Object? setupCompletedAt = $none,
    bool? isDeleted,
    Object? created = $none,
    Object? updated = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (name != null) #name: name,
      if (slug != null) #slug: slug,
      if (displayName != $none) #displayName: displayName,
      if (seedColor != $none) #seedColor: seedColor,
      if (logoLightUrl != $none) #logoLightUrl: logoLightUrl,
      if (logoTransparentUrl != $none) #logoTransparentUrl: logoTransparentUrl,
      if (splashBackgroundColor != $none)
        #splashBackgroundColor: splashBackgroundColor,
      if (subdomain != $none) #subdomain: subdomain,
      if (dnsStatus != null) #dnsStatus: dnsStatus,
      if (dnsError != $none) #dnsError: dnsError,
      if (dnsLastAttempt != $none) #dnsLastAttempt: dnsLastAttempt,
      if (setupStatus != null) #setupStatus: setupStatus,
      if (setupCompletedAt != $none) #setupCompletedAt: setupCompletedAt,
      if (isDeleted != null) #isDeleted: isDeleted,
      if (created != $none) #created: created,
      if (updated != $none) #updated: updated,
    }),
  );
  @override
  Organization $make(CopyWithData data) => Organization(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    slug: data.get(#slug, or: $value.slug),
    displayName: data.get(#displayName, or: $value.displayName),
    seedColor: data.get(#seedColor, or: $value.seedColor),
    logoLightUrl: data.get(#logoLightUrl, or: $value.logoLightUrl),
    logoTransparentUrl: data.get(
      #logoTransparentUrl,
      or: $value.logoTransparentUrl,
    ),
    splashBackgroundColor: data.get(
      #splashBackgroundColor,
      or: $value.splashBackgroundColor,
    ),
    subdomain: data.get(#subdomain, or: $value.subdomain),
    dnsStatus: data.get(#dnsStatus, or: $value.dnsStatus),
    dnsError: data.get(#dnsError, or: $value.dnsError),
    dnsLastAttempt: data.get(#dnsLastAttempt, or: $value.dnsLastAttempt),
    setupStatus: data.get(#setupStatus, or: $value.setupStatus),
    setupCompletedAt: data.get(#setupCompletedAt, or: $value.setupCompletedAt),
    isDeleted: data.get(#isDeleted, or: $value.isDeleted),
    created: data.get(#created, or: $value.created),
    updated: data.get(#updated, or: $value.updated),
  );

  @override
  OrganizationCopyWith<$R2, Organization, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _OrganizationCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

