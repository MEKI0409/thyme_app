// controllers/garden_controller.dart

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

  String? get userId => _userId;

  int get daysSinceLastVisit {
    if (_lastVisit == null) return 0;
    return DateTime.now().difference(_lastVisit!).inDays;
  }

  bool get shouldShowWelcomeBack => daysSinceLastVisit > 3;

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

  Future<void> _applyRestBonus(Map<String, int> bonus, String todayStr) async {
    if (_gardenState == null) return;

    _gardenState = _gardenState!.copyWith(
      waterDrops: _gardenState!.waterDrops + (bonus['water'] ?? 0),
      sunlightPoints: _gardenState!.sunlightPoints + (bonus['sunlight'] ?? 0),
      gardenStatus: 'active',
    );

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

  Future<Map<String, dynamic>> rewardHabitCompletion({
    required String userId,
    required Habit habit,
    String? currentMood,
  }) async {
    if (_gardenState == null) {
      return {'water': 0, 'sunlight': 0, 'specialUnlock': null, 'message': ''};
    }

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

    final rewards = Constants.calculateHabitReward(
      category: habit.category,
      currentStreak: habit.currentStreak,
      currentMood: currentMood,
    );

    final waterReward = rewards['water'] ?? Constants.baseWaterReward;
    final sunlightReward = rewards['sunlight'] ?? Constants.baseSunlightReward;

    String? specialUnlock;
    if (currentMood != null) {
      specialUnlock = Constants.checkSpecialUnlock(currentMood, habit.category);
      if (specialUnlock != null && !_gardenState!.unlockedColors.contains(specialUnlock)) {
        final updatedColors = List<String>.from(_gardenState!.unlockedColors)
          ..add(specialUnlock);
        _gardenState = _gardenState!.copyWith(unlockedColors: updatedColors);
      }
    }

    _gardenState = _gardenState!.copyWith(
      waterDrops: _gardenState!.waterDrops + waterReward,
      sunlightPoints: _gardenState!.sunlightPoints + sunlightReward,
      lastUpdated: DateTime.now(),
    );

    await _saveGarden();

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

  String _getDefaultAcknowledgment(String habitTitle) {
    final messages = [
      'Well done completing "$habitTitle"! 🌱',
      'Your garden grows with each habit! 🌿',
      '"$habitTitle" completed - wonderful! ✨',
      'Another step forward! Keep blooming! 🌸',
    ];
    return messages[DateTime.now().millisecond % messages.length];
  }

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

  Future<void> addJournalReward(String mood, double sentimentScore) async {
    if (_gardenState == null) return;

    int waterReward = 1;
    int sunlightReward = 1;

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