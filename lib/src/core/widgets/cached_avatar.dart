import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/organizations/presentation/controllers/organization_branding_providers.dart';

/// A reusable cached avatar widget that displays an image from a URL
/// with a customizable placeholder.
///
/// Uses [CachedNetworkImage] for efficient disk/memory caching.
class CachedAvatar extends StatelessWidget {
  const CachedAvatar({
    super.key,
    this.imageUrl,
    this.radius = 20,
    this.placeholder,
    this.placeholderIcon = Icons.person,
    this.onTap,
    this.thumbSize,
  });

  /// The URL of the image to display. If null, shows the placeholder.
  final String? imageUrl;

  /// The radius of the avatar. Defaults to 20.
  final double radius;

  /// Custom placeholder widget. If null, uses a default CircleAvatar
  /// with [placeholderIcon].
  final Widget? placeholder;

  /// The icon to show in the default placeholder. Defaults to [Icons.person].
  final IconData placeholderIcon;

  /// Optional callback when the avatar is tapped.
  final VoidCallback? onTap;

  /// When set, requests a PocketBase server-side thumbnail of this pixel size
  /// (square) instead of the full-resolution image. This dramatically reduces
  /// download size for small avatars in lists.
  final int? thumbSize;

  /// Builds the effective image URL, appending a PocketBase `thumb=WxH`
  /// query parameter when [thumbSize] is provided.
  String? _resolveImageUrl() {
    final url = imageUrl;
    if (url == null || url.isEmpty) return null;
    final size = thumbSize;
    if (size == null) return url;
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}thumb=${size}x$size';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final defaultPlaceholder = CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Icon(
        placeholderIcon,
        size: radius,
        color: theme.colorScheme.primary,
      ),
    );

    final placeholderWidget = placeholder ?? defaultPlaceholder;

    final resolvedUrl = _resolveImageUrl();

    if (resolvedUrl == null) {
      return onTap != null
          ? GestureDetector(onTap: onTap, child: placeholderWidget)
          : placeholderWidget;
    }

    // Decode to roughly 2x the display size for crisp rendering on hi-dpi
    // screens while keeping memory usage low.
    final memCacheSize =
        thumbSize != null ? thumbSize! * 2 : (radius * 2 * 3).round();

    final avatar = CachedNetworkImage(
      imageUrl: resolvedUrl,
      memCacheWidth: memCacheSize,
      memCacheHeight: memCacheSize,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          placeholderIcon,
          size: radius,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      errorWidget: (context, url, error) => placeholderWidget,
    );

    return onTap != null ? GestureDetector(onTap: onTap, child: avatar) : avatar;
  }
}

/// A reusable cached image widget that displays a rectangular image from a URL
/// with a customizable placeholder.
///
/// Unlike [CachedAvatar] which renders a circle, this renders a rectangular
/// image that fills its parent using [BoxFit.cover].
///
/// Uses [CachedNetworkImage] for efficient disk/memory caching.
class CachedImage extends ConsumerWidget {
  const CachedImage({
    super.key,
    this.imageUrl,
    this.placeholder,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  /// The URL of the image to display. If null, shows the placeholder.
  final String? imageUrl;

  /// Custom placeholder widget. If null, uses the current organization's
  /// transparent logo (see [effectiveLogoUrlProvider]).
  final Widget? placeholder;

  /// Optional border radius for the image.
  final BorderRadius? borderRadius;

  /// How the image should fit within its bounds. Defaults to [BoxFit.cover].
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgLogoUrl = ref.watch(effectiveLogoUrlProvider);

    final placeholderWidget = placeholder ??
        _OrgLogoImagePlaceholder(logoUrl: orgLogoUrl);

    if (imageUrl == null || imageUrl!.isEmpty) {
      return placeholderWidget;
    }

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => _OrgLogoImagePlaceholder(
        logoUrl: orgLogoUrl,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      errorWidget: (context, url, error) => placeholderWidget,
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }
}

/// Default [CachedImage] placeholder — organization logo when configured,
/// otherwise a person icon.
class _OrgLogoImagePlaceholder extends StatelessWidget {
  const _OrgLogoImagePlaceholder({
    required this.logoUrl,
    this.backgroundColor,
  });

  final String? logoUrl;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = logoUrl;

    return Container(
      color: backgroundColor ?? theme.colorScheme.primaryContainer,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final logoSize = constraints.biggest.shortestSide * 0.72;

          return Center(
            child: SizedBox(
              width: logoSize,
              height: logoSize,
              child: url != null && url.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => _iconFallback(theme, logoSize * 0.55),
                      errorWidget: (_, __, ___) =>
                          _iconFallback(theme, logoSize * 0.55),
                    )
                  : _iconFallback(theme, logoSize * 0.55),
            ),
          );
        },
      ),
    );
  }

  Widget _iconFallback(ThemeData theme, double size) {
    return Icon(
      Icons.person,
      size: size,
      color: theme.colorScheme.primary,
    );
  }
}
