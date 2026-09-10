import 'package:flutter/material.dart';

import '../assets/assets.gen.dart';
import '../utils/breakpoints.dart';

/// Branded 404 screen used when a route cannot be resolved.
///
/// Layout scales for mobile, tablet, and desktop: larger type and logo on
/// wide screens, full-width primary action on compact widths.
class PageNotFoundPage extends StatelessWidget {
  const PageNotFoundPage({
    super.key,
    required this.onGoHome,
    this.attemptedPath,
  });

  /// Navigates the user to the resolved home route.
  final VoidCallback onGoHome;

  /// Optional unmatched path shown as secondary context.
  final String? attemptedPath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < Breakpoints.mobile;
    final isDesktop = width >= Breakpoints.desktop;

    final codeStyle = theme.textTheme.displayLarge?.copyWith(
      fontSize: isDesktop
          ? 112
          : isMobile
          ? 64
          : 88,
      fontWeight: FontWeight.w700,
      height: 1,
      letterSpacing: -2,
      color: colors.onSurface,
    );
    final logoSize = isMobile ? 56.0 : 72.0;
    final maxContentWidth = isDesktop ? 520.0 : 440.0;
    final horizontalPadding = isMobile ? 24.0 : 40.0;
    final canPop = Navigator.of(context).canPop();
    final path = attemptedPath?.trim();
    final showPath = path != null && path.isNotEmpty && path != '/';

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.surface,
              Color.lerp(
                    colors.surface,
                    colors.primaryContainer,
                    0.22,
                  ) ??
                  colors.surface,
              colors.surface,
            ],
            stops: const [0, 0.45, 1],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: _GlowOrb(
                size: isMobile ? 180 : 260,
                color: colors.primary.withValues(alpha: 0.12),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: _GlowOrb(
                size: isMobile ? 200 : 300,
                color: colors.tertiary.withValues(alpha: 0.1),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 32,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Assets.icons.appIconTransparent.image(
                          width: logoSize,
                          height: logoSize,
                        ),
                        SizedBox(height: isMobile ? 28 : 36),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.primaryContainer.withValues(
                              alpha: 0.55,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(isMobile ? 16 : 20),
                            child: Icon(
                              Icons.explore_off_outlined,
                              size: isMobile ? 36 : 44,
                              color: colors.onPrimaryContainer,
                            ),
                          ),
                        ),
                        SizedBox(height: isMobile ? 20 : 28),
                        Text('404', style: codeStyle, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        Text(
                          'Page not found',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "The page you're looking for doesn't exist or may "
                          'have been moved.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colors.onSurfaceVariant,
                            height: 1.45,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (showPath) ...[
                          const SizedBox(height: 16),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHighest.withValues(
                                alpha: 0.7,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: colors.outlineVariant.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Text(
                                path,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontFamily: 'monospace',
                                  color: colors.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: isMobile ? 28 : 36),
                        SizedBox(
                          width: isMobile ? double.infinity : null,
                          child: FilledButton.icon(
                            onPressed: onGoHome,
                            style: FilledButton.styleFrom(
                              minimumSize: Size(
                                isMobile ? double.infinity : 200,
                                48,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                            ),
                            icon: const Icon(Icons.home_outlined),
                            label: const Text('Go Home'),
                          ),
                        ),
                        if (canPop) ...[
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            child: const Text('Go Back'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        child: SizedBox(width: size, height: size),
      ),
    );
  }
}
