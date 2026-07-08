// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_info_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides app package information (version, build number, etc.).
///
/// Uses package_info_plus to get the actual values from pubspec.yaml.

@ProviderFor(appInfo)
final appInfoProvider = AppInfoProvider._();

/// Provides app package information (version, build number, etc.).
///
/// Uses package_info_plus to get the actual values from pubspec.yaml.

final class AppInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<PackageInfo>,
          PackageInfo,
          FutureOr<PackageInfo>
        >
    with $FutureModifier<PackageInfo>, $FutureProvider<PackageInfo> {
  /// Provides app package information (version, build number, etc.).
  ///
  /// Uses package_info_plus to get the actual values from pubspec.yaml.
  AppInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appInfoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appInfoHash();

  @$internal
  @override
  $FutureProviderElement<PackageInfo> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PackageInfo> create(Ref ref) {
    return appInfo(ref);
  }
}

String _$appInfoHash() => r'7b1df52ff753fa06cd37655f821d8572004c9aad';
