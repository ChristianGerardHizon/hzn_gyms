import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'pocketbase_provider.dart';

part 'pb_connectivity_provider.g.dart';

/// Polls PocketBase `/api/health` to determine whether the server is reachable.
///
/// Returns `true` when online, `false` when offline.
/// Polls every 15s while online and every 5s while offline for faster recovery.
@Riverpod(keepAlive: true)
class PbConnectivity extends _$PbConnectivity {
  static const _onlineInterval = Duration(seconds: 15);
  static const _offlineInterval = Duration(seconds: 5);

  Timer? _timer;

  @override
  Future<bool> build() async {
    ref.onDispose(() => _timer?.cancel());

    final online = await _checkHealth();
    _scheduleNext(online);
    return online;
  }

  /// Forces an immediate health check and reschedules the poll timer.
  Future<void> checkNow() async {
    final online = await _checkHealth();
    state = AsyncData(online);
    _scheduleNext(online);
  }

  Future<bool> _checkHealth() async {
    try {
      final result = await ref.read(pocketbaseProvider).health.check();
      return result.code == 200;
    } catch (_) {
      return false;
    }
  }

  void _scheduleNext(bool online) {
    _timer?.cancel();
    _timer = Timer(
      online ? _onlineInterval : _offlineInterval,
      () async {
        final next = await _checkHealth();
        state = AsyncData(next);
        _scheduleNext(next);
      },
    );
  }
}
