/// Helpers for dashboard members pagination / prefetch.
library;

/// Whether [error] is Riverpod disposing an autoDispose provider mid-load.
///
/// Happens when silent prefetch uses `.future` and listeners drop before the
/// request completes (branch switch, filter change, widget dispose).
bool isProviderDisposedDuringLoading(Object error) {
  if (error is! StateError) return false;
  return error.message.contains('disposed during loading state');
}

/// Whether async work may still write into hook [ValueNotifier]s.
///
/// Prefetch must not touch notifiers after the section unmounts or after a
/// newer branch/filter/search generation supersedes this request.
bool canCommitDashboardMembersPrefetch({
  required int requestGeneration,
  required int currentGeneration,
  required bool isMounted,
}) {
  return isMounted && requestGeneration == currentGeneration;
}

/// After create/renew invalidates page 1, reset [loadedUpToPage] so the next
/// [AsyncData] reseeds the local list (otherwise updates are ignored once
/// page 1 has already been applied).
bool shouldResetLoadedPageForDashboardMembersRefresh({
  required bool isProviderLoading,
  required bool hasLoadedOnce,
}) {
  return isProviderLoading && hasLoadedOnce;
}

/// Whether [error] is using a disposed [ValueNotifier] / ChangeNotifier.
bool isUsedAfterDisposeError(Object error) {
  final message = error.toString();
  return message.contains('used after being disposed') ||
      message.contains('was used after being disposed');
}
