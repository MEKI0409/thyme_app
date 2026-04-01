// utils/constants.dart
// Unified constants for the Thyme app

import 'package:flutter/material.dart';

class Constants {
  // =============================================================================
  // API Configuration - Direct Embedding
  // =============================================================================

  // ⚠️ NEVER hardcode API keys in source code!
  // Pass it at build time:  flutter run --dart-define=GEMINI_API_KEY=your_key
  // Get your free API Key at: https://aistudio.google.com/apikey
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

  // Recommended Gemini models (2025-2026)
  // ✅ FIXED: gemini-1.5-flash/pro are SHUT DOWN (return 404)
  // Updated to current available models
  static const String geminiModel = 'gemini-2.5-flash-lite';
  static const String geminiModelFallback = 'gemini-2.0-flash';

  // Sentiment API URL (optional)
  static const String sentimentApiUrl = '';

  // =============================================================================
  // API Status Check
  // =============================================================================

  /// Check if Gemini API is configured
  static bool get isGeminiConfigured {
    if (geminiApiKey.isEmpty) return false;
    if (geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE') return false;
    if (geminiApiKey == 'YOUR_API_KEY_HERE') return false;
    // Valid Google API Keys start with AIza
    return geminiApiKey.startsWith('AIza') && geminiApiKey.length > 30;
  }

  /// Check if Sentiment API is configured
  static bool get isSentimentApiConfigured =>
      sentimentApiUrl.isNotEmpty &&
          sentimentApiUrl != 'YOUR_SENTIMENT_API_URL';

  // =============================================================================
  // App Info
  // =============================================================================

  static const String appName = 'Thyme';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Take your time to heal';

  // =============================================================================
  // Mood Configuration
  // =============================================================================

  static const Map<String, Color> moodColors = {
    'happy': Color(0xFFFFD54F),
    'calm': Color(0xFF81C784),
    'anxious': Color(0xFF9575CD),
    'sad': Color(0xFF64B5F6),
    'stressed': Color(0xFFE57373),
    'neutral': Color(0xFFB0BEC5),
    'angry': Color(0xFFEF5350),
    'tired': Color(0xFF90A4AE),
    'hopeful': Color(0xFF4DD0E1),
    'confused': Color(0xFFFFAB91),
    'lonely': Color(0xFF7986CB),
  };

  static const Map<String, String> moodEmojis = {
    'happy': '😊',
    'calm': '😌',
    'anxious': '😰',
    'sad': '😢',
    'stressed': '😫',
    'neutral': '😐',
    'angry': '😠',
    'tired': '😴',
    'hopeful': '🌟',
    'confused': '😕',
    'lonely': '💙',
  };

  /// Safely get mood color
  static Color getMoodColor(String? mood) {
    if (mood == null || mood.isEmpty) return const Color(0xFFB0BEC5);
    return moodColors[mood.toLowerCase()] ?? const Color(0xFFB0BEC5);
  }

  /// Safely get mood emoji
  static String getMoodEmoji(String? mood) {
    if (mood == null || mood.isEmpty) return '😐';
    return moodEmojis[mood.toLowerCase()] ?? '😐';
  }

  /// Get all mood options
  static List<String> get allMoods => moodColors.keys.toList();

  // =============================================================================
  // Habit Categories
  // =============================================================================

  static const Map<String, String> habitCategories = {
    'Mindfulness': '🧘',
    'Exercise': '💪',
    'Social': '👥',
    'Creative': '🎨',
    'Learning': '📚',
    'Self-Care': '💚',
  };

  /// Safely get category icon
  static String getCategoryIcon(String? category) {
    if (category == null || category.isEmpty) return '📌';
    return habitCategories[category] ?? '📌';
  }

  /// Get all categories
  static List<String> get allCategories => habitCategories.keys.toList();

  // =============================================================================
  // Garden System - maxPlantLevel = 10
  // =============================================================================

  /// Maximum plant level
  static const int maxPlantLevel = 10;

  /// Plant stage names (corresponds to GardenModel and icon system)
  static const List<String> plantStageNames = [
    'Seedling',        // Level 0
    'Tiny Sprout',     // Level 1
    'Sprout',    // Level 2
    'Small Plant',     // Level 3
    'Young Plant',   // Level 4
    'Blooming',        // Level 5
    'Flowering',       // Level 6
    'Big Flower',      // Level 7
    'Sunflower',       // Level 8
    'Small Tree',      // Level 9
    'Mighty Tree',     // Level 10
  ];

  /// Get plant stage name
  static String getPlantStageName(int level) {
    if (level < 0) return plantStageNames.first;
    if (level >= plantStageNames.length) return plantStageNames.last;
    return plantStageNames[level];
  }

  /// Growth messages
  static const List<String> plantGrowthMessages = [
    '🌱 A tiny sprout appears',
    '🌱 Your seedling is taking root',
    '🌿 Small leaves are emerging',
    '🌿 Your plant is growing stronger',
    '🍃 Beautiful leaves are spreading',
    '🌸 A small bud is forming',
    '🌸 Your plant is starting to bloom',
    '🌺 Full bloom - magnificent!',
    '🌻 A radiant sunflower!',
    '🌳 Growing into a tree',
    '🌳 A mighty tree of resilience!',
  ];

  /// Safely get growth message
  static String getGrowthMessage(int level) {
    if (level < 0) return plantGrowthMessages.first;
    if (level >= plantGrowthMessages.length) return plantGrowthMessages.last;
    return plantGrowthMessages[level];
  }

  /// Get growth cost - matches GardenModel formula
  /// GardenModel uses: water = 10 * (level + 1), sunlight = 5 * (level + 1)
  static Map<String, int> getGrowthCost(int currentLevel) {
    final water = 10 * (currentLevel + 1);
    final sunlight = 5 * (currentLevel + 1);
    return {'water': water, 'sunlight': sunlight};
  }

  /// Legacy growthCosts Map (kept for compatibility)
  @Deprecated('Use getGrowthCost(level) instead for consistency with GardenModel')
  static const Map<int, Map<String, int>> growthCosts = {
    0: {'water': 10, 'sunlight': 5},
    1: {'water': 20, 'sunlight': 10},
    2: {'water': 30, 'sunlight': 15},
    3: {'water': 40, 'sunlight': 20},
    4: {'water': 50, 'sunlight': 25},
    5: {'water': 60, 'sunlight': 30},
    6: {'water': 70, 'sunlight': 35},
    7: {'water': 80, 'sunlight': 40},
    8: {'water': 90, 'sunlight': 45},
    9: {'water': 100, 'sunlight': 50},
  };

  static const List<Map<String, dynamic>> gardenColors = [
    {'name': 'Teal', 'hex': '#4DB6AC', 'cost': 0},
    {'name': 'Calm Blue', 'hex': '#64B5F6', 'cost': 5},
    {'name': 'Warm Yellow', 'hex': '#FFD54F', 'cost': 10},
    {'name': 'Energy Orange', 'hex': '#FF7043', 'cost': 15},
    {'name': 'Soft Purple', 'hex': '#9575CD', 'cost': 20},
    {'name': 'Fresh Green', 'hex': '#81C784', 'cost': 25},
    {'name': 'Pink Bliss', 'hex': '#F06292', 'cost': 30},
    {'name': 'Sky Blue', 'hex': '#4FC3F7', 'cost': 35},
    {'name': 'Sunset', 'hex': '#FFAB91', 'cost': 40},
  ];

  /// Get garden color by name
  static Map<String, dynamic>? getGardenColorByName(String name) {
    try {
      return gardenColors.firstWhere(
            (c) => c['name'].toString().toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get garden color by hex
  static Map<String, dynamic>? getGardenColorByHex(String hex) {
    final normalizedHex = hex.startsWith('#') ? hex : '#$hex';
    try {
      return gardenColors.firstWhere(
            (c) => c['hex'].toString().toLowerCase() == normalizedHex.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // =============================================================================
  // Mood to Habit Recommendations
  // =============================================================================

  static const Map<String, List<String>> moodToCategories = {
    'anxious': ['Mindfulness', 'Self-Care'],
    'stressed': ['Exercise', 'Mindfulness'],
    'sad': ['Social', 'Creative'],
    'happy': ['Exercise', 'Learning'],
    'calm': ['Creative', 'Learning'],
    'neutral': ['Self-Care', 'Mindfulness'],
    'angry': ['Exercise', 'Mindfulness'],
    'tired': ['Self-Care', 'Mindfulness'],
    'hopeful': ['Learning', 'Creative'],
    'confused': ['Mindfulness', 'Self-Care'],
    'lonely': ['Social', 'Self-Care'],
  };

  /// Get recommended categories for mood
  static List<String> getRecommendedCategories(String? mood) {
    if (mood == null || mood.isEmpty) return ['Self-Care', 'Mindfulness'];
    return moodToCategories[mood.toLowerCase()] ?? ['Self-Care', 'Mindfulness'];
  }

  // =============================================================================
  // Special Unlocks
  // =============================================================================

  static const Map<String, String> specialUnlocks = {
    'anxious_Mindfulness': '#64B5F6',
    'sad_Social': '#FFD54F',
    'stressed_Exercise': '#FF7043',
    'happy_Creative': '#F06292',
    'calm_Learning': '#81C784',
  };

  /// Check special unlock
  static String? checkSpecialUnlock(String? mood, String? category) {
    if (mood == null || category == null) return null;
    final key = '${mood.toLowerCase()}_$category';
    return specialUnlocks[key];
  }

  // =============================================================================
  // Reward Calculation
  // =============================================================================

  /// Base habit completion reward
  static const int baseWaterReward = 2;
  static const int baseSunlightReward = 1;

  /// Category reward bonuses
  /// - Calming categories (Mindfulness, Self-Care): +water bonus
  /// - Active categories (Exercise, Learning): +sunlight bonus
  /// - Social: Neutral baseline (no bonus)
  /// - Creative: Both bonuses
  static const Map<String, Map<String, int>> categoryBonuses = {
    'Mindfulness': {'water': 1, 'sunlight': 0},
    'Self-Care': {'water': 1, 'sunlight': 0},
    'Exercise': {'water': 0, 'sunlight': 1},
    'Learning': {'water': 0, 'sunlight': 1},
    'Social': {'water': 0, 'sunlight': 0},
    'Creative': {'water': 1, 'sunlight': 1},
  };

  /// Streak bonus calculation
  static Map<String, int> getStreakBonus(int streak) {
    if (streak >= 30) return {'water': 3, 'sunlight': 3};
    if (streak >= 14) return {'water': 2, 'sunlight': 2};
    if (streak >= 7) return {'water': 1, 'sunlight': 1};
    return {'water': 0, 'sunlight': 0};
  }

  /// Calculate habit completion reward (unified method)
  static Map<String, int> calculateHabitReward({
    required String category,
    required int currentStreak,
    String? currentMood,
  }) {
    int water = baseWaterReward;
    int sunlight = baseSunlightReward;

    // Category bonus
    final categoryBonus = categoryBonuses[category] ?? {'water': 0, 'sunlight': 0};
    water += categoryBonus['water'] ?? 0;
    sunlight += categoryBonus['sunlight'] ?? 0;

    // Streak bonus
    final streakBonus = getStreakBonus(currentStreak);
    water += streakBonus['water'] ?? 0;
    sunlight += streakBonus['sunlight'] ?? 0;

    // Mood match bonus
    if (currentMood != null) {
      final recommendedCategories = getRecommendedCategories(currentMood);
      if (recommendedCategories.contains(category)) {
        water += 1;
        sunlight += 1;
      }
    }

    return {'water': water, 'sunlight': sunlight};
  }

  // =============================================================================
  // Utility Methods
  // =============================================================================

  /// Safely parse color
  static Color parseColor(String? hex, {Color defaultColor = const Color(0xFF4DB6AC)}) {
    if (hex == null || hex.isEmpty) return defaultColor;
    try {
      String colorHex = hex;
      if (colorHex.startsWith('#')) {
        colorHex = colorHex.substring(1);
      }
      if (colorHex.length == 6) {
        colorHex = 'FF$colorHex';
      }
      return Color(int.parse(colorHex, radix: 16));
    } catch (e) {
      return defaultColor;
    }
  }

  /// Convert color to hex string
  static String colorToHex(Color color, {bool includeHash = true}) {
    final hex = color.value.toRadixString(16).padLeft(8, '0').substring(2);
    return includeHash ? '#$hex' : hex;
  }

  // =============================================================================
  // Time Constants
  // =============================================================================

  static const Duration apiTimeout = Duration(seconds: 15);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);
  static const Duration toastDuration = Duration(seconds: 2);
}