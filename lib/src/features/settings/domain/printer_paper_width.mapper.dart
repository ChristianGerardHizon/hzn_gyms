// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'printer_paper_width.dart';

class PrinterPaperWidthMapper extends EnumMapper<PrinterPaperWidth> {
  PrinterPaperWidthMapper._();

  static PrinterPaperWidthMapper? _instance;
  static PrinterPaperWidthMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PrinterPaperWidthMapper._());
    }
    return _instance!;
  }

  static PrinterPaperWidth fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  PrinterPaperWidth decode(dynamic value) {
    switch (value) {
      case r'mm58':
        return PrinterPaperWidth.mm58;
      case r'mm80':
        return PrinterPaperWidth.mm80;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(PrinterPaperWidth self) {
    switch (self) {
      case PrinterPaperWidth.mm58:
        return r'mm58';
      case PrinterPaperWidth.mm80:
        return r'mm80';
    }
  }
}

extension PrinterPaperWidthMapperExtension on PrinterPaperWidth {
  String toValue() {
    PrinterPaperWidthMapper.ensureInitialized();
    return MapperContainer.globals.toValue<PrinterPaperWidth>(this) as String;
  }
}

