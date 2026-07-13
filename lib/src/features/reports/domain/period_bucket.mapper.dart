// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'period_bucket.dart';

class PeriodBucketMapper extends ClassMapperBase<PeriodBucket> {
  PeriodBucketMapper._();

  static PeriodBucketMapper? _instance;
  static PeriodBucketMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PeriodBucketMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'PeriodBucket';

  static DateTime _$periodStart(PeriodBucket v) => v.periodStart;
  static const Field<PeriodBucket, DateTime> _f$periodStart = Field(
    'periodStart',
    _$periodStart,
  );
  static num _$value(PeriodBucket v) => v.value;
  static const Field<PeriodBucket, num> _f$value = Field('value', _$value);
  static String _$label(PeriodBucket v) => v.label;
  static const Field<PeriodBucket, String> _f$label = Field('label', _$label);

  @override
  final MappableFields<PeriodBucket> fields = const {
    #periodStart: _f$periodStart,
    #value: _f$value,
    #label: _f$label,
  };

  static PeriodBucket _instantiate(DecodingData data) {
    return PeriodBucket(
      periodStart: data.dec(_f$periodStart),
      value: data.dec(_f$value),
      label: data.dec(_f$label),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static PeriodBucket fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PeriodBucket>(map);
  }

  static PeriodBucket fromJson(String json) {
    return ensureInitialized().decodeJson<PeriodBucket>(json);
  }
}

mixin PeriodBucketMappable {
  String toJson() {
    return PeriodBucketMapper.ensureInitialized().encodeJson<PeriodBucket>(
      this as PeriodBucket,
    );
  }

  Map<String, dynamic> toMap() {
    return PeriodBucketMapper.ensureInitialized().encodeMap<PeriodBucket>(
      this as PeriodBucket,
    );
  }

  PeriodBucketCopyWith<PeriodBucket, PeriodBucket, PeriodBucket> get copyWith =>
      _PeriodBucketCopyWithImpl<PeriodBucket, PeriodBucket>(
        this as PeriodBucket,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PeriodBucketMapper.ensureInitialized().stringifyValue(
      this as PeriodBucket,
    );
  }

  @override
  bool operator ==(Object other) {
    return PeriodBucketMapper.ensureInitialized().equalsValue(
      this as PeriodBucket,
      other,
    );
  }

  @override
  int get hashCode {
    return PeriodBucketMapper.ensureInitialized().hashValue(
      this as PeriodBucket,
    );
  }
}

extension PeriodBucketValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PeriodBucket, $Out> {
  PeriodBucketCopyWith<$R, PeriodBucket, $Out> get $asPeriodBucket =>
      $base.as((v, t, t2) => _PeriodBucketCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PeriodBucketCopyWith<$R, $In extends PeriodBucket, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({DateTime? periodStart, num? value, String? label});
  PeriodBucketCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PeriodBucketCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PeriodBucket, $Out>
    implements PeriodBucketCopyWith<$R, PeriodBucket, $Out> {
  _PeriodBucketCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PeriodBucket> $mapper =
      PeriodBucketMapper.ensureInitialized();
  @override
  $R call({DateTime? periodStart, num? value, String? label}) => $apply(
    FieldCopyWithData({
      if (periodStart != null) #periodStart: periodStart,
      if (value != null) #value: value,
      if (label != null) #label: label,
    }),
  );
  @override
  PeriodBucket $make(CopyWithData data) => PeriodBucket(
    periodStart: data.get(#periodStart, or: $value.periodStart),
    value: data.get(#value, or: $value.value),
    label: data.get(#label, or: $value.label),
  );

  @override
  PeriodBucketCopyWith<$R2, PeriodBucket, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PeriodBucketCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

