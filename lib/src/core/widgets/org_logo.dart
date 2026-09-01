import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/organizations/presentation/controllers/organization_branding_providers.dart';
import '../assets/assets.gen.dart';

/// The current organization's transparent logo, falling back to the bundled
/// default app icon when unset/unresolved.
class OrgLogo extends ConsumerWidget {
  const OrgLogo({super.key, required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoUrl = ref.watch(effectiveLogoUrlProvider);

    final fallback = Assets.icons.appIconTransparent.image(
      width: width,
      height: height,
      fit: BoxFit.contain,
    );

    if (logoUrl == null || logoUrl.isEmpty) return fallback;

    return CachedNetworkImage(
      imageUrl: logoUrl,
      width: width,
      height: height,
      fit: BoxFit.contain,
      placeholder: (context, url) => fallback,
      errorWidget: (context, url, error) => fallback,
    );
  }
}
