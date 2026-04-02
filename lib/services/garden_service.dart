// services/garden_service.dart

import '../models/habit_model.dart';
import '../models/garden_model.dart';
import '../utils/constants.dart';

class GardenService {
  Map<String, int> calculateRewards(Habit habit, String? currentMood) {
    // Use the unified Constants method for consistency
    return Constants.calculateHabitReward(
      category: habit.category,
      currentStreak: habit.currentStreak,
      currentMood: currentMood,
    );
  }

  String? checkSpecialUnlock(String? mood, String? habitCategory) {
    return Constants.checkSpecialUnlock(mood, habitCategory);
  }

  GardenState growPlant(GardenState currentState) {
    return currentState.tryGrow() ?? currentState;
  }

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

  String getGrowthMessage(int level) {
    return Constants.getGrowthMessage(level);
  }

  String getPlantStageName(int level) {
    return Constants.getPlantStageName(level);
  }

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

  List<String> getRecommendedCategories(String? mood) {
    return Constants.getRecommendedCategories(mood);
  }

  bool isTherapeuticHabit(String? mood, String category) {
    final recommended = Constants.getRecommendedCategories(mood);
    return recommended.contains(category);
  }
}