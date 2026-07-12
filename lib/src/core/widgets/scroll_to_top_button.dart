import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Lower-right FAB that appears after [scrollController] scrolls past
/// [threshold], then animates back to the top on tap.
class ScrollToTopButton extends HookWidget {
  const ScrollToTopButton({
    required this.scrollController,
    this.threshold = 300,
    this.right = 16,
    this.bottom = 16,
    super.key,
  });

  final ScrollController scrollController;
  final double threshold;
  final double right;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    final visible = useState(false);

    useEffect(() {
      void listener() {
        if (!scrollController.hasClients) return;
        final shouldShow = scrollController.offset > threshold;
        if (visible.value != shouldShow) {
          visible.value = shouldShow;
        }
      }

      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, [scrollController, threshold]);

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
