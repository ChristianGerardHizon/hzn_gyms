import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pending_redirect_provider.g.dart';

/// Eager deep-link stash that does not touch Riverpod listener state.
///
/// GoRouter [redirect] may run during widget/provider build, where updating a
/// Notifier is unsafe. [PendingRedirect.stash] records the URL immediately so
/// splash restore cannot race a deferred [PendingRedirect.set].
String? _stashedPendingRedirect;

/// Stores the URL user intended to visit before auth resolved.
///
/// Used to redirect back after successful authentication on web,
/// where users can directly access deep links.
@Riverpod(keepAlive: true)
class PendingRedirect extends _$PendingRedirect {
  @override
  String? build() => _stashedPendingRedirect;

  /// Record [url] immediately without notifying Riverpod listeners.
  ///
  /// Safe to call from GoRouter redirect during build.
  static void stash(String url) {
    _stashedPendingRedirect = url;
  }

  /// Clears the eager stash. Used by tests and [clear]/[consume].
  static void clearStash() {
    _stashedPendingRedirect = null;
  }

  /// Set the pending redirect URL (updates Riverpod state + stash).
  void set(String url) {
    _stashedPendingRedirect = url;
    state = url;
  }

  /// Clear the pending redirect URL.
  void clear() {
    _stashedPendingRedirect = null;
    state = null;
  }

  /// Pending URL from Riverpod state or eager stash.
  String? peek() => state ?? _stashedPendingRedirect;

  /// Clear and return the pending redirect URL.
  String? consume() {
    final url = peek();
    _stashedPendingRedirect = null;
    state = null;
    return url;
  }
}
