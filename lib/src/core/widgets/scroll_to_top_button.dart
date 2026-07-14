import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Lower-right FAB that appears after [scrollController] scrolls past
/// [threshold] (or past [anchorKey]'s laid-out height), then animates
/// back to the top on tap.
///
/// Prefer [anchorKey] when the content above the fold can change height
/// (e.g. collapsible dashboard sections) so visibility stays in sync.
class ScrollToTopButton extends HookWidget {
  const ScrollToTopButton({
    required this.scrollController,
    this.threshold = 300,
    this.anchorKey,
    this.right = 16,
    this.bottom = 16,
    super.key,
  });

  final ScrollController scrollController;

  /// Fallback when [anchorKey] is null or not laid out yet.
  final double threshold;

  /// When set, the button shows after this widget has scrolled out of view.
  /// Height is read on each scroll so layout changes are accounted for.
  final GlobalKey? anchorKey;

  final double right;
  final double bottom;

  double _resolveThreshold() {
    final key = anchorKey;
    if (key != null) {
      final box = key.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize && box.size.height > 0) {
        return box.size.height;
      }
    }
    return threshold;
  }

  @override
  Widget build(BuildContext context) {
    final visible = useState(false);

    useEffect(() {
      void updateVisibility() {
        if (!scrollController.hasClients) return;
        final shouldShow = scrollController.offset > _resolveThreshold();
        if (visible.value != shouldShow) {
          visible.value = shouldShow;
        }
      }

      scrollController.addListener(updateVisibility);
      WidgetsBinding.instance.addPostFrameCallback((_) => updateVisibility());
      return () => scrollController.removeListener(updateVisibility);
    }, [scrollController, threshold, anchorKey]);

    return Positioned(
      right: right,
      bottom: bottom,
      child: IgnorePointer(
        ignoring: !visible.value,
        child: AnimatedScale(
          scale: visible.value ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: visible.value ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: FloatingActionButton.small(
              heroTag: 'scrollToTop',
              tooltip: 'Scroll to top',
              onPressed: () {
                scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                );
              },
              child: const Icon(Icons.keyboard_arrow_up),
            ),
          ),
        ),
      ),
    );
  }
}
