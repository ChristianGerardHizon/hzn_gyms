// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'app_theme_mode.dart';

class AppThemeModeMapper extends EnumMapper<AppThemeMode> {
  AppThemeModeMapper._();

  static AppThemeModeMapper? _instance;
  static AppThemeModeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AppThemeModeMapper._());
    }
    return _instance!;
  }

  static AppThemeMode fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  AppThemeMode decode(dynamic value) {
    switch (value) {
      case r'light':
        return AppThemeMode.light;
      case r'dark':
        return AppThemeMode.dark;
      case r'system':
        return AppThemeMode.system;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(AppThemeMode self) {
    switch (self) {
      case AppThemeMode.light:
        return r'light';
      case AppThemeMode.dark:
        return r'dark';
      case AppThemeMode.system:
        return r'system';
    }
  }
}

extension AppThemeModeMapperExtension on AppThemeMode {
  String toValue() {
    AppThemeModeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<AppThemeMode>(this) as String;
  }
}

