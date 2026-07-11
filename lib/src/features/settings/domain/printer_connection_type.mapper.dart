// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'printer_connection_type.dart';

class PrinterConnectionTypeMapper extends EnumMapper<PrinterConnectionType> {
  PrinterConnectionTypeMapper._();

  static PrinterConnectionTypeMapper? _instance;
  static PrinterConnectionTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PrinterConnectionTypeMapper._());
    }
    return _instance!;
  }

  static PrinterConnectionType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  PrinterConnectionType decode(dynamic value) {
    switch (value) {
      case r'bluetooth':
        return PrinterConnectionType.bluetooth;
      case r'network':
        return PrinterConnectionType.network;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(PrinterConnectionType self) {
    switch (self) {
      case PrinterConnectionType.bluetooth:
        return r'bluetooth';
      case PrinterConnectionType.network:
        return r'network';
    }
  }
}

extension PrinterConnectionTypeMapperExtension on PrinterConnectionType {
  String toValue() {
    PrinterConnectionTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<PrinterConnectionType>(this)
        as String;
  }
}

