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

