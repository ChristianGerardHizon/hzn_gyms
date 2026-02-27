// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'membership_report.dart';

class MembershipReportMapper extends ClassMapperBase<MembershipReport> {
  MembershipReportMapper._();

  static MembershipReportMapper? _instance;
  static MembershipReportMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MembershipReportMapper._());
      DailyRegistrationMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'MembershipReport';

  static int _$totalNewMembers(MembershipReport v) => v.totalNewMembers;
  static const Field<MembershipReport, int> _f$totalNewMembers = Field(
    'totalNewMembers',
    _$totalNewMembers,
  );
  static int _$activeMemberships(MembershipReport v) => v.activeMemberships;
  static const Field<MembershipReport, int> _f$activeMemberships = Field(
    'activeMemberships',
    _$activeMemberships,
  );
  static int _$expiredCancelledMemberships(MembershipReport v) =>
      v.expiredCancelledMemberships;
  static const Field<MembershipReport, int> _f$expiredCancelledMemberships =
      Field('expiredCancelledMemberships', _$expiredCancelledMemberships);
  static num _$membershipRevenue(MembershipReport v) => v.membershipRevenue;
  static const Field<MembershipReport, num> _f$membershipRevenue = Field(
    'membershipRevenue',
    _$membershipRevenue,
  );
  static num _$addOnRevenue(MembershipReport v) => v.addOnRevenue;
  static const Field<MembershipReport, num> _f$addOnRevenue = Field(
    'addOnRevenue',
    _$addOnRevenue,
  );
  static List<DailyRegistration> _$registrationsByDay(MembershipReport v) =>
      v.registrationsByDay;
  static const Field<MembershipReport, List<DailyRegistration>>
  _f$registrationsByDay = Field('registrationsByDay', _$registrationsByDay);
  static Map<String, num> _$membershipPlanDistribution(MembershipReport v) =>
      v.membershipPlanDistribution;
  static const Field<MembershipReport, Map<String, num>>
  _f$membershipPlanDistribution = Field(
    'membershipPlanDistribution',
    _$membershipPlanDistribution,
  );
  static Map<String, num> _$revenueByPlan(MembershipReport v) =>
      v.revenueByPlan;
  static const Field<MembershipReport, Map<String, num>> _f$revenueByPlan =
      Field('revenueByPlan', _$revenueByPlan);

  @override
  final MappableFields<MembershipReport> fields = const {
    #totalNewMembers: _f$totalNewMembers,
    #activeMemberships: _f$activeMemberships,
    #expiredCancelledMemberships: _f$expiredCancelledMemberships,
    #membershipRevenue: _f$membershipRevenue,
    #addOnRevenue: _f$addOnRevenue,
    #registrationsByDay: _f$registrationsByDay,
    #membershipPlanDistribution: _f$membershipPlanDistribution,
    #revenueByPlan: _f$revenueByPlan,
  };

  static MembershipReport _instantiate(DecodingData data) {
    return MembershipReport(
      totalNewMembers: data.dec(_f$totalNewMembers),
      activeMemberships: data.dec(_f$activeMemberships),
      expiredCancelledMemberships: data.dec(_f$expiredCancelledMemberships),
      membershipRevenue: data.dec(_f$membershipRevenue),
      addOnRevenue: data.dec(_f$addOnRevenue),
      registrationsByDay: data.dec(_f$registrationsByDay),
      membershipPlanDistribution: data.dec(_f$membershipPlanDistribution),
      revenueByPlan: data.dec(_f$revenueByPlan),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MembershipReport fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MembershipReport>(map);
  }

  static MembershipReport fromJson(String json) {
    return ensureInitialized().decodeJson<MembershipReport>(json);
  }
}

mixin MembershipReportMappable {
  String toJson() {
    return MembershipReportMapper.ensureInitialized()
        .encodeJson<MembershipReport>(this as MembershipReport);
  }

  Map<String, dynamic> toMap() {
    return MembershipReportMapper.ensureInitialized()
        .encodeMap<MembershipReport>(this as MembershipReport);
  }

  MembershipReportCopyWith<MembershipReport, MembershipReport, MembershipReport>
  get copyWith =>
      _MembershipReportCopyWithImpl<MembershipReport, MembershipReport>(
        this as MembershipReport,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return MembershipReportMapper.ensureInitialized().stringifyValue(
      this as MembershipReport,
    );
  }

  @override
  bool operator ==(Object other) {
    return MembershipReportMapper.ensureInitialized().equalsValue(
      this as MembershipReport,
      other,
    );
  }

  @override
  int get hashCode {
    return MembershipReportMapper.ensureInitialized().hashValue(
      this as MembershipReport,
    );
  }
}

extension MembershipReportValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MembershipReport, $Out> {
  MembershipReportCopyWith<$R, MembershipReport, $Out>
  get $asMembershipReport =>
      $base.as((v, t, t2) => _MembershipReportCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class MembershipReportCopyWith<$R, $In extends MembershipReport, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    DailyRegistration,
    DailyRegistrationCopyWith<$R, DailyRegistration, DailyRegistration>
  >
  get registrationsByDay;
  MapCopyWith<$R, String, num, ObjectCopyWith<$R, num, num>>
  get membershipPlanDistribution;
  MapCopyWith<$R, String, num, ObjectCopyWith<$R, num, num>> get revenueByPlan;
  $R call({
    int? totalNewMembers,
    int? activeMemberships,
    int? expiredCancelledMemberships,
    num? membershipRevenue,
    num? addOnRevenue,
    List<DailyRegistration>? registrationsByDay,
    Map<String, num>? membershipPlanDistribution,
    Map<String, num>? revenueByPlan,
  });
  MembershipReportCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _MembershipReportCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MembershipReport, $Out>
    implements MembershipReportCopyWith<$R, MembershipReport, $Out> {
  _MembershipReportCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MembershipReport> $mapper =
      MembershipReportMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    DailyRegistration,
    DailyRegistrationCopyWith<$R, DailyRegistration, DailyRegistration>
  >
  get registrationsByDay => ListCopyWith(
    $value.registrationsByDay,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(registrationsByDay: v),
  );
  @override
  MapCopyWith<$R, String, num, ObjectCopyWith<$R, num, num>>
  get membershipPlanDistribution => MapCopyWith(
    $value.membershipPlanDistribution,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(membershipPlanDistribution: v),
  );
  @override
  MapCopyWith<$R, String, num, ObjectCopyWith<$R, num, num>>
  get revenueByPlan => MapCopyWith(
    $value.revenueByPlan,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(revenueByPlan: v),
  );
  @override
  $R call({
    int? totalNewMembers,
    int? activeMemberships,
    int? expiredCancelledMemberships,
    num? membershipRevenue,
    num? addOnRevenue,
    List<DailyRegistration>? registrationsByDay,
    Map<String, num>? membershipPlanDistribution,
    Map<String, num>? revenueByPlan,
  }) => $apply(
    FieldCopyWithData({
      if (totalNewMembers != null) #totalNewMembers: totalNewMembers,
      if (activeMemberships != null) #activeMemberships: activeMemberships,
      if (expiredCancelledMemberships != null)
        #expiredCancelledMemberships: expiredCancelledMemberships,
      if (membershipRevenue != null) #membershipRevenue: membershipRevenue,
      if (addOnRevenue != null) #addOnRevenue: addOnRevenue,
      if (registrationsByDay != null) #registrationsByDay: registrationsByDay,
      if (membershipPlanDistribution != null)
        #membershipPlanDistribution: membershipPlanDistribution,
      if (revenueByPlan != null) #revenueByPlan: revenueByPlan,
    }),
  );
  @override
  MembershipReport $make(CopyWithData data) => MembershipReport(
    totalNewMembers: data.get(#totalNewMembers, or: $value.totalNewMembers),
    activeMemberships: data.get(
      #activeMemberships,
      or: $value.activeMemberships,
    ),
    expiredCancelledMemberships: data.get(
      #expiredCancelledMemberships,
      or: $value.expiredCancelledMemberships,
    ),
    membershipRevenue: data.get(
      #membershipRevenue,
      or: $value.membershipRevenue,
    ),
    addOnRevenue: data.get(#addOnRevenue, or: $value.addOnRevenue),
    registrationsByDay: data.get(
      #registrationsByDay,
      or: $value.registrationsByDay,
    ),
    membershipPlanDistribution: data.get(
      #membershipPlanDistribution,
      or: $value.membershipPlanDistribution,
    ),
    revenueByPlan: data.get(#revenueByPlan, or: $value.revenueByPlan),
  );

  @override
  MembershipReportCopyWith<$R2, MembershipReport, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _MembershipReportCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DailyRegistrationMapper extends ClassMapperBase<DailyRegistration> {
  DailyRegistrationMapper._();

  static DailyRegistrationMapper? _instance;
  static DailyRegistrationMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DailyRegistrationMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'DailyRegistration';

  static DateTime _$date(DailyRegistration v) => v.date;
  static const Field<DailyRegistration, DateTime> _f$date = Field(
    'date',
    _$date,
  );
  static int _$count(DailyRegistration v) => v.count;
  static const Field<DailyRegistration, int> _f$count = Field('count', _$count);

  @override
  final MappableFields<DailyRegistration> fields = const {
    #date: _f$date,
    #count: _f$count,
  };

  static DailyRegistration _instantiate(DecodingData data) {
    return DailyRegistration(
      date: data.dec(_f$date),
      count: data.dec(_f$count),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static DailyRegistration fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DailyRegistration>(map);
  }

  static DailyRegistration fromJson(String json) {
    return ensureInitialized().decodeJson<DailyRegistration>(json);
  }
}

mixin DailyRegistrationMappable {
  String toJson() {
    return DailyRegistrationMapper.ensureInitialized()
        .encodeJson<DailyRegistration>(this as DailyRegistration);
  }

  Map<String, dynamic> toMap() {
    return DailyRegistrationMapper.ensureInitialized()
        .encodeMap<DailyRegistration>(this as DailyRegistration);
  }

  DailyRegistrationCopyWith<
    DailyRegistration,
    DailyRegistration,
    DailyRegistration
  >
  get copyWith =>
      _DailyRegistrationCopyWithImpl<DailyRegistration, DailyRegistration>(
        this as DailyRegistration,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DailyRegistrationMapper.ensureInitialized().stringifyValue(
      this as DailyRegistration,
    );
  }

  @override
  bool operator ==(Object other) {
    return DailyRegistrationMapper.ensureInitialized().equalsValue(
      this as DailyRegistration,
      other,
    );
  }

  @override
  int get hashCode {
    return DailyRegistrationMapper.ensureInitialized().hashValue(
      this as DailyRegistration,
    );
  }
}

extension DailyRegistrationValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DailyRegistration, $Out> {
  DailyRegistrationCopyWith<$R, DailyRegistration, $Out>
  get $asDailyRegistration => $base.as(
    (v, t, t2) => _DailyRegistrationCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class DailyRegistrationCopyWith<
  $R,
  $In extends DailyRegistration,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({DateTime? date, int? count});
  DailyRegistrationCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _DailyRegistrationCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DailyRegistration, $Out>
    implements DailyRegistrationCopyWith<$R, DailyRegistration, $Out> {
  _DailyRegistrationCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DailyRegistration> $mapper =
      DailyRegistrationMapper.ensureInitialized();
  @override
  $R call({DateTime? date, int? count}) => $apply(
    FieldCopyWithData({
      if (date != null) #date: date,
      if (count != null) #count: count,
    }),
  );
  @override
  DailyRegistration $make(CopyWithData data) => DailyRegistration(
    date: data.get(#date, or: $value.date),
    count: data.get(#count, or: $value.count),
  );

  @override
  DailyRegistrationCopyWith<$R2, DailyRegistration, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DailyRegistrationCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

