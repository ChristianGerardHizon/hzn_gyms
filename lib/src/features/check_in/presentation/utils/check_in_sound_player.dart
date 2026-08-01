import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../../domain/check_in_chime.dart';

/// Plays short check-in outcome chimes from bundled assets.
///
/// Failures are swallowed so UI never blocks on audio.
class CheckInSoundPlayer {
  CheckInSoundPlayer._();

  static final AudioPlayer _player = AudioPlayer();

  static const _assetByChime = {
    CheckInChime.success: 'sounds/check_in_success.wav',
    CheckInChime.nearExpiry: 'sounds/check_in_near_expiry.wav',
    CheckInChime.failure: 'sounds/check_in_failure.wav',
  };

  /// Plays [chime] without awaiting completion.
  static void play(CheckInChime chime) {
    unawaited(_play(chime));
  }

  static Future<void> _play(CheckInChime chime) async {
    final asset = _assetByChime[chime];
    if (asset == null) return;
    try {
      await _player.stop();
      await _player.play(AssetSource(asset));
    } catch (e, st) {
      debugPrint('CheckInSoundPlayer: failed to play $chime: $e\n$st');
    }
  }
}
