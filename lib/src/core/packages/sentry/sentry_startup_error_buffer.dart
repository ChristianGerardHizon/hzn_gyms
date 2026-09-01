import 'package:sentry_flutter/sentry_flutter.dart';

/// Holds errors that occur before [SentryFlutter.init] has bound a DSN.
///
/// [Sentry.runZonedGuarded] only reports once the hub is configured. First-paint
/// failures would otherwise be dropped if `runApp` runs before init completes.
class SentryStartupErrorBuffer {
  SentryStartupErrorBuffer({SentryExceptionCapture? capture})
    : _capture = capture ?? _defaultCapture;

  final SentryExceptionCapture _capture;
  final List<(Object, StackTrace)> _pending = [];
  var _ready = false;

  /// Whether init has finished and the buffer will no longer queue.
  bool get isReady => _ready;

  /// Errors waiting to be flushed. Empty after [markReadyAndFlush].
  List<(Object, StackTrace)> get pending => List.unmodifiable(_pending);

  /// Queues [error] until Sentry is ready. After ready, the SDK zone already
  /// captures, so this is a no-op.
  void add(Object error, StackTrace stackTrace) {
    if (_ready) return;
    _pending.add((error, stackTrace));
  }

  /// Marks the hub as live and sends any queued first-paint errors.
  Future<void> markReadyAndFlush() async {
    _ready = true;
    final toFlush = List<(Object, StackTrace)>.from(_pending);
    _pending.clear();
    for (final entry in toFlush) {
      await _capture(entry.$1, entry.$2);
    }
  }
}

typedef SentryExceptionCapture =
    Future<void> Function(Object error, StackTrace stackTrace);

Future<void> _defaultCapture(Object error, StackTrace stackTrace) async {
  await Sentry.captureException(error, stackTrace: stackTrace);
}
