// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'payment_method.dart';

class PaymentMethodMapper extends EnumMapper<PaymentMethod> {
  PaymentMethodMapper._();

  static PaymentMethodMapper? _instance;
  static PaymentMethodMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PaymentMethodMapper._());
    }
    return _instance!;
  }

  static PaymentMethod fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  PaymentMethod decode(dynamic value) {
    switch (value) {
      case r'cash':
        return PaymentMethod.cash;
      case r'card':
        return PaymentMethod.card;
      case r'bankTransfer':
        return PaymentMethod.bankTransfer;
      case r'check':
        return PaymentMethod.check;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(PaymentMethod self) {
    switch (self) {
      case PaymentMethod.cash:
        return r'cash';
      case PaymentMethod.card:
        return r'card';
      case PaymentMethod.bankTransfer:
        return r'bankTransfer';
      case PaymentMethod.check:
        return r'check';
    }
  }
}

extension PaymentMethodMapperExtension on PaymentMethod {
  String toValue() {
    PaymentMethodMapper.ensureInitialized();
    return MapperContainer.globals.toValue<PaymentMethod>(this) as String;
  }
}

