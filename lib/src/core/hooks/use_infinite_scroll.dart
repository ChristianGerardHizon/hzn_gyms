import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Custom hook for infinite scroll detection.
///
/// Returns a ScrollController that triggers [onLoadMore] when the user
/// scrolls near the bottom of the list.
///
/// Example:
/// ```dart
/// final scrollController = useInfiniteScroll(
///   onLoadMore: () => ref.read(controllerProvider.notifier).loadMore(),
///   hasMore: paginatedState.hasMore,
///   isLoading: paginatedState.isLoadingMore,
/// );
/// ```
ScrollController useInfiniteScroll({
  required VoidCallback onLoadMore,
  required bool hasMore,
  required bool isLoading,
  double threshold = 200.0,
  int? itemCount,
}) {
  final scrollController = useScrollController();

  useEffect(() {
    void checkAndLoad() {
      if (isLoading || !hasMore) return;
      if (!scrollController.hasClients) return;

      final position = scrollController.position;
      // Post-frame / early listeners can run before dimensions attach;
      // maxScrollExtent uses `!` and throws (EBEGYM-4 / EBEGYM-9).
      if (!position.hasContentDimensions) return;

      final remaining = position.maxScrollExtent - position.pixels;

      if (remaining <= threshold) {
        onLoadMore();
      }
    }

    void listener() => checkAndLoad();

    scrollController.addListener(listener);

    // When the first page does not fill the viewport, no scroll events fire.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      checkAndLoad();
    });

    return () => scrollController.removeListener(listener);
  }, [hasMore, isLoading, itemCount]);

  return scrollController;
}
