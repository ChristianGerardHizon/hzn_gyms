import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Debug-only performance timer that logs checkpoints with elapsed ms.
///
/// Logs appear in the console / DevTools under the `Perf` logger name.
class PerfTimer {
  PerfTimer(this.label) : _start = DateTime.now() {
    if (kDebugMode) {
      developer.log('START', name: 'Perf/$label');
      _lastCheckpoint = _start;
    }
  }

  final String label;
  final DateTime _start;
  DateTime? _lastCheckpoint;

  /// Logs elapsed time since the previous checkpoint (or start).
  void checkpoint(String stage) {
    if (!kDebugMode) return;
    final now = DateTime.now();
    final fromStart = now.difference(_start).inMilliseconds;
    final fromLast = now.difference(_lastCheckpoint!).inMilliseconds;
    _lastCheckpoint = now;
    developer.log(
      '$stage (+${fromLast}ms, total ${fromStart}ms)',
      name: 'Perf/$label',
    );
  }

  /// Logs the final total elapsed time.
  void finish([String stage = 'DONE']) {
    if (!kDebugMode) return;
    final total = DateTime.now().difference(_start).inMilliseconds;
    developer.log('$stage (total ${total}ms)', name: 'Perf/$label');
  }
}
