// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/app_icon.png
  AssetGenImage get appIcon => const AssetGenImage('assets/icons/app_icon.png');

  /// File path: assets/icons/app_icon_mac.png
  AssetGenImage get appIconMac =>
      const AssetGenImage('assets/icons/app_icon_mac.png');

  /// File path: assets/icons/app_icon_mark.png
  AssetGenImage get appIconMark =>
      const AssetGenImage('assets/icons/app_icon_mark.png');

  /// File path: assets/icons/app_icon_mark_opaque.png
  AssetGenImage get appIconMarkOpaque =>
      const AssetGenImage('assets/icons/app_icon_mark_opaque.png');

  /// File path: assets/icons/app_icon_transparent.png
  AssetGenImage get appIconTransparent =>
      const AssetGenImage('assets/icons/app_icon_transparent.png');

  /// File path: assets/icons/hzn_systems_logo.jpg
  AssetGenImage get hznSystemsLogoJpg =>
      const AssetGenImage('assets/icons/hzn_systems_logo.jpg');

  /// File path: assets/icons/hzn_systems_logo.png
  AssetGenImage get hznSystemsLogoPng =>
      const AssetGenImage('assets/icons/hzn_systems_logo.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    appIcon,
    appIconMac,
    appIconMark,
    appIconMarkOpaque,
    appIconTransparent,
    hznSystemsLogoJpg,
    hznSystemsLogoPng,
  ];
}

class $AssetsSoundsGen {
  const $AssetsSoundsGen();

  /// File path: assets/sounds/check_in_failure.wav
  String get checkInFailure => 'assets/sounds/check_in_failure.wav';

  /// File path: assets/sounds/check_in_near_expiry.wav
  String get checkInNearExpiry => 'assets/sounds/check_in_near_expiry.wav';

  /// File path: assets/sounds/check_in_success.wav
  String get checkInSuccess => 'assets/sounds/check_in_success.wav';

  /// List of all assets
  List<String> get values => [
    checkInFailure,
    checkInNearExpiry,
    checkInSuccess,
  ];
}

abstract final class Assets {
  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsSoundsGen sounds = $AssetsSoundsGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
