// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'sale_status.dart';

class SaleStatusMapper extends EnumMapper<SaleStatus> {
  SaleStatusMapper._();

  static SaleStatusMapper? _instance;
  static SaleStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SaleStatusMapper._());
    }
    return _instance!;
  }

  static SaleStatus fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  SaleStatus decode(dynamic value) {
    switch (value) {
      case r'pending':
        return SaleStatus.pending;
      case r'awaitingPayment':
        return SaleStatus.awaitingPayment;
      case r'paid':
        return SaleStatus.paid;
      case r'completed':
        return SaleStatus.completed;
      case r'refunded':
        return SaleStatus.refunded;
      case r'voided':
        return SaleStatus.voided;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(SaleStatus self) {
    switch (self) {
      case SaleStatus.pending:
        return r'pending';
      case SaleStatus.awaitingPayment:
        return r'awaitingPayment';
      case SaleStatus.paid:
        return r'paid';
      case SaleStatus.completed:
        return r'completed';
      case SaleStatus.refunded:
        return r'refunded';
      case SaleStatus.voided:
        return r'voided';
    }
  }
}

extension SaleStatusMapperExtension on SaleStatus {
  String toValue() {
    SaleStatusMapper.ensureInitialized();
    return MapperContainer.globals.toValue<SaleStatus>(this) as String;
  }
}

