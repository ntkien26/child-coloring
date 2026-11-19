import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  bool _muted = false;
  bool _initialized = false;

  bool get isMuted => _muted;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      await FlameAudio.audioCache.loadAll([
        'pop.wav',
        'sparkle.wav',
        'theme_switch.wav',
        'erase.wav',
      ]);
    } catch (e) {
      debugPrint('Audio preload skipped: $e');
    }
  }

  void setMuted(bool muted) {
    _muted = muted;
  }

  Future<void> playPop() => _playSafe('pop.wav', volume: 0.7);
  Future<void> playSparkle() => _playSafe('sparkle.wav', volume: 0.8);
  Future<void> playThemeSwitch() => _playSafe('theme_switch.wav', volume: 0.65);
  Future<void> playErase() => _playSafe('erase.wav', volume: 0.6);

  Future<void> _playSafe(String fileName, {double volume = 0.7}) async {
    if (_muted || !_initialized) return;
    try {
      await FlameAudio.play(fileName, volume: volume);
    } catch (e) {
      debugPrint('Audio play skipped ($fileName): $e');
    }
  }
}
