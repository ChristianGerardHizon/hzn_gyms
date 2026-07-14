// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'report_period.dart';

class ReportPeriodMapper extends EnumMapper<ReportPeriod> {
  ReportPeriodMapper._();

  static ReportPeriodMapper? _instance;
  static ReportPeriodMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ReportPeriodMapper._());
    }
    return _instance!;
  }

  static ReportPeriod fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  ReportPeriod decode(dynamic value) {
    switch (value) {
      case r'day':
        return ReportPeriod.day;
      case r'weekly':
        return ReportPeriod.weekly;
      case r'monthly':
        return ReportPeriod.monthly;
      case r'yearly':
        return ReportPeriod.yearly;
      case r'allTime':
        return ReportPeriod.allTime;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(ReportPeriod self) {
    switch (self) {
      case ReportPeriod.day:
        return r'day';
      case ReportPeriod.weekly:
        return r'weekly';
      case ReportPeriod.monthly:
        return r'monthly';
      case ReportPeriod.yearly:
        return r'yearly';
      case ReportPeriod.allTime:
        return r'allTime';
    }
  }
}

extension ReportPeriodMapperExtension on ReportPeriod {
  String toValue() {
    ReportPeriodMapper.ensureInitialized();
    return MapperContainer.globals.toValue<ReportPeriod>(this) as String;
  }
}

class ReportPeriodSelectionMapper
    extends ClassMapperBase<ReportPeriodSelection> {
  ReportPeriodSelectionMapper._();

  static ReportPeriodSelectionMapper? _instance;
  static ReportPeriodSelectionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ReportPeriodSelectionMapper._());
      ReportPeriodMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ReportPeriodSelection';

  static ReportPeriod _$period(ReportPeriodSelection v) => v.period;
  static const Field<ReportPeriodSelection, ReportPeriod> _f$period = Field(
    'period',
    _$period,
  );
  static DateTime _$rangeStart(ReportPeriodSelection v) => v.rangeStart;
  static const Field<ReportPeriodSelection, DateTime> _f$rangeStart = Field(
    'rangeStart',
    _$rangeStart,
  );
  static DateTime _$rangeEnd(ReportPeriodSelection v) => v.rangeEnd;
  static const Field<ReportPeriodSelection, DateTime> _f$rangeEnd = Field(
    'rangeEnd',
    _$rangeEnd,
  );

  @override
  final MappableFields<ReportPeriodSelection> fields = const {
    #period: _f$period,
    #rangeStart: _f$rangeStart,
    #rangeEnd: _f$rangeEnd,
  };

  static ReportPeriodSelection _instantiate(DecodingData data) {
    return ReportPeriodSelection(
      period: data.dec(_f$period),
      rangeStart: data.dec(_f$rangeStart),
      rangeEnd: data.dec(_f$rangeEnd),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ReportPeriodSelection fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ReportPeriodSelection>(map);
  }

  static ReportPeriodSelection fromJson(String json) {
    return ensureInitialized().decodeJson<ReportPeriodSelection>(json);
  }
}

mixin ReportPeriodSelectionMappable {
  String toJson() {
    return ReportPeriodSelectionMapper.ensureInitialized()
        .encodeJson<ReportPeriodSelection>(this as ReportPeriodSelection);
  }

  Map<String, dynamic> toMap() {
    return ReportPeriodSelectionMapper.ensureInitialized()
        .encodeMap<ReportPeriodSelection>(this as ReportPeriodSelection);
  }

  ReportPeriodSelectionCopyWith<
    ReportPeriodSelection,
    ReportPeriodSelection,
    ReportPeriodSelection
  >
  get copyWith =>
      _ReportPeriodSelectionCopyWithImpl<
        ReportPeriodSelection,
        ReportPeriodSelection
      >(this as ReportPeriodSelection, $identity, $identity);
  @override
  String toString() {
    return ReportPeriodSelectionMapper.ensureInitialized().stringifyValue(
      this as ReportPeriodSelection,
    );
  }

  @override
  bool operator ==(Object other) {
    return ReportPeriodSelectionMapper.ensureInitialized().equalsValue(
      this as ReportPeriodSelection,
      other,
    );
  }

  @override
  int get hashCode {
    return ReportPeriodSelectionMapper.ensureInitialized().hashValue(
      this as ReportPeriodSelection,
    );
  }
}

extension ReportPeriodSelectionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ReportPeriodSelection, $Out> {
  ReportPeriodSelectionCopyWith<$R, ReportPeriodSelection, $Out>
  get $asReportPeriodSelection => $base.as(
    (v, t, t2) => _ReportPeriodSelectionCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class ReportPeriodSelectionCopyWith<
  $R,
  $In extends ReportPeriodSelection,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({ReportPeriod? period, DateTime? rangeStart, DateTime? rangeEnd});
  ReportPeriodSelectionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ReportPeriodSelectionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ReportPeriodSelection, $Out>
    implements ReportPeriodSelectionCopyWith<$R, ReportPeriodSelection, $Out> {
  _ReportPeriodSelectionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ReportPeriodSelection> $mapper =
      ReportPeriodSelectionMapper.ensureInitialized();
  @override
  $R call({ReportPeriod? period, DateTime? rangeStart, DateTime? rangeEnd}) =>
      $apply(
        FieldCopyWithData({
          if (period != null) #period: period,
          if (rangeStart != null) #rangeStart: rangeStart,
          if (rangeEnd != null) #rangeEnd: rangeEnd,
        }),
      );
  @override
  ReportPeriodSelection $make(CopyWithData data) => ReportPeriodSelection(
    period: data.get(#period, or: $value.period),
    rangeStart: data.get(#rangeStart, or: $value.rangeStart),
    rangeEnd: data.get(#rangeEnd, or: $value.rangeEnd),
  );

  @override
  ReportPeriodSelectionCopyWith<$R2, ReportPeriodSelection, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ReportPeriodSelectionCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

