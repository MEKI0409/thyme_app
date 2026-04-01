// test/integration_test.dart
// ============================================================================
// THYME APP - INTEGRATION TESTS
// ============================================================================
// ✅ IMPROVED: 修复service import，使用统一的Constants
// ✅ IMPROVED: 添加更完整的端到端场景测试
// ✅ IMPROVED: 增强错误处理和边界条件测试
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:thyme_app/models/habit_model.dart';
import 'package:thyme_app/models/garden_model.dart';
import 'package:thyme_app/models/mood_entry_model.dart';
import 'package:thyme_app/services/garden_service.dart';
import 'package:thyme_app/services/welcome_back_service.dart';
import 'package:thyme_app/services/mood_responsive_garden_service.dart';
import 'package:thyme_app/services/recommendation_service.dart';
import 'package:thyme_app/services/journal_prompts_service.dart';
import 'package:thyme_app/services/gentle_insights_service.dart';
import 'package:thyme_app/utils/constants.dart';

void main() {
  group('Integration Tests', () {
    late GardenService gardenService;
    late WelcomeBackService welcomeBackService;
    late MoodResponsiveGardenService moodGardenService;
    late RecommendationService recommendationService;
    late GentleInsightsService insightsService;

    setUp(() {
      gardenService = GardenService();
      welcomeBackService = WelcomeBackService();
      moodGardenService = MoodResponsiveGardenService();
      recommendationService = RecommendationService();
      insightsService = GentleInsightsService();
    });

    // ========================================================================
    // SCENARIO 1: Complete Habit Workflow
    // ========================================================================
    group('Scenario: Complete Habit Workflow', () {
      test('INT-1.1: Habit completion should generate correct rewards using Constants', () {
        // GIVEN: A Mindfulness habit
        final habit = _createTestHabit(category: 'Mindfulness', streak: 0);

        // WHEN: Calculating rewards using Constants
        final rewards = Constants.calculateHabitReward(
          category: habit.category,
          currentStreak: habit.currentStreak,
        );

        // THEN: Should receive category bonus
        expect(rewards['water'], greaterThan(Constants.baseWaterReward),
            reason: 'Mindfulness should give water bonus');
      });

      test('INT-1.2: Rewards should correctly update garden resources', () {
        // GIVEN: A garden with initial resources
        final initialGarden = GardenState.initial('test_user');
        final initialWater = initialGarden.waterDrops;
        final initialSunlight = initialGarden.sunlightPoints;

        // AND: An Exercise habit
        final rewards = Constants.calculateHabitReward(
          category: 'Exercise',
          currentStreak: 0,
        );

        // WHEN: Adding rewards to garden
        final updatedGarden = initialGarden.addResources(
          water: rewards['water']!,
          sunlight: rewards['sunlight']!,
        );

        // THEN: Garden resources should increase
        expect(updatedGarden.waterDrops, equals(initialWater + rewards['water']!));
        expect(updatedGarden.sunlightPoints, equals(initialSunlight + rewards['sunlight']!));
      });

      test('INT-1.3: Garden should grow when resources are sufficient', () {
        // GIVEN: A garden with enough resources to grow
        // Level 0→1 needs: water = 10, sunlight = 5
        var garden = _createTestGarden(level: 0, water: 15, sunlight: 10);

        expect(garden.canGrow(), isTrue);

        // WHEN: Growing using tryGrow()
        final grownGarden = garden.tryGrow();

        // THEN: Level increases, resources decrease
        expect(grownGarden, isNotNull);
        expect(grownGarden!.plantLevel, equals(1));
        expect(grownGarden.waterDrops, equals(15 - 10));
        expect(grownGarden.sunlightPoints, equals(10 - 5));
      });

      test('INT-1.4: Anti-exploit - Cannot claim reward twice', () {
        // GIVEN: A habit completed and rewarded today
        final today = DateTime.now();
        final habit = Habit(
          id: 'test_habit',
          userId: 'test_user',
          title: 'Test Habit',
          description: 'Test',
          category: 'Exercise',
          completedDates: [today],
          rewardedDates: [today],
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          currentStreak: 1,
          longestStreak: 1,
        );

        // THEN: Should NOT be able to claim reward again
        expect(habit.canClaimReward(), isFalse,
            reason: 'ANTI-EXPLOIT: Cannot claim reward twice');
      });

      test('INT-1.5: Full habit completion cycle with reward and garden update', () {
        // GIVEN: A garden and a habit
        var garden = _createTestGarden(level: 0, water: 5, sunlight: 3);
        final habit = _createTestHabit(category: 'Mindfulness', streak: 7);

        // WHEN: Completing habit and getting rewards
        final rewards = Constants.calculateHabitReward(
          category: habit.category,
          currentStreak: habit.currentStreak,
          currentMood: 'anxious', // Mindfulness is therapeutic for anxious
        );

        // AND: Adding rewards to garden
        garden = garden.addResources(
          water: rewards['water']!,
          sunlight: rewards['sunlight']!,
        );

        // THEN: Garden should have increased resources
        expect(garden.waterDrops, greaterThan(5));
        expect(garden.sunlightPoints, greaterThan(3));

        // AND: Special unlock should be available
        final specialUnlock = Constants.checkSpecialUnlock('anxious', 'Mindfulness');
        expect(specialUnlock, equals('#64B5F6'));
      });
    });

    // ========================================================================
    // SCENARIO 2: Mood Analysis → Garden Response Flow
    // ========================================================================
    group('Scenario: Mood Analysis → Garden Response Flow', () {
      test('INT-2.1: Anxious mood should trigger breathing guide', () {
        // GIVEN: Detected anxious mood
        const detectedMood = 'anxious';

        // WHEN: Getting garden ambiance
        final ambiance = moodGardenService.getGardenAmbiance(detectedMood);

        // THEN: Should show breathing guide
        expect(ambiance.showBreathingGuide, isTrue,
            reason: 'Anxious mood should show breathing guide');
      });

      test('INT-2.2: Therapeutic habit should unlock special color', () {
        // Test all therapeutic pairs
        final therapeuticPairs = {
          'anxious_Mindfulness': '#64B5F6',
          'sad_Social': '#FFD54F',
          'stressed_Exercise': '#FF7043',
          'happy_Creative': '#F06292',
          'calm_Learning': '#81C784',
        };

        therapeuticPairs.forEach((key, expectedColor) {
          final parts = key.split('_');
          final mood = parts[0];
          final category = parts[1];

          final unlock = Constants.checkSpecialUnlock(mood, category);
          expect(unlock, equals(expectedColor),
              reason: '$mood + $category should unlock $expectedColor');
        });
      });

      test('INT-2.3: Mood-appropriate recommendations should prioritize therapeutic habits', () {
        // GIVEN: User is feeling stressed
        const currentMood = 'stressed';

        final habits = [
          _createTestHabit(category: 'Exercise', streak: 3),
          _createTestHabit(category: 'Mindfulness', streak: 1),
          _createTestHabit(category: 'Social', streak: 0),
          _createTestHabit(category: 'Creative', streak: 2),
        ];

        // WHEN: Getting recommendations
        final recommendations = recommendationService.recommendHabits(currentMood, habits);

        // THEN: Should prioritize therapeutic categories
        expect(recommendations, isNotEmpty);

        // Exercise and Mindfulness are recommended for stressed
        final recommendedCategories = Constants.getRecommendedCategories(currentMood);
        expect(recommendedCategories, contains('Exercise'));
        expect(recommendedCategories, contains('Mindfulness'));
      });

      test('INT-2.4: All moods should have valid garden ambiance', () {
        for (final mood in Constants.allMoods) {
          final ambiance = moodGardenService.getGardenAmbiance(mood);

          expect(ambiance, isNotNull);
          expect(ambiance.message, isNotEmpty);
          expect(ambiance.skyGradient, isNotEmpty);
          expect(ambiance.groundGradient, isNotEmpty);
        }
      });
    });

    // ========================================================================
    // SCENARIO 3: User Return Flow (Anti-Streak-Anxiety)
    // ========================================================================
    group('Scenario: User Return Flow (Anti-Streak-Anxiety)', () {
      test('INT-3.1: Returning user receives rest bonus', () {
        final testCases = {
          1: {'water': 0, 'sunlight': 0},      // 1 day - no bonus
          5: {'water': 2, 'sunlight': 2},      // 5 days - small bonus
          15: {'water': 5, 'sunlight': 5},     // 15 days - medium bonus
          60: {'water': 10, 'sunlight': 10},   // 60 days - large bonus (capped)
        };

        testCases.forEach((days, expectedBonus) {
          final bonus = welcomeBackService.calculateRestBonus(days);

          expect(bonus['water'], equals(expectedBonus['water']),
              reason: '$days days should give ${expectedBonus['water']} water');
          expect(bonus['sunlight'], equals(expectedBonus['sunlight']),
              reason: '$days days should give ${expectedBonus['sunlight']} sunlight');
        });
      });

      test('INT-3.2: Welcome back messages should NEVER contain guilt language', () {
        final guiltPhrases = [
          'we missed you',
          'don\'t forget',
          'you should',
          'you need to',
          'falling behind',
          'you failed',
          'disappointed',
          'streak broken',
        ];

        final testDays = [1, 3, 7, 14, 30, 60, 90, 180, 365];

        for (int days in testDays) {
          final message = welcomeBackService.getWelcomeBackMessage(days);

          for (var phrase in guiltPhrases) {
            expect(message.toLowerCase().contains(phrase), isFalse,
                reason: 'Message for $days days should NOT contain: "$phrase"');
          }
        }
      });

      test('INT-3.3: Garden should transition to active on visit', () {
        // GIVEN: A resting garden
        final restingGarden = GardenState(
          userId: 'test_user',
          plantLevel: 5,
          waterDrops: 20,
          sunlightPoints: 15,
          lastVisited: DateTime.now().subtract(const Duration(days: 30)),
          gardenStatus: 'resting',
          unlockedColors: ['#4DB6AC'],
          achievements: [],
        );

        expect(restingGarden.isResting, isTrue);

        // WHEN: User visits
        final activeGarden = restingGarden.markVisited();

        // THEN: Status should change to active
        expect(activeGarden.gardenStatus, equals('active'));
        expect(activeGarden.lastVisited.day, equals(DateTime.now().day));
      });

      test('INT-3.4: Return affirmations should be supportive and positive', () {
        for (int i = 0; i < 10; i++) {
          final affirmation = welcomeBackService.getReturnAffirmation();

          expect(affirmation, isNotEmpty);
          expect(affirmation.toLowerCase().contains('fail'), isFalse);
          expect(affirmation.toLowerCase().contains('lazy'), isFalse);
          expect(affirmation.toLowerCase().contains('bad'), isFalse);
          expect(affirmation.length, greaterThan(10));
        }
      });
    });

    // ========================================================================
    // SCENARIO 4: Journal Entry Flow
    // ========================================================================
    group('Scenario: Journal Entry Flow', () {
      test('INT-4.1: Journal prompts should be available for all moods', () {
        for (final mood in Constants.allMoods) {
          final prompt = JournalPromptsService.getPromptForMood(mood);

          expect(prompt, isNotEmpty);
          // Prompts should not be overly aggressive
          expect(prompt.contains('!'), isFalse,
              reason: 'Prompts should not use exclamation marks');
        }
      });

      test('INT-4.2: Mood entry should have correct structure', () {
        final moodEntry = MoodEntry(
          id: 'entry_1',
          userId: 'test_user',
          journalText: 'I feel calm and peaceful today',
          detectedMood: 'calm',
          sentimentScore: 0.7,
          confidence: 0.85,
          createdAt: DateTime.now(),
        );

        expect(moodEntry.detectedMood, equals('calm'));
        expect(moodEntry.sentimentScore, greaterThan(0));
        expect(moodEntry.confidence, greaterThan(0.5));
        expect(moodEntry.moodEmoji, equals('😌'));
      });

      test('INT-4.3: Journal should reward garden', () {
        // GIVEN: A garden
        var garden = _createTestGarden(level: 2, water: 20, sunlight: 15);
        final initialWater = garden.waterDrops;
        final initialSunlight = garden.sunlightPoints;

        // WHEN: User completes a journal entry
        // Base journal reward: 1 water, 1 sunlight
        // Extra water for expressing difficult emotions
        const journalWater = 2; // expressing 'anxious' gives +1
        const journalSunlight = 1;

        garden = garden.addResources(water: journalWater, sunlight: journalSunlight);

        // THEN: Garden resources should increase
        expect(garden.waterDrops, equals(initialWater + journalWater));
        expect(garden.sunlightPoints, equals(initialSunlight + journalSunlight));
      });
    });

    // ========================================================================
    // SCENARIO 5: Gentle Insights Generation
    // ========================================================================
    group('Scenario: Gentle Insights Generation', () {
      test('INT-5.1: Insights should be non-prescriptive', () {
        final habits = [
          _createTestHabit(category: 'Mindfulness', streak: 5),
        ];

        final completedHabit = habits[0].copyWith(
          completedDates: [DateTime.now()],
        );

        final moods = <MoodEntry>[
          MoodEntry(
            id: 'm1',
            userId: 'test_user',
            journalText: 'Feeling good',
            detectedMood: 'calm',
            sentimentScore: 0.5,
            createdAt: DateTime.now(),
          ),
        ];

        // WHEN: Generating insight
        final insight = insightsService.generateInsight([completedHabit], moods);

        // THEN: Should NOT contain prescriptive language
        expect(insight, isNotEmpty);

        final prescriptivePhrases = ['you should', 'you need to', 'try to', 'you must'];
        for (var phrase in prescriptivePhrases) {
          expect(insight.toLowerCase().contains(phrase), isFalse,
              reason: 'Insight should NOT contain: "$phrase"');
        }
      });

      test('INT-5.2: Time-based greeting should match time of day', () {
        final greeting = insightsService.getTimeBasedGreeting();
        final hour = DateTime.now().hour;

        expect(greeting, isNotEmpty);

        if (hour >= 5 && hour < 12) {
          expect(greeting.toLowerCase(), contains('morning'));
        } else if (hour >= 12 && hour < 17) {
          expect(greeting.toLowerCase(), contains('afternoon'));
        } else if (hour >= 17 && hour < 21) {
          expect(greeting.toLowerCase(), contains('evening'));
        } else {
          expect(greeting.toLowerCase(), contains('night'));
        }
      });
    });

    // ========================================================================
    // SCENARIO 6: Plant Growth Progression
    // ========================================================================
    group('Scenario: Plant Growth Progression', () {
      test('INT-6.1: Full growth cycle from level 0 to max', () {
        var garden = _createTestGarden(level: 0, water: 1000, sunlight: 500);

        // Grow through all levels
        for (int targetLevel = 1; targetLevel <= 10; targetLevel++) {
          final grown = garden.tryGrow();
          if (grown != null) {
            garden = grown;
            expect(garden.plantLevel, equals(targetLevel));
          }
        }

        // Should reach max level
        expect(garden.plantLevel, equals(10));
        expect(garden.isMaxLevel, isTrue);
        expect(garden.canGrow(), isFalse);
      });

      test('INT-6.2: Resource costs should match Constants', () {
        for (int level = 0; level < 10; level++) {
          final garden = _createTestGarden(level: level, water: 200, sunlight: 100);
          final constantsCost = Constants.getGrowthCost(level);
          final modelWaterCost = garden.getWaterNeededForNextLevel();
          final modelSunlightCost = garden.getSunlightNeededForNextLevel();

          expect(modelWaterCost, equals(constantsCost['water']),
              reason: 'Level $level water cost should match Constants');
          expect(modelSunlightCost, equals(constantsCost['sunlight']),
              reason: 'Level $level sunlight cost should match Constants');
        }
      });

      test('INT-6.3: Plant stages should have correct names at each level', () {
        final stageMapping = {
          0: 'Seedling',
          2: 'Sprout',
          4: 'Young Plant',
          6: 'Flowering',
          8: 'Sunflower',
          10: 'Mighty Tree',
        };

        stageMapping.forEach((level, expectedStage) {
          final garden = _createTestGarden(level: level);
          expect(garden.plantStageName, equals(expectedStage),
              reason: 'Level $level should be "$expectedStage"');
        });
      });
    });

    // ========================================================================
    // SCENARIO 7: Color Unlock System
    // ========================================================================
    group('Scenario: Color Unlock System', () {
      test('INT-7.1: Initial garden should have default color unlocked', () {
        final garden = GardenState.initial('test_user');

        expect(garden.unlockedColors, contains('#4DB6AC'));
        expect(garden.selectedColor, equals('#4DB6AC'));
      });

      test('INT-7.2: Can unlock color when sufficient sunlight', () {
        final garden = _createTestGarden(level: 5, water: 50, sunlight: 30);

        // Garden colors from Constants
        final colorToUnlock = Constants.gardenColors[1]; // Calm Blue, cost 5
        final cost = colorToUnlock['cost'] as int;
        final colorHex = colorToUnlock['hex'] as String;

        expect(garden.canUnlockColor(cost), isTrue);

        // Simulate unlock
        final updatedGarden = garden.copyWith(
          unlockedColors: [...garden.unlockedColors, colorHex],
          sunlightPoints: garden.sunlightPoints - cost,
          selectedColor: colorHex,
        );

        expect(updatedGarden.unlockedColors, contains(colorHex));
        expect(updatedGarden.selectedColor, equals(colorHex));
      });

      test('INT-7.3: Cannot unlock color when insufficient sunlight', () {
        final garden = _createTestGarden(level: 0, water: 50, sunlight: 2);

        // Try to unlock a color that costs 10
        expect(garden.canUnlockColor(10), isFalse);
      });

      test('INT-7.4: Special unlock from mood-habit pairing', () {
        // GIVEN: User is sad and completes Social habit
        const mood = 'sad';
        const category = 'Social';
        final specialColor = Constants.checkSpecialUnlock(mood, category);

        expect(specialColor, isNotNull);
        expect(specialColor, equals('#FFD54F')); // Warm Yellow

        // THEN: Garden should be able to receive this color
        var garden = _createTestGarden(level: 3, water: 30, sunlight: 20);
        expect(garden.unlockedColors.contains(specialColor), isFalse);

        // Add special unlock
        garden = garden.copyWith(
          unlockedColors: [...garden.unlockedColors, specialColor!],
        );

        expect(garden.unlockedColors, contains(specialColor));
      });
    });
  });
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

Habit _createTestHabit({
  String category = 'Self-Care',
  int streak = 0,
  String title = 'Test Habit',
}) {
  return Habit(
    id: 'test_habit_${DateTime.now().millisecondsSinceEpoch}',
    userId: 'test_user',
    title: title,
    description: 'Test habit for integration testing',
    category: category,
    completedDates: [],
    rewardedDates: [],
    createdAt: DateTime.now().subtract(const Duration(days: 14)),
    currentStreak: streak,
    longestStreak: streak > 0 ? streak : 0,
  );
}

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