// controllers/garden_controller.dart
// ✅ FIXED: 统一奖励逻辑，移除重复的 rewardHabitCompletion 和 addHabitReward
// ✅ FIXED: 使用 Constants.calculateHabitReward 统一计算
// ✅ FIXED: addHabitReward 中 _userId 为 null 时提前返回，避免传空字符串
// ✅ FIXED (v2): rest bonus 写入 Firestore 防止重复发放
// ✅ FIXED (v2): rewardHabitCompletion 增加 isRewardedToday 检查

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/garden_model.dart';
import '../models/habit_model.dart';
import '../services/gemini_service.dart';
import '../services/mood_responsive_garden_service.dart';
import '../services/welcome_back_service.dart';
import '../utils/constants.dart';

class GardenController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GeminiService _geminiService = GeminiService();
  final MoodResponsiveGardenService _ambianceService = MoodResponsiveGardenService();
  final WelcomeBackService _welcomeService = WelcomeBackService();

  GardenState? _gardenState;
  String? _userId;
  String? _currentMood;
  GardenAmbiance? _currentAmbiance;
  bool _isLoading = false;
  DateTime? _lastVisit;

  GardenState get gardenState => _gardenState ?? _getDefaultGardenState();
  String? get currentMood => _currentMood;
  GardenAmbiance? get currentAmbiance => _currentAmbiance;
  bool get isLoading => _isLoading;
  DateTime? get lastVisit => _lastVisit;

  /// ✅ NEW: 暴露 userId 用于外部检查
  String? get userId => _userId;

  int get daysSinceLastVisit {
    if (_lastVisit == null) return 0;
    return DateTime.now().difference(_lastVisit!).inDays;
  }

  bool get shouldShowWelcomeBack => daysSinceLastVisit > 3;

  /// ✅ FIXED: 使用 GardenState.initial() 确保默认值一致
  GardenState _getDefaultGardenState() {
    return GardenState.initial(_userId ?? '');
  }

  Future<void> loadGardenState(String userId) async {
    _userId = userId;
    _isLoading = true;
    notifyListeners();

    try {
      final doc = await _firestore.collection('gardens').doc(userId).get();

      if (doc.exists && doc.data() != null) {
        _gardenState = GardenState.fromMap(doc.data()!);
        _lastVisit = _gardenState!.lastVisited;

        // ✅ FIXED (v2): 使用 Firestore 中的 lastBonusDate 判断是否已发放
        final daysSince = daysSinceLastVisit;
        if (daysSince > 1) {
          final lastBonusDate = doc.data()!['lastRestBonusDate'] as String?;
          final todayStr = DateTime.now().toIso8601String().substring(0, 10);

          if (lastBonusDate != todayStr) {
            final bonus = _welcomeService.calculateRestBonus(daysSince);
            await _applyRestBonus(bonus, todayStr);
          }
        }
      } else {
        // ✅ FIXED: 使用 GardenState.initial() 确保与 model 一致
        _gardenState = GardenState.initial(userId);
        await _saveGarden();
      }

      _gardenState = _gardenState!.copyWith(
        lastVisited: DateTime.now(),
        lastUpdated: DateTime.now(),
      );
      await _saveGarden();

      _currentAmbiance = _ambianceService.getGardenAmbiance(null);
    } catch (e) {
      debugPrint('Error loading garden state: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> initializeGarden(String userId) async {
    await loadGardenState(userId);
  }

  /// ✅ FIXED (v2): 将 bonus 发放日期写入 Firestore
  Future<void> _applyRestBonus(Map<String, int> bonus, String todayStr) async {
    if (_gardenState == null) return;

    _gardenState = _gardenState!.copyWith(
      waterDrops: _gardenState!.waterDrops + (bonus['water'] ?? 0),
      sunlightPoints: _gardenState!.sunlightPoints + (bonus['sunlight'] ?? 0),
      gardenStatus: 'active',
    );

    // ✅ 额外写入 lastRestBonusDate 防止重复
    if (_userId != null) {
      try {
        await _firestore.collection('gardens').doc(_userId).set(
          {
            ..._gardenState!.toMap(),
            'lastRestBonusDate': todayStr,
          },
          SetOptions(merge: true),
        );
      } catch (e) {
        debugPrint('Error saving rest bonus: $e');
      }
    }
  }

  void setCurrentMood(String? mood) {
    _currentMood = mood;
    _currentAmbiance = _ambianceService.getGardenAmbiance(mood);
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 植物成长
  // ═══════════════════════════════════════════════════════════════════════════

  Future<bool> growPlant(String userId) async {
    if (_gardenState == null) return false;
    if (!_gardenState!.canGrow()) return false; // canGrow() 已包含资源检查

    final waterNeeded = _gardenState!.getWaterNeededForNextLevel();
    final sunlightNeeded = _gardenState!.getSunlightNeededForNextLevel();

    _gardenState = _gardenState!.copyWith(
      plantLevel: _gardenState!.plantLevel + 1,
      waterDrops: _gardenState!.waterDrops - waterNeeded,
      sunlightPoints: _gardenState!.sunlightPoints - sunlightNeeded,
      lastUpdated: DateTime.now(),
    );

    await _saveGarden();
    notifyListeners();
    return true;
  }

  String getGrowthMessage() {
    if (_gardenState == null) return 'Your garden is growing! 🌱';
    return Constants.getGrowthMessage(_gardenState!.plantLevel);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 颜色系统
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> selectColor(String userId, String colorHex) async {
    if (_gardenState == null) return;
    if (!_gardenState!.unlockedColors.contains(colorHex)) return;

    _gardenState = _gardenState!.copyWith(
      selectedColor: colorHex,
      lastUpdated: DateTime.now(),
    );

    await _saveGarden();
    notifyListeners();
  }

  Future<bool> unlockColor(String userId, String colorHex, int cost) async {
    if (_gardenState == null) return false;
    if (!_gardenState!.canUnlockColor(cost)) return false;
    if (_gardenState!.unlockedColors.contains(colorHex)) return false;

    final updatedColors = List<String>.from(_gardenState!.unlockedColors)
      ..add(colorHex);

    _gardenState = _gardenState!.copyWith(
      unlockedColors: updatedColors,
      sunlightPoints: _gardenState!.sunlightPoints - cost,
      selectedColor: colorHex,
      lastUpdated: DateTime.now(),
    );

    await _saveGarden();
    notifyListeners();
    return true;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ✅ 统一的奖励系统 - 替代 rewardHabitCompletion 和 addHabitReward
  // ═══════════════════════════════════════════════════════════════════════════

  /// ✅ 统一的习惯完成奖励方法
  /// ✅ FIXED (v2): 增加 isRewardedToday 检查，防止重复奖励
  Future<Map<String, dynamic>> rewardHabitCompletion({
    required String userId,
    required Habit habit,
    String? currentMood,
  }) async {
    if (_gardenState == null) {
      return {'water': 0, 'sunlight': 0, 'specialUnlock': null, 'message': ''};
    }

    // ✅ FIXED (v2): 防止重复奖励 - 即使外部忘记检查也能防护
    if (habit.isRewardedToday()) {
      debugPrint('⚠️ Habit "${habit.title}" already rewarded today, skipping');
      return {
        'water': 0,
        'sunlight': 0,
        'specialUnlock': null,
        'message': 'Already rewarded today~',
        'alreadyRewarded': true,
      };
    }

    // ✅ 使用 Constants 中的统一计算方法
    final rewards = Constants.calculateHabitReward(
      category: habit.category,
      currentStreak: habit.currentStreak,
      currentMood: currentMood,
    );

    final waterReward = rewards['water'] ?? Constants.baseWaterReward;
    final sunlightReward = rewards['sunlight'] ?? Constants.baseSunlightReward;

    // 检查特殊解锁
    String? specialUnlock;
    if (currentMood != null) {
      specialUnlock = Constants.checkSpecialUnlock(currentMood, habit.category);
      if (specialUnlock != null && !_gardenState!.unlockedColors.contains(specialUnlock)) {
        final updatedColors = List<String>.from(_gardenState!.unlockedColors)
          ..add(specialUnlock);
        _gardenState = _gardenState!.copyWith(unlockedColors: updatedColors);
      }
    }

    // 更新花园状态
    _gardenState = _gardenState!.copyWith(
      waterDrops: _gardenState!.waterDrops + waterReward,
      sunlightPoints: _gardenState!.sunlightPoints + sunlightReward,
      lastUpdated: DateTime.now(),
    );

    await _saveGarden();

    // 生成温柔的确认消息
    String message = '';
    try {
      message = await _geminiService.generateGentleAcknowledgment(habit.title);
    } catch (e) {
      debugPrint('Failed to generate acknowledgment: $e');
      message = _getDefaultAcknowledgment(habit.title);
    }

    notifyListeners();

    debugPrint('🌸 Habit reward: +$waterReward 💧, +$sunlightReward ☀️');

    return {
      'water': waterReward,
      'sunlight': sunlightReward,
      'specialUnlock': specialUnlock,
      'message': message,
    };
  }

  /// 默认确认消息（当 AI 不可用时）
  String _getDefaultAcknowledgment(String habitTitle) {
    final messages = [
      'Well done completing "$habitTitle"! 🌱',
      'Your garden grows with each habit! 🌿',
      '"$habitTitle" completed - wonderful! ✨',
      'Another step forward! Keep blooming! 🌸',
    ];
    return messages[DateTime.now().millisecond % messages.length];
  }

  /// ✅ FIXED: 使用 rewardHabitCompletion 替代，_userId 为 null 时提前返回
  @Deprecated('Use rewardHabitCompletion instead for unified reward logic')
  Future<String> addHabitReward(Habit habit) async {
    // ✅ FIXED: 如果 _userId 为 null，提前返回空字符串，避免传空字符串导致问题
    if (_userId == null) {
      debugPrint('⚠️ Cannot add habit reward: userId is null');
      return '';
    }

    final result = await rewardHabitCompletion(
      userId: _userId!,
      habit: habit,
      currentMood: _currentMood,
    );
    return result['message'] as String? ?? '';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 其他奖励方法
  // ═══════════════════════════════════════════════════════════════════════════

  /// 日记奖励
  Future<void> addJournalReward(String mood, double sentimentScore) async {
    if (_gardenState == null) return;

    int waterReward = 1;
    int sunlightReward = 1;

    // 表达困难情绪额外奖励
    if (mood == 'anxious' || mood == 'sad' || mood == 'stressed') {
      waterReward += 1;
    }

    _gardenState = _gardenState!.copyWith(
      waterDrops: _gardenState!.waterDrops + waterReward,
      sunlightPoints: _gardenState!.sunlightPoints + sunlightReward,
      lastUpdated: DateTime.now(),
    );

    await _saveGarden();
    notifyListeners();

    debugPrint('📝 Journal reward: +$waterReward 💧, +$sunlightReward ☀️');
  }

  /// 善意链奖励
  Future<void> addKindnessReward({
    required int sunlight,
    required int water,
  }) async {
    if (_gardenState == null) return;

    _gardenState = _gardenState!.copyWith(
      waterDrops: _gardenState!.waterDrops + water,
      sunlightPoints: _gardenState!.sunlightPoints + sunlight,
      lastUpdated: DateTime.now(),
    );

    await _saveGarden();
    notifyListeners();

    debugPrint('🌸 Kindness reward: +$water 💧, +$sunlight ☀️');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 辅助方法
  // ═══════════════════════════════════════════════════════════════════════════

  String getPlantEmoji() {
    if (_gardenState == null) return '🌱';
    return _gardenState!.plantEmoji;
  }

  String getPlantDescription() {
    if (_gardenState == null) return 'Your garden awaits...';
    return Constants.getGrowthMessage(_gardenState!.plantLevel);
  }

  String getGardenMessage() {
    if (_currentAmbiance != null) {
      return _currentAmbiance!.message;
    }
    return 'Welcome to your garden 🌿';
  }

  Future<void> _saveGarden() async {
    if (_gardenState == null || _userId == null) return;

    try {
      await _firestore
          .collection('gardens')
          .doc(_userId)
          .set(_gardenState!.toMap());
    } catch (e) {
      debugPrint('Error saving garden: $e');
    }
  }

  void reset() {
    _gardenState = null;
    _userId = null;
    _currentMood = null;
    _currentAmbiance = null;
    _lastVisit = null;
    _isLoading = false;
    notifyListeners();
  }
}