import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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

    if (imageUrl == null || imageUrl!.isEmpty) {
      return onTap != null
          ? GestureDetector(onTap: onTap, child: placeholderWidget)
          : placeholderWidget;
    }

    final avatar = CachedNetworkImage(
      imageUrl: imageUrl!,
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
class CachedImage extends StatelessWidget {
  const CachedImage({
    super.key,
    this.imageUrl,
    this.placeholder,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  /// The URL of the image to display. If null, shows the placeholder.
  final String? imageUrl;

  /// Custom placeholder widget. If null, uses a default container with
  /// the app icon.
  final Widget? placeholder;

  /// Optional border radius for the image.
  final BorderRadius? borderRadius;

  /// How the image should fit within its bounds. Defaults to [BoxFit.cover].
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final placeholderWidget = placeholder ??
        Container(
          color: theme.colorScheme.primaryContainer,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Image.asset(
                'assets/icons/app_icon_transparent.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        );

    if (imageUrl == null || imageUrl!.isEmpty) {
      return placeholderWidget;
    }

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Container(
        color: theme.colorScheme.surfaceContainerHighest,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Image.asset(
              'assets/icons/app_icon_transparent.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
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
