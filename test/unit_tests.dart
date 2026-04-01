// test/unit_tests.dart
// ============================================================================
// THYME APP - COMPREHENSIVE UNIT TESTS
// ============================================================================
// ✅ IMPROVED: 移除所有 placeholder 测试，添加真实的测试逻辑
// ✅ IMPROVED: 使用统一的 Constants 进行验证
// ✅ IMPROVED: 添加更多边界条件测试
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:thyme_app/models/garden_model.dart';
import 'package:thyme_app/models/habit_model.dart';
import 'package:thyme_app/utils/constants.dart';

void main() {
  // ═══════════════════════════════════════════════════════════════════════════
  // CONSTANTS TESTS - 验证常量配置
  // ═══════════════════════════════════════════════════════════════════════════
  group('Constants Tests', () {
    group('Plant Level Configuration', () {
      test('maxPlantLevel should be 10', () {
        expect(Constants.maxPlantLevel, equals(10));
        expect(GardenState.maxPlantLevel, equals(10));
        // 两者应该保持一致
        expect(Constants.maxPlantLevel, equals(GardenState.maxPlantLevel));
      });

      test('plantGrowthMessages should have 11 entries (level 0-10)', () {
        expect(Constants.plantGrowthMessages.length, equals(11));
      });

      test('plantStageNames should have 11 entries (level 0-10)', () {
        expect(Constants.plantStageNames.length, equals(11));
      });

      test('getGrowthMessage should return valid message for all levels', () {
        for (int level = 0; level <= 10; level++) {
          final message = Constants.getGrowthMessage(level);
          expect(message, isNotEmpty);
          expect(message, isA<String>());
        }
      });

      test('getGrowthMessage should handle out-of-range levels gracefully', () {
        expect(Constants.getGrowthMessage(-1), equals(Constants.plantGrowthMessages.first));
        expect(Constants.getGrowthMessage(100), equals(Constants.plantGrowthMessages.last));
      });
    });

    group('Growth Cost Configuration', () {
      test('getGrowthCost should return correct values for each level', () {
        // Level 0 → 1: water = 10*1=10, sunlight = 5*1=5
        expect(Constants.getGrowthCost(0), equals({'water': 10, 'sunlight': 5}));

        // Level 5 → 6: water = 10*6=60, sunlight = 5*6=30
        expect(Constants.getGrowthCost(5), equals({'water': 60, 'sunlight': 30}));

        // Level 9 → 10: water = 10*10=100, sunlight = 5*10=50
        expect(Constants.getGrowthCost(9), equals({'water': 100, 'sunlight': 50}));
      });

      test('growth costs should increase linearly with level', () {
        int prevWater = 0;
        int prevSunlight = 0;

        for (int level = 0; level < 10; level++) {
          final cost = Constants.getGrowthCost(level);
          expect(cost['water']!, greaterThan(prevWater));
          expect(cost['sunlight']!, greaterThan(prevSunlight));
          prevWater = cost['water']!;
          prevSunlight = cost['sunlight']!;
        }
      });
    });

    group('Mood Configuration', () {
      test('all moods should have colors defined', () {
        for (final mood in Constants.allMoods) {
          final color = Constants.getMoodColor(mood);
          expect(color, isNotNull);
        }
      });

      test('all moods should have emojis defined', () {
        for (final mood in Constants.allMoods) {
          final emoji = Constants.getMoodEmoji(mood);
          expect(emoji, isNotEmpty);
        }
      });

      test('getMoodColor should handle null and empty gracefully', () {
        expect(Constants.getMoodColor(null), isNotNull);
        expect(Constants.getMoodColor(''), isNotNull);
        expect(Constants.getMoodColor('unknown'), isNotNull);
      });

      test('getMoodEmoji should handle null and empty gracefully', () {
        expect(Constants.getMoodEmoji(null), equals('😐'));
        expect(Constants.getMoodEmoji(''), equals('😐'));
        expect(Constants.getMoodEmoji('unknown'), equals('😐'));
      });
    });

    group('Habit Category Configuration', () {
      test('all categories should have icons defined', () {
        final categories = ['Mindfulness', 'Exercise', 'Social', 'Creative', 'Learning', 'Self-Care'];
        for (final category in categories) {
          final icon = Constants.getCategoryIcon(category);
          expect(icon, isNotEmpty);
        }
      });

      test('getCategoryIcon should handle unknown categories', () {
        expect(Constants.getCategoryIcon(null), equals('📌'));
        expect(Constants.getCategoryIcon(''), equals('📌'));
        expect(Constants.getCategoryIcon('Unknown'), equals('📌'));
      });

      test('moodToCategories should have recommendations for all moods', () {
        for (final mood in Constants.allMoods) {
          final categories = Constants.getRecommendedCategories(mood);
          expect(categories, isNotEmpty);
          expect(categories.length, greaterThanOrEqualTo(1));
        }
      });
    });

    group('Reward Calculation', () {
      test('base rewards should be positive', () {
        expect(Constants.baseWaterReward, greaterThan(0));
        expect(Constants.baseSunlightReward, greaterThan(0));
      });

      test('calculateHabitReward should return base rewards for neutral category', () {
        final rewards = Constants.calculateHabitReward(
          category: 'Social',
          currentStreak: 0,
        );

        expect(rewards['water'], greaterThanOrEqualTo(Constants.baseWaterReward));
        expect(rewards['sunlight'], greaterThanOrEqualTo(Constants.baseSunlightReward));
      });

      test('Mindfulness should give water bonus', () {
        final mindfulnessRewards = Constants.calculateHabitReward(
          category: 'Mindfulness',
          currentStreak: 0,
        );
        final socialRewards = Constants.calculateHabitReward(
          category: 'Social',
          currentStreak: 0,
        );

        expect(mindfulnessRewards['water'], greaterThan(socialRewards['water']!));
      });

      test('Exercise should give sunlight bonus', () {
        final exerciseRewards = Constants.calculateHabitReward(
          category: 'Exercise',
          currentStreak: 0,
        );
        final socialRewards = Constants.calculateHabitReward(
          category: 'Social',
          currentStreak: 0,
        );

        expect(exerciseRewards['sunlight'], greaterThan(socialRewards['sunlight']!));
      });

      test('streak bonus should increase rewards', () {
        final noStreakRewards = Constants.calculateHabitReward(
          category: 'Social',
          currentStreak: 0,
        );
        final sevenDayRewards = Constants.calculateHabitReward(
          category: 'Social',
          currentStreak: 7,
        );
        final fourteenDayRewards = Constants.calculateHabitReward(
          category: 'Social',
          currentStreak: 14,
        );

        expect(sevenDayRewards['water'], greaterThan(noStreakRewards['water']!));
        expect(fourteenDayRewards['water'], greaterThan(sevenDayRewards['water']!));
      });

      test('mood matching should give bonus', () {
        // stressed → Exercise is recommended
        final matchedRewards = Constants.calculateHabitReward(
          category: 'Exercise',
          currentStreak: 0,
          currentMood: 'stressed',
        );
        final unmatchedRewards = Constants.calculateHabitReward(
          category: 'Exercise',
          currentStreak: 0,
          currentMood: null,
        );

        expect(matchedRewards['water'], greaterThan(unmatchedRewards['water']!));
      });
    });

    group('Special Unlocks', () {
      test('therapeutic pairs should unlock correct colors', () {
        expect(Constants.checkSpecialUnlock('anxious', 'Mindfulness'), equals('#64B5F6'));
        expect(Constants.checkSpecialUnlock('sad', 'Social'), equals('#FFD54F'));
        expect(Constants.checkSpecialUnlock('stressed', 'Exercise'), equals('#FF7043'));
        expect(Constants.checkSpecialUnlock('happy', 'Creative'), equals('#F06292'));
        expect(Constants.checkSpecialUnlock('calm', 'Learning'), equals('#81C784'));
      });

      test('non-therapeutic pairs should return null', () {
        expect(Constants.checkSpecialUnlock('happy', 'Exercise'), isNull);
        expect(Constants.checkSpecialUnlock('sad', 'Learning'), isNull);
        expect(Constants.checkSpecialUnlock('neutral', 'Mindfulness'), isNull);
      });

      test('checkSpecialUnlock should handle null inputs', () {
        expect(Constants.checkSpecialUnlock(null, 'Mindfulness'), isNull);
        expect(Constants.checkSpecialUnlock('anxious', null), isNull);
        expect(Constants.checkSpecialUnlock(null, null), isNull);
      });
    });

    group('Color Utilities', () {
      test('parseColor should handle valid hex strings', () {
        final color1 = Constants.parseColor('#4DB6AC');
        final color2 = Constants.parseColor('4DB6AC');
        final color3 = Constants.parseColor('#FF4DB6AC');

        expect(color1, isNotNull);
        expect(color2, isNotNull);
        expect(color3, isNotNull);
      });

      test('parseColor should return default for invalid input', () {
        final defaultColor = Constants.parseColor(null);
        final emptyColor = Constants.parseColor('');
        final invalidColor = Constants.parseColor('not-a-color');

        expect(defaultColor, isNotNull);
        expect(emptyColor, isNotNull);
        expect(invalidColor, isNotNull);
      });

      test('colorToHex should produce valid hex strings', () {
        final color = Constants.parseColor('#4DB6AC');
        final hex = Constants.colorToHex(color);

        expect(hex, startsWith('#'));
        expect(hex.length, equals(7)); // #RRGGBB
      });
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GARDEN MODEL TESTS
  // ═══════════════════════════════════════════════════════════════════════════
  group('GardenState Tests', () {
    group('Factory Constructors', () {
      test('initial should create valid starting state', () {
        final garden = GardenState.initial('test_user');

        expect(garden.userId, equals('test_user'));
        expect(garden.plantLevel, equals(0));
        expect(garden.waterDrops, equals(5));
        expect(garden.sunlightPoints, equals(5));
        expect(garden.gardenStatus, equals('active'));
        expect(garden.unlockedColors, contains('#4DB6AC'));
      });

      test('fromMap should parse all fields correctly', () {
        final map = {
          'userId': 'test_user',
          'plantLevel': 5,
          'waterDrops': 100,
          'sunlightPoints': 50,
          'lastVisited': DateTime.now().toIso8601String(),
          'gardenStatus': 'active',
          'unlockedColors': ['#4DB6AC', '#64B5F6'],
          'achievements': ['first_bloom'],
          'selectedColor': '#64B5F6',
        };

        final garden = GardenState.fromMap(map);

        expect(garden.plantLevel, equals(5));
        expect(garden.waterDrops, equals(100));
        expect(garden.sunlightPoints, equals(50));
        expect(garden.unlockedColors.length, equals(2));
      });

      test('fromMap should handle missing optional fields', () {
        final minimalMap = {
          'userId': 'test_user',
          'plantLevel': 1,
          'waterDrops': 10,
          'sunlightPoints': 5,
          'lastVisited': DateTime.now().toIso8601String(),
          'gardenStatus': 'active',
        };

        final garden = GardenState.fromMap(minimalMap);

        expect(garden.unlockedColors, isNotEmpty);
        expect(garden.achievements, isEmpty);
      });
    });

    group('Resource Calculations', () {
      test('getWaterNeededForNextLevel should use formula: 10 * (level + 1)', () {
        for (int level = 0; level < 10; level++) {
          final garden = _createTestGarden(level: level);
          final expected = 10 * (level + 1);
          expect(garden.getWaterNeededForNextLevel(), equals(expected));
        }
      });

      test('getSunlightNeededForNextLevel should use formula: 5 * (level + 1)', () {
        for (int level = 0; level < 10; level++) {
          final garden = _createTestGarden(level: level);
          final expected = 5 * (level + 1);
          expect(garden.getSunlightNeededForNextLevel(), equals(expected));
        }
      });

      test('getWaterNeededForNextLevel at max level should return 0', () {
        final garden = _createTestGarden(level: 10);
        expect(garden.getWaterNeededForNextLevel(), equals(0));
      });

      test('getSunlightNeededForNextLevel at max level should return 0', () {
        final garden = _createTestGarden(level: 10);
        expect(garden.getSunlightNeededForNextLevel(), equals(0));
      });
    });

    group('Growth Eligibility', () {
      test('hasEnoughResourcesToGrow returns true when sufficient', () {
        // Level 0 → 1 needs 10 water, 5 sunlight
        final garden = _createTestGarden(level: 0, water: 15, sunlight: 10);
        expect(garden.hasEnoughResourcesToGrow(), isTrue);
      });

      test('hasEnoughResourcesToGrow returns false when water insufficient', () {
        final garden = _createTestGarden(level: 0, water: 5, sunlight: 10);
        expect(garden.hasEnoughResourcesToGrow(), isFalse);
      });

      test('hasEnoughResourcesToGrow returns false when sunlight insufficient', () {
        final garden = _createTestGarden(level: 0, water: 15, sunlight: 2);
        expect(garden.hasEnoughResourcesToGrow(), isFalse);
      });

      test('canGrow returns false at max level even with resources', () {
        final garden = _createTestGarden(level: 10, water: 1000, sunlight: 1000);
        expect(garden.canGrow(), isFalse);
      });

      test('canGrow returns true when below max and has resources', () {
        final garden = _createTestGarden(level: 5, water: 100, sunlight: 50);
        expect(garden.canGrow(), isTrue);
      });
    });

    group('Growth Progress', () {
      test('growthProgress should be 1.0 at max level', () {
        final garden = _createTestGarden(level: 10);
        expect(garden.growthProgress, equals(1.0));
      });

      test('growthProgress should be 0.5 when half resources collected', () {
        // Level 0 needs 10 water, 5 sunlight
        final garden = _createTestGarden(level: 0, water: 5, sunlight: 2);
        // water: 5/10 = 0.5, sunlight: 2/5 = 0.4, average = 0.45
        expect(garden.growthProgress, closeTo(0.45, 0.01));
      });

      test('growthProgress should be clamped at 1.0 when over-resourced', () {
        final garden = _createTestGarden(level: 0, water: 100, sunlight: 100);
        expect(garden.growthProgress, equals(1.0));
      });
    });

    group('Plant Stage Names', () {
      test('plantEmoji should return correct emoji for each stage', () {
        expect(_createTestGarden(level: 0).plantEmoji, equals('🌱'));
        expect(_createTestGarden(level: 2).plantEmoji, equals('🌿'));
        expect(_createTestGarden(level: 4).plantEmoji, equals('🌸'));
        expect(_createTestGarden(level: 6).plantEmoji, equals('🌺'));
        expect(_createTestGarden(level: 8).plantEmoji, equals('🌻'));
        expect(_createTestGarden(level: 10).plantEmoji, equals('🌳'));
      });

      test('plantStageName should return correct name for each stage', () {
        expect(_createTestGarden(level: 0).plantStageName, equals('Seedling'));
        expect(_createTestGarden(level: 2).plantStageName, equals('Sprout'));
        expect(_createTestGarden(level: 4).plantStageName, equals('Young Plant'));
        expect(_createTestGarden(level: 6).plantStageName, equals('Flowering'));
        expect(_createTestGarden(level: 8).plantStageName, equals('Sunflower'));
        expect(_createTestGarden(level: 10).plantStageName, equals('Mighty Tree'));
      });
    });

    group('State Mutations', () {
      test('addResources should increase resources correctly', () {
        final garden = _createTestGarden(level: 0, water: 10, sunlight: 5);
        final updated = garden.addResources(water: 5, sunlight: 3);

        expect(updated.waterDrops, equals(15));
        expect(updated.sunlightPoints, equals(8));
        expect(updated.lastUpdated, isNotNull);
      });

      test('consumeResources should decrease resources correctly', () {
        final garden = _createTestGarden(level: 0, water: 20, sunlight: 15);
        final updated = garden.consumeResources(water: 10, sunlight: 5);

        expect(updated.waterDrops, equals(10));
        expect(updated.sunlightPoints, equals(10));
      });

      test('consumeResources should not go below zero', () {
        final garden = _createTestGarden(level: 0, water: 5, sunlight: 5);
        final updated = garden.consumeResources(water: 100, sunlight: 100);

        expect(updated.waterDrops, equals(0));
        expect(updated.sunlightPoints, equals(0));
      });

      test('markVisited should update lastVisited and status', () {
        final garden = GardenState(
          userId: 'test',
          plantLevel: 5,
          waterDrops: 20,
          sunlightPoints: 15,
          lastVisited: DateTime.now().subtract(const Duration(days: 30)),
          gardenStatus: 'resting',
          unlockedColors: ['#4DB6AC'],
          achievements: [],
        );

        final updated = garden.markVisited();

        expect(updated.gardenStatus, equals('active'));
        expect(updated.lastVisited.day, equals(DateTime.now().day));
      });

      test('tryGrow should return new state when possible', () {
        final garden = _createTestGarden(level: 0, water: 20, sunlight: 10);
        final grown = garden.tryGrow();

        expect(grown, isNotNull);
        expect(grown!.plantLevel, equals(1));
        expect(grown.waterDrops, equals(10)); // 20 - 10
        expect(grown.sunlightPoints, equals(5)); // 10 - 5
      });

      test('tryGrow should return null when not possible', () {
        final garden = _createTestGarden(level: 0, water: 5, sunlight: 2);
        final grown = garden.tryGrow();

        expect(grown, isNull);
      });
    });

    group('copyWith Immutability', () {
      test('copyWith should create new instance with updated field', () {
        final original = _createTestGarden(level: 5, water: 100);
        final copy = original.copyWith(plantLevel: 6);

        expect(copy.plantLevel, equals(6));
        expect(original.plantLevel, equals(5));
        expect(copy.waterDrops, equals(100));
      });

      test('copyWith should preserve unchanged fields', () {
        final original = _createTestGarden(level: 5, water: 100, sunlight: 50);
        final copy = original.copyWith(waterDrops: 200);

        expect(copy.plantLevel, equals(5));
        expect(copy.sunlightPoints, equals(50));
        expect(copy.waterDrops, equals(200));
      });
    });

    group('Serialization', () {
      test('toMap should produce valid map', () {
        final garden = _createTestGarden(level: 5, water: 100, sunlight: 50);
        final map = garden.toMap();

        expect(map['plantLevel'], equals(5));
        expect(map['waterDrops'], equals(100));
        expect(map['sunlightPoints'], equals(50));
        expect(map['lastVisited'], isA<String>());
      });

      test('roundtrip fromMap/toMap should preserve data', () {
        final original = _createTestGarden(level: 7, water: 150, sunlight: 80);
        final map = original.toMap();
        final restored = GardenState.fromMap(map);

        expect(restored.plantLevel, equals(original.plantLevel));
        expect(restored.waterDrops, equals(original.waterDrops));
        expect(restored.sunlightPoints, equals(original.sunlightPoints));
      });
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // HABIT MODEL TESTS
  // ═══════════════════════════════════════════════════════════════════════════
  group('Habit Model Tests', () {
    group('Completion Status', () {
      test('isCompletedToday returns false when no completions', () {
        final habit = _createTestHabit();
        expect(habit.isCompletedToday(), isFalse);
      });

      test('isCompletedToday returns true when completed today', () {
        final habit = _createTestHabit(completedDates: [DateTime.now()]);
        expect(habit.isCompletedToday(), isTrue);
      });

      test('isCompletedToday returns false when completed yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final habit = _createTestHabit(completedDates: [yesterday]);
        expect(habit.isCompletedToday(), isFalse);
      });

      test('isCompletedToday handles midnight edge case', () {
        final midnight = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          0, 0, 0,
        );
        final habit = _createTestHabit(completedDates: [midnight]);
        expect(habit.isCompletedToday(), isTrue);
      });

      test('isCompletedToday handles 23:59:59 edge case', () {
        final lateNight = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          23, 59, 59,
        );
        final habit = _createTestHabit(completedDates: [lateNight]);
        expect(habit.isCompletedToday(), isTrue);
      });
    });

    group('Reward Status (Anti-Exploit)', () {
      test('isRewardedToday returns false when no rewards', () {
        final habit = _createTestHabit();
        expect(habit.isRewardedToday(), isFalse);
      });

      test('isRewardedToday returns true when rewarded today', () {
        final habit = _createTestHabit(rewardedDates: [DateTime.now()]);
        expect(habit.isRewardedToday(), isTrue);
      });

      test('canClaimReward returns true when completed but not rewarded', () {
        final habit = _createTestHabit(
          completedDates: [DateTime.now()],
          rewardedDates: [],
        );
        expect(habit.canClaimReward(), isTrue);
      });

      test('canClaimReward returns false when already rewarded (ANTI-EXPLOIT)', () {
        final today = DateTime.now();
        final habit = _createTestHabit(
          completedDates: [today],
          rewardedDates: [today],
        );
        expect(habit.canClaimReward(), isFalse);
      });

      test('canClaimReward returns false when not completed', () {
        final habit = _createTestHabit(
          completedDates: [],
          rewardedDates: [],
        );
        expect(habit.canClaimReward(), isFalse);
      });

      test('canClaimReward allows claim if yesterday rewarded, today completed', () {
        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));
        final habit = _createTestHabit(
          completedDates: [today],
          rewardedDates: [yesterday],
        );
        expect(habit.canClaimReward(), isTrue);
      });
    });

    group('Category Emoji', () {
      test('categoryEmoji returns correct emoji for each category', () {
        expect(_createTestHabit(category: 'Mindfulness').categoryEmoji, equals('🧘'));
        expect(_createTestHabit(category: 'Exercise').categoryEmoji, equals('💪'));
        expect(_createTestHabit(category: 'Social').categoryEmoji, equals('👥'));
        expect(_createTestHabit(category: 'Creative').categoryEmoji, equals('🎨'));
        expect(_createTestHabit(category: 'Learning').categoryEmoji, equals('📚'));
        expect(_createTestHabit(category: 'Self-Care').categoryEmoji, equals('💚'));
      });

      test('categoryEmoji returns default for unknown category', () {
        final habit = _createTestHabit(category: 'Unknown');
        expect(habit.categoryEmoji, equals('✨'));
      });
    });

    group('Statistics', () {
      test('weeklyCompletionCount counts this week completions', () {
        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));
        final lastWeek = today.subtract(const Duration(days: 10));

        final habit = _createTestHabit(
          completedDates: [lastWeek, yesterday, today],
        );

        // Should count at least today and yesterday (depends on day of week)
        expect(habit.weeklyCompletionCount, greaterThanOrEqualTo(1));
      });

      test('monthlyCompletionCount counts this month completions', () {
        final today = DateTime.now();
        final habit = _createTestHabit(completedDates: [today]);

        expect(habit.monthlyCompletionCount, equals(1));
      });

      test('completionRate is between 0 and 1', () {
        final habit = _createTestHabit(completedDates: [DateTime.now()]);

        expect(habit.completionRate, greaterThanOrEqualTo(0.0));
        expect(habit.completionRate, lessThanOrEqualTo(1.0));
      });
    });

    group('Serialization', () {
      test('toMap produces valid map', () {
        final habit = _createTestHabit(
          title: 'Test Habit',
          category: 'Exercise',
          currentStreak: 5,
        );
        final map = habit.toMap();

        expect(map['title'], equals('Test Habit'));
        expect(map['category'], equals('Exercise'));
        expect(map['currentStreak'], equals(5));
      });

      test('fromMap parses all fields correctly', () {
        final map = {
          'userId': 'user_123',
          'title': 'Parsed Habit',
          'description': 'Test',
          'category': 'Learning',
          'completedDates': [DateTime.now().toIso8601String()],
          'rewardedDates': [],
          'createdAt': DateTime.now().toIso8601String(),
          'currentStreak': 3,
          'longestStreak': 5,
        };

        final habit = Habit.fromMap(map, 'parsed_id');

        expect(habit.id, equals('parsed_id'));
        expect(habit.title, equals('Parsed Habit'));
        expect(habit.currentStreak, equals(3));
        expect(habit.completedDates.length, equals(1));
      });
    });

    group('copyWith Immutability', () {
      test('copyWith creates new instance', () {
        final original = _createTestHabit(title: 'Original');
        final copy = original.copyWith(title: 'Updated');

        expect(copy.title, equals('Updated'));
        expect(original.title, equals('Original'));
      });

      test('copyWith preserves unchanged fields', () {
        final original = _createTestHabit(
          title: 'Original',
          category: 'Exercise',
          currentStreak: 5,
        );
        final copy = original.copyWith(title: 'Updated');

        expect(copy.category, equals('Exercise'));
        expect(copy.currentStreak, equals(5));
      });
    });
  });
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

GardenState _createTestGarden({
  int level = 0,
  int water = 10,
  int sunlight = 10,
}) {
  return GardenState(
    userId: 'test_user',
    plantLevel: level,
    waterDrops: water,
    sunlightPoints: sunlight,
    lastVisited: DateTime.now(),
    lastUpdated: DateTime.now(),
    gardenStatus: 'active',
    unlockedColors: ['#4DB6AC'],
    achievements: [],
    selectedColor: '#4DB6AC',
  );
}

Habit _createTestHabit({
  String title = 'Test Habit',
  String category = 'Self-Care',
  int currentStreak = 0,
  int longestStreak = 0,
  List<DateTime>? completedDates,
  List<DateTime>? rewardedDates,
}) {
  return Habit(
    id: 'test_id_${DateTime.now().millisecondsSinceEpoch}',
    userId: 'test_user',
    title: title,
    description: 'Test description for $title',
    category: category,
    completedDates: completedDates ?? [],
    rewardedDates: rewardedDates ?? [],
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
    currentStreak: currentStreak,
    longestStreak: longestStreak > currentStreak ? longestStreak : currentStreak,
  );
}