// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'attendance_report.dart';

class AttendanceReportMapper extends ClassMapperBase<AttendanceReport> {
  AttendanceReportMapper._();

  static AttendanceReportMapper? _instance;
  static AttendanceReportMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AttendanceReportMapper._());
      PeriodBucketMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'AttendanceReport';

  static int _$totalCheckIns(AttendanceReport v) => v.totalCheckIns;
  static const Field<AttendanceReport, int> _f$totalCheckIns = Field(
    'totalCheckIns',
    _$totalCheckIns,
  );
  static int _$uniqueMembers(AttendanceReport v) => v.uniqueMembers;
  static const Field<AttendanceReport, int> _f$uniqueMembers = Field(
    'uniqueMembers',
    _$uniqueMembers,
  );
  static List<PeriodBucket> _$checkInsTrend(AttendanceReport v) =>
      v.checkInsTrend;
  static const Field<AttendanceReport, List<PeriodBucket>> _f$checkInsTrend =
      Field('checkInsTrend', _$checkInsTrend);
  static Map<String, num> _$checkInsByMethod(AttendanceReport v) =>
      v.checkInsByMethod;
  static const Field<AttendanceReport, Map<String, num>> _f$checkInsByMethod =
      Field('checkInsByMethod', _$checkInsByMethod);
  static Map<String, num> _$checkInsByHour(AttendanceReport v) =>
      v.checkInsByHour;
  static const Field<AttendanceReport, Map<String, num>> _f$checkInsByHour =
      Field('checkInsByHour', _$checkInsByHour);
  static int _$withoutActiveMembershipCount(AttendanceReport v) =>
      v.withoutActiveMembershipCount;
  static const Field<AttendanceReport, int> _f$withoutActiveMembershipCount =
      Field(
        'withoutActiveMembershipCount',
        _$withoutActiveMembershipCount,
        opt: true,
        def: 0,
      );

  @override
  final MappableFields<AttendanceReport> fields = const {
    #totalCheckIns: _f$totalCheckIns,
    #uniqueMembers: _f$uniqueMembers,
    #checkInsTrend: _f$checkInsTrend,
    #checkInsByMethod: _f$checkInsByMethod,
    #checkInsByHour: _f$checkInsByHour,
    #withoutActiveMembershipCount: _f$withoutActiveMembershipCount,
  };

  static AttendanceReport _instantiate(DecodingData data) {
    return AttendanceReport(
      totalCheckIns: data.dec(_f$totalCheckIns),
      uniqueMembers: data.dec(_f$uniqueMembers),
      checkInsTrend: data.dec(_f$checkInsTrend),
      checkInsByMethod: data.dec(_f$checkInsByMethod),
      checkInsByHour: data.dec(_f$checkInsByHour),
      withoutActiveMembershipCount: data.dec(_f$withoutActiveMembershipCount),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static AttendanceReport fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AttendanceReport>(map);
  }

  static AttendanceReport fromJson(String json) {
    return ensureInitialized().decodeJson<AttendanceReport>(json);
  }
}

mixin AttendanceReportMappable {
  String toJson() {
    return AttendanceReportMapper.ensureInitialized()
        .encodeJson<AttendanceReport>(this as AttendanceReport);
  }

  Map<String, dynamic> toMap() {
    return AttendanceReportMapper.ensureInitialized()
        .encodeMap<AttendanceReport>(this as AttendanceReport);
  }

  AttendanceReportCopyWith<AttendanceReport, AttendanceReport, AttendanceReport>
  get copyWith =>
      _AttendanceReportCopyWithImpl<AttendanceReport, AttendanceReport>(
        this as AttendanceReport,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AttendanceReportMapper.ensureInitialized().stringifyValue(
      this as AttendanceReport,
    );
  }

  @override
  bool operator ==(Object other) {
    return AttendanceReportMapper.ensureInitialized().equalsValue(
      this as AttendanceReport,
      other,
    );
  }

  @override
  int get hashCode {
    return AttendanceReportMapper.ensureInitialized().hashValue(
      this as AttendanceReport,
    );
  }
}

extension AttendanceReportValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AttendanceReport, $Out> {
  AttendanceReportCopyWith<$R, AttendanceReport, $Out>
  get $asAttendanceReport =>
      $base.as((v, t, t2) => _AttendanceReportCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AttendanceReportCopyWith<$R, $In extends AttendanceReport, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    PeriodBucket,
    PeriodBucketCopyWith<$R, PeriodBucket, PeriodBucket>
  >
  get checkInsTrend;
  MapCopyWith<$R, String, num, ObjectCopyWith<$R, num, num>>
  get checkInsByMethod;
  MapCopyWith<$R, String, num, ObjectCopyWith<$R, num, num>> get checkInsByHour;
  $R call({
    int? totalCheckIns,
    int? uniqueMembers,
    List<PeriodBucket>? checkInsTrend,
    Map<String, num>? checkInsByMethod,
    Map<String, num>? checkInsByHour,
    int? withoutActiveMembershipCount,
  });
  AttendanceReportCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _AttendanceReportCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AttendanceReport, $Out>
    implements AttendanceReportCopyWith<$R, AttendanceReport, $Out> {
  _AttendanceReportCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AttendanceReport> $mapper =
      AttendanceReportMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    PeriodBucket,
    PeriodBucketCopyWith<$R, PeriodBucket, PeriodBucket>
  >
  get checkInsTrend => ListCopyWith(
    $value.checkInsTrend,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(checkInsTrend: v),
  );
  @override
  MapCopyWith<$R, String, num, ObjectCopyWith<$R, num, num>>
  get checkInsByMethod => MapCopyWith(
    $value.checkInsByMethod,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(checkInsByMethod: v),
  );
  @override
  MapCopyWith<$R, String, num, ObjectCopyWith<$R, num, num>>
  get checkInsByHour => MapCopyWith(
    $value.checkInsByHour,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(checkInsByHour: v),
  );
  @override
  $R call({
    int? totalCheckIns,
    int? uniqueMembers,
    List<PeriodBucket>? checkInsTrend,
    Map<String, num>? checkInsByMethod,
    Map<String, num>? checkInsByHour,
    int? withoutActiveMembershipCount,
  }) => $apply(
    FieldCopyWithData({
      if (totalCheckIns != null) #totalCheckIns: totalCheckIns,
      if (uniqueMembers != null) #uniqueMembers: uniqueMembers,
      if (checkInsTrend != null) #checkInsTrend: checkInsTrend,
      if (checkInsByMethod != null) #checkInsByMethod: checkInsByMethod,
      if (checkInsByHour != null) #checkInsByHour: checkInsByHour,
      if (withoutActiveMembershipCount != null)
        #withoutActiveMembershipCount: withoutActiveMembershipCount,
    }),
  );
  @override
  AttendanceReport $make(CopyWithData data) => AttendanceReport(
    totalCheckIns: data.get(#totalCheckIns, or: $value.totalCheckIns),
    uniqueMembers: data.get(#uniqueMembers, or: $value.uniqueMembers),
    checkInsTrend: data.get(#checkInsTrend, or: $value.checkInsTrend),
    checkInsByMethod: data.get(#checkInsByMethod, or: $value.checkInsByMethod),
    checkInsByHour: data.get(#checkInsByHour, or: $value.checkInsByHour),
    withoutActiveMembershipCount: data.get(
      #withoutActiveMembershipCount,
      or: $value.withoutActiveMembershipCount,
    ),
  );

  @override
  AttendanceReportCopyWith<$R2, AttendanceReport, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _AttendanceReportCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

