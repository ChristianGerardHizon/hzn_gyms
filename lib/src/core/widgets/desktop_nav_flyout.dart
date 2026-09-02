import 'package:flutter/material.dart';

import '../i18n/strings.g.dart';
import '../navigation/app_nav_destination.dart';
import '../navigation/app_nav_presentation.dart';
import 'desktop_nav_item.dart';

/// Hover/tap flyout panel listing destinations within a sidebar category.
class DesktopNavFlyout extends StatelessWidget {
  const DesktopNavFlyout({
    super.key,
    required this.category,
    required this.destinations,
    required this.location,
    required this.onDestinationTap,
  });

  final AppNavCategory category;
  final List<AppNavDestination> destinations;
  final String location;
  final ValueChanged<AppNavDestination> onDestinationTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = Translations.of(context);

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: colorScheme.surfaceContainerHigh,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 220, maxWidth: 280),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  appNavCategoryLabel(category, t),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              for (final dest in destinations)
                _FlyoutItem(
                  icon: appNavIcon(
                    dest.id,
                    selected: isNavDestinationSelected(
                      location,
                      dest.id,
                      destinations,
                    ),
                  ),
                  label: appNavLabel(dest.id, t),
                  selected: isNavDestinationSelected(
                    location,
                    dest.id,
                    destinations,
                  ),
                  onTap: () => onDestinationTap(dest),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlyoutItem extends StatelessWidget {
  const _FlyoutItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: selected ? colorScheme.secondaryContainer : null,
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: selected
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onSurface,
                    fontWeight: selected ? FontWeight.w600 : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Category row that opens [DesktopNavFlyout] on hover (expanded) or tap (collapsed).
class DesktopNavCategoryRow extends StatefulWidget {
  const DesktopNavCategoryRow({
    super.key,
    required this.category,
    required this.destinations,
    required this.location,
    required this.selected,
    required this.collapsed,
    required this.onDestinationTap,
  });

  final AppNavCategory category;
  final List<AppNavDestination> destinations;
  final String location;
  final bool selected;
  final bool collapsed;
  final ValueChanged<AppNavDestination> onDestinationTap;

  @override
  State<DesktopNavCategoryRow> createState() => _DesktopNavCategoryRowState();
}

class _DesktopNavCategoryRowState extends State<DesktopNavCategoryRow> {
  final _anchorKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isHovered = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    if (_overlayEntry != null || widget.destinations.isEmpty) return;

    final renderBox =
        _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final overlay = Overlay.of(context);
    final anchorOffset = renderBox.localToGlobal(Offset.zero);
    final anchorSize = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _hideOverlay,
            ),
          ),
          Positioned(
            left: anchorOffset.dx + anchorSize.width + 4,
            top: anchorOffset.dy,
            child: MouseRegion(
              onEnter: (_) => _isHovered = true,
              onExit: (_) {
                _isHovered = false;
                Future<void>.delayed(const Duration(milliseconds: 120), () {
                  if (!_isHovered && mounted) _hideOverlay();
                });
              },
              child: DesktopNavFlyout(
                category: widget.category,
                destinations: widget.destinations,
                location: widget.location,
                onDestinationTap: (dest) {
                  _hideOverlay();
                  widget.onDestinationTap(dest);
                },
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _removeOverlay();
    setState(() => _isHovered = false);
  }

  void _onHoverEnter() {
    if (widget.collapsed) return;
    _isHovered = true;
    _showOverlay();
  }

  void _onHoverExit() {
    if (widget.collapsed) return;
    _isHovered = false;
    Future<void>.delayed(const Duration(milliseconds: 120), () {
      if (!_isHovered && mounted) _hideOverlay();
    });
  }

  void _onTap() {
    if (widget.collapsed) {
      _showOverlay();
      return;
    }
    if (_overlayEntry == null) {
      _showOverlay();
    } else {
      _hideOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final label = appNavCategoryLabel(widget.category, t);

    return MouseRegion(
      onEnter: (_) => _onHoverEnter(),
      onExit: (_) => _onHoverExit(),
      child: KeyedSubtree(
        key: _anchorKey,
        child: DesktopNavItem(
          icon: appNavCategoryIcon(widget.category),
          label: label,
          selected: widget.selected,
          onTap: _onTap,
          collapsed: widget.collapsed,
          trailing: widget.collapsed
              ? null
              : Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
        ),
      ),
    );
  }
}
