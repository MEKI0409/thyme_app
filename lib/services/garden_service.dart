// services/garden_service.dart
// ✅ FIXED: Now matches Constants.calculateHabitReward logic completely

import '../models/habit_model.dart';
import '../models/garden_model.dart';
import '../utils/constants.dart';

class GardenService {
  /// Calculate rewards for completing a habit
  /// ✅ FIXED: Now includes all bonuses (category, streak milestones, mood matching)
  Map<String, int> calculateRewards(Habit habit, String? currentMood) {
    // Use the unified Constants method for consistency
    return Constants.calculateHabitReward(
      category: habit.category,
      currentStreak: habit.currentStreak,
      currentMood: currentMood,
    );
  }

  /// Check if a therapeutic pairing unlocks a special color
  String? checkSpecialUnlock(String? mood, String? habitCategory) {
    return Constants.checkSpecialUnlock(mood, habitCategory);
  }

  /// Grow the plant if resources are sufficient
  /// ✅ Properly deducts both water and sunlight when growing
  GardenState growPlant(GardenState currentState) {
    // Use the model's tryGrow method for consistency
    return currentState.tryGrow() ?? currentState;
  }

  /// Unlock a new garden color
  GardenState unlockColor(GardenState currentState, String colorHex, int cost) {
    if (!currentState.canUnlockColor(cost)) {
      return currentState;
    }

    if (currentState.unlockedColors.contains(colorHex)) {
      return currentState;
    }

    final updatedColors = List<String>.from(currentState.unlockedColors)
      ..add(colorHex);

    return currentState.copyWith(
      unlockedColors: updatedColors,
      sunlightPoints: currentState.sunlightPoints - cost,
      selectedColor: colorHex,
      lastUpdated: DateTime.now(),
    );
  }

  /// Get growth message for current level
  String getGrowthMessage(int level) {
    return Constants.getGrowthMessage(level);
  }

  /// Get plant stage name for current level
  String getPlantStageName(int level) {
    return Constants.getPlantStageName(level);
  }

  /// Calculate total resources needed to reach a target level
  Map<String, int> calculateTotalResourcesToLevel(int currentLevel, int targetLevel) {
    int totalWater = 0;
    int totalSunlight = 0;

    for (int level = currentLevel; level < targetLevel; level++) {
      final cost = Constants.getGrowthCost(level);
      totalWater += cost['water']!;
      totalSunlight += cost['sunlight']!;
    }

    return {
      'water': totalWater,
      'sunlight': totalSunlight,
    };
  }

  /// Get recommended habits based on current mood
  List<String> getRecommendedCategories(String? mood) {
    return Constants.getRecommendedCategories(mood);
  }

  /// Check if habit category is therapeutic for current mood
  bool isTherapeuticHabit(String? mood, String category) {
    final recommended = Constants.getRecommendedCategories(mood);
    return recommended.contains(category);
  }
}