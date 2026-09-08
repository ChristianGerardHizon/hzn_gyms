import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/organizations/presentation/controllers/organization_branding_providers.dart';
import 'org_logo.dart';

/// Firebase-style sidebar brand row: compact logo + prominent title text.
class AppBrandTitle extends ConsumerWidget {
  const AppBrandTitle({
    super.key,
    this.logoOnly = false,
    this.logoSize = 36,
  });

  /// When true, renders only the logo (e.g. collapsed sidebar).
  final bool logoOnly;

  /// Logo width/height in logical pixels.
  final double logoSize;

  static const double _titleFontSize = 22;
  static const double _logoGap = 12;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final title = ref.watch(effectiveAppTitleProvider);

    final logo = OrgLogo(width: logoSize, height: logoSize);

    if (logoOnly) {
      return logo;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        logo,
        const SizedBox(width: _logoGap),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: _titleFontSize,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.2,
              height: 1.15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
