// services/garden_audio_service.dart

import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class GardenAudioService {
  static final GardenAudioService _instance = GardenAudioService._internal();
  factory GardenAudioService() => _instance;
  GardenAudioService._internal();

  AudioPlayer? _ambientPlayer;
  String? _currentSound;
  bool _isEnabled = true;
  double _volume = 0.3; // 默認音量

  static const Map<String, String> _soundAssets = {
    'gentle_stream': 'audio/gentle_stream.mp3',
    'soft_rain': 'audio/soft_rain.mp3',
    'forest_birds': 'audio/forest_birds.mp3',
    'cheerful_birds': 'audio/cheerful_birds.mp3',
    'evening_crickets': 'audio/evening_crickets.mp3',
    'nature_ambient': 'audio/nature_ambient.mp3',
  };



  /// 檢查是否啟用音量
  bool get isEnabled => _isEnabled;
  String? get currentSound => _currentSound;

  /// 當前音量 (0.0 - 1.0)
  double get volume => _volume;

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (!enabled) {
      stop();
    }
  }

  void setVolume(double vol) {
    _volume = vol.clamp(0.0, 1.0);
    _ambientPlayer?.setVolume(_volume);
  }

  Future<void> playAmbientSound(String? soundName) async {
    if (!_isEnabled || soundName == null || soundName.isEmpty) {
      await stop();
      return;
    }

    if (_currentSound == soundName) return;

    final assetPath = _soundAssets[soundName];
    if (assetPath == null) {
      if (kDebugMode) {
        debugPrint('🎵 GardenAudio: Unknown sound "$soundName", skipping');
      }
      return;
    }

    try {
      await stop();

      _ambientPlayer = AudioPlayer();
      _ambientPlayer!.setReleaseMode(ReleaseMode.loop);
      _ambientPlayer!.setVolume(_volume);

      await _ambientPlayer!.play(AssetSource(assetPath));
      _currentSound = soundName;

      if (kDebugMode) {
        debugPrint('🎵 GardenAudio: Playing "$soundName" (${assetPath})');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ GardenAudio: Failed to play "$soundName": $e');
        debugPrint('   Make sure the audio file exists at assets/$assetPath');
      }
      _currentSound = null;
    }
  }
  Future<void> playWithFadeIn(String? soundName, {
    Duration fadeDuration = const Duration(milliseconds: 1500),
  }) async {
    if (!_isEnabled || soundName == null) {
      await stop();
      return;
    }

    if (_currentSound == soundName) return;

    final targetVolume = _volume;
    _volume = 0.0;

    await playAmbientSound(soundName);

    // 逐步提高音量
    if (_ambientPlayer != null) {
      const steps = 15;
      final stepDuration = fadeDuration ~/ steps;
      final stepVolume = targetVolume / steps;

      for (int i = 1; i <= steps; i++) {
        await Future.delayed(stepDuration);
        if (_currentSound != soundName) break; // 如果已经切换到其他音效，停止淡入
        _volume = (stepVolume * i).clamp(0.0, targetVolume);
        _ambientPlayer?.setVolume(_volume);
      }
      _volume = targetVolume;
    }
  }

  Future<void> stop() async {
    try {
      await _ambientPlayer?.stop();
      await _ambientPlayer?.dispose();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🎵 GardenAudio: Error stopping player: $e');
      }
    }
    _ambientPlayer = null;
    _currentSound = null;
  }

  Future<void> stopWithFadeOut({
    Duration fadeDuration = const Duration(milliseconds: 800),
  }) async {
    if (_ambientPlayer == null) return;

    final startVolume = _volume;
    const steps = 10;
    final stepDuration = fadeDuration ~/ steps;
    final stepVolume = startVolume / steps;

    for (int i = steps - 1; i >= 0; i--) {
      await Future.delayed(stepDuration);
      _ambientPlayer?.setVolume((stepVolume * i).clamp(0.0, 1.0));
    }

    await stop();
    _volume = startVolume;
  }

  Future<void> pause() async {
    await _ambientPlayer?.pause();
  }

  Future<void> resume() async {
    await _ambientPlayer?.resume();
  }

  Future<void> dispose() async {
    await stop();
  }
}