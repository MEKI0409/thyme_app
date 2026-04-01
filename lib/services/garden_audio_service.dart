// services/garden_audio_service.dart
// 🎵 花园环境音效服务
// 根据情绪播放不同的环境音：鸟叫声、雨声、溪流声等
//
// ⚠️ 使用前需要:
// 1. pubspec.yaml 添加依赖: audioplayers: ^6.0.0
// 2. 添加音频文件到 assets/audio/ 目录
// 3. pubspec.yaml 注册 assets:
//    flutter:
//      assets:
//        - assets/audio/

import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class GardenAudioService {
  static final GardenAudioService _instance = GardenAudioService._internal();
  factory GardenAudioService() => _instance;
  GardenAudioService._internal();

  AudioPlayer? _ambientPlayer;
  String? _currentSound;
  bool _isEnabled = true;
  double _volume = 0.3; // 默认较低音量，营造背景氛围

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎵 音频资源映射 - ambientSound 名称 → 音频文件路径
  // ═══════════════════════════════════════════════════════════════════════════
  static const Map<String, String> _soundAssets = {
    'gentle_stream': 'audio/gentle_stream.mp3',     // 焦虑 → 溪流声
    'soft_rain': 'audio/soft_rain.mp3',              // 悲伤 → 轻柔雨声
    'forest_birds': 'audio/forest_birds.mp3',        // 压力 → 森林鸟叫
    'cheerful_birds': 'audio/cheerful_birds.mp3',    // 开心 → 欢快鸟叫
    'evening_crickets': 'audio/evening_crickets.mp3', // 平静 → 夜晚蟋蟀
    'nature_ambient': 'audio/nature_ambient.mp3',    // 默认 → 自然环境音
  };

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔊 公共 API
  // ═══════════════════════════════════════════════════════════════════════════

  /// 是否启用音效
  bool get isEnabled => _isEnabled;

  /// 当前播放的音效名称
  String? get currentSound => _currentSound;

  /// 当前音量 (0.0 - 1.0)
  double get volume => _volume;

  /// 启用/禁用音效
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (!enabled) {
      stop();
    }
  }

  /// 设置音量
  void setVolume(double vol) {
    _volume = vol.clamp(0.0, 1.0);
    _ambientPlayer?.setVolume(_volume);
  }

  /// 根据 ambientSound 名称播放对应的环境音
  /// 这是与 MoodResponsiveGardenService.GardenAmbiance.ambientSound 对接的方法
  Future<void> playAmbientSound(String? soundName) async {
    if (!_isEnabled || soundName == null || soundName.isEmpty) {
      await stop();
      return;
    }

    // 如果已经在播放相同的音效，不重复启动
    if (_currentSound == soundName) return;

    final assetPath = _soundAssets[soundName];
    if (assetPath == null) {
      if (kDebugMode) {
        debugPrint('🎵 GardenAudio: Unknown sound "$soundName", skipping');
      }
      return;
    }

    try {
      // 停止当前播放
      await stop();

      // 创建新的播放器
      _ambientPlayer = AudioPlayer();
      _ambientPlayer!.setReleaseMode(ReleaseMode.loop); // 循环播放
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

  /// 带淡入效果播放（更柔和的过渡）
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

  /// 停止播放
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

  /// 带淡出效果停止
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
    _volume = startVolume; // 恢复原始音量设置
  }

  /// 暂停播放（保留状态，可恢复）
  Future<void> pause() async {
    await _ambientPlayer?.pause();
  }

  /// 恢复播放
  Future<void> resume() async {
    await _ambientPlayer?.resume();
  }

  /// 释放资源（在 dispose 时调用）
  Future<void> dispose() async {
    await stop();
  }
}