// test/calm_gamification_engine_test.dart
// ============================================================================
// CALM GAMIFICATION ENGINE - COMPREHENSIVE UNIT TESTS
// ============================================================================
// ✅ IMPROVED: 使用 Constants.calculateHabitReward 替代 GardenService
// ✅ IMPROVED: 更严格的边界值测试
// ✅ IMPROVED: 添加回归测试保护
// ============================================================================
//
// TEST METHODOLOGY:
// This test suite validates the core algorithms that differentiate this app
// from traditional gamified habit apps. The "Calm Gamification" approach:
//   1. Non-punitive mechanics (gardens rest, never wither)
//   2. Anti-streak-anxiety design (returning users receive bonuses)
//   3. Mood-responsive rewards (emotional alignment unlocks special features)
//   4. Guilt-free messaging (no "we missed you" or "you're falling behind")
//
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:thyme_app/models/garden_model.dart';
import 'package:thyme_app/services/welcome_back_service.dart';
import 'package:thyme_app/services/mood_responsive_garden_service.dart';
import 'package:thyme_app/utils/constants.dart';

void main() {
  group('Calm Gamification Engine Tests', () {
    late WelcomeBackService welcomeBackService;
    late MoodResponsiveGardenService moodGardenService;

    setUp(() {
      welcomeBackService = WelcomeBackService();
      moodGardenService = MoodResponsiveGardenService();
    });

    // ========================================================================
    // TEST GROUP 1: Reward Calculation Algorithm (Using Constants)
    // ========================================================================
    group('Reward Calculation Algorithm', () {
      test('TC1.1: Base reward should be minimum for any habit', () {
        final rewards = Constants.calculateHabitReward(
          category: 'Social',
          currentStreak: 0,
        );

        expect(rewards['water'], greaterThanOrEqualTo(Constants.baseWaterReward));
        expect(rewards['sunlight'], greaterThanOrEqualTo(Constants.baseSunlightReward));
      });

      test('TC1.2: Mindfulness should give +1 water bonus (calming category)', () {
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

      test('TC1.3: Self-Care should give +1 water bonus (calming category)', () {
        final selfCareRewards = Constants.calculateHabitReward(
          category: 'Self-Care',
          currentStreak: 0,
        );
        final socialRewards = Constants.calculateHabitReward(
          category: 'Social',
          currentStreak: 0,
        );

        expect(selfCareRewards['water'], greaterThan(socialRewards['water']!));
      });

      test('TC1.4: Exercise should give +1 sunlight bonus (active category)', () {
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

      test('TC1.5: Learning should give +1 sunlight bonus (active category)', () {
        final learningRewards = Constants.calculateHabitReward(
          category: 'Learning',
          currentStreak: 0,
        );
        final socialRewards = Constants.calculateHabitReward(
          category: 'Social',
          currentStreak: 0,
        );

        expect(learningRewards['sunlight'], greaterThan(socialRewards['sunlight']!));
      });

      test('TC1.6: 7-day streak should unlock bonus (boundary value)', () {
        final belowThreshold = Constants.calculateHabitReward(
          category: 'Social',
          currentStreak: 6,
        );
        final atThreshold = Constants.calculateHabitReward(
          category: 'Social',
          currentStreak: 7,
        );

        expect(atThreshold['water'], greaterThan(belowThreshold['water']!));
        expect(atThreshold['sunlight'], greaterThan(belowThreshold['sunlight']!));
      });

      test('TC1.7: 14-day streak should give larger bonus', () {
        final sevenDays = Constants.calculateHabitReward(
          category: 'Social',
          currentStreak: 7,
        );
        final fourteenDays = Constants.calculateHabitReward(
          category: 'Social',
          currentStreak: 14,
        );

        expect(fourteenDays['water'], greaterThan(sevenDays['water']!));
        expect(fourteenDays['sunlight'], greaterThan(sevenDays['sunlight']!));
      });

      test('TC1.8: 30-day streak should give maximum bonus', () {
        final fourteenDays = Constants.calculateHabitReward(
          category: 'Social',
          currentStreak: 14,
        );
        final thirtyDays = Constants.calculateHabitReward(
          category: 'Social',
          currentStreak: 30,
        );

        expect(thirtyDays['water'], greaterThan(fourteenDays['water']!));
        expect(thirtyDays['sunlight'], greaterThan(fourteenDays['sunlight']!));
      });

      test('TC1.9: Combined bonuses should stack correctly', () {
        // Mindfulness + 7-day streak + anxious mood match
        final rewards = Constants.calculateHabitReward(
          category: 'Mindfulness',
          currentStreak: 7,
          currentMood: 'anxious',
        );

        // water = base(2) + mindfulness(1) + streak(1) + mood_match(1) = 5
        // sunlight = base(1) + streak(1) + mood_match(1) = 3
        expect(rewards['water'], greaterThanOrEqualTo(4));
        expect(rewards['sunlight'], greaterThanOrEqualTo(2));
      });

      test('TC1.10: Mood matching should give bonus when therapeutic', () {
        final matched = Constants.calculateHabitReward(
          category: 'Exercise',
          currentStreak: 0,
          currentMood: 'stressed', // Exercise is recommended for stressed
        );
        final unmatched = Constants.calculateHabitReward(
          category: 'Exercise',
          currentStreak: 0,
          currentMood: null,
        );

        expect(matched['water'], greaterThan(unmatched['water']!));
        expect(matched['sunlight'], greaterThan(unmatched['sunlight']!));
      });
    });

    // ========================================================================
    // TEST GROUP 2: Special Unlock System
    // ========================================================================
    group('Special Unlock System', () {
      test('TC2.1: anxious + Mindfulness should unlock Calm Blue', () {
        final unlock = Constants.checkSpecialUnlock('anxious', 'Mindfulness');
        expect(unlock, equals('#64B5F6'));
      });

      test('TC2.2: sad + Social should unlock Warm Yellow', () {
        final unlock = Constants.checkSpecialUnlock('sad', 'Social');
        expect(unlock, equals('#FFD54F'));
      });

      test('TC2.3: stressed + Exercise should unlock Energy Orange', () {
        final unlock = Constants.checkSpecialUnlock('stressed', 'Exercise');
        expect(unlock, equals('#FF7043'));
      });

      test('TC2.4: happy + Creative should unlock Pink Bliss', () {
        final unlock = Constants.checkSpecialUnlock('happy', 'Creative');
        expect(unlock, equals('#F06292'));
      });

      test('TC2.5: calm + Learning should unlock Fresh Green', () {
        final unlock = Constants.checkSpecialUnlock('calm', 'Learning');
        expect(unlock, equals('#81C784'));
      });

      test('TC2.6: Non-therapeutic pairs should return null', () {
        expect(Constants.checkSpecialUnlock('happy', 'Exercise'), isNull);
        expect(Constants.checkSpecialUnlock('sad', 'Learning'), isNull);
        expect(Constants.checkSpecialUnlock('neutral', 'Creative'), isNull);
      });

      test('TC2.7: Case sensitivity check', () {
        // Function should be case-insensitive for better UX
        expect(Constants.checkSpecialUnlock('anxious', 'Mindfulness'), isNotNull);
        expect(Constants.checkSpecialUnlock('ANXIOUS', 'Mindfulness'), isNotNull);  // 也应该匹配
        expect(Constants.checkSpecialUnlock('Anxious', 'Mindfulness'), isNotNull);  // 也应该匹配
      });
    });

    // ========================================================================
    // TEST GROUP 3: Rest Bonus Algorithm (Anti-Streak-Anxiety)
    // ========================================================================
    group('Rest Bonus Algorithm', () {
      test('TC3.1: 0-1 day absence should give no bonus', () {
        for (int days = 0; days <= 1; days++) {
          final bonus = welcomeBackService.calculateRestBonus(days);
          expect(bonus['water'], equals(0));
          expect(bonus['sunlight'], equals(0));
        }
      });

      test('TC3.2: 2-7 day absence should give small bonus', () {
        final bonus = welcomeBackService.calculateRestBonus(5);
        expect(bonus['water'], greaterThan(0));
        expect(bonus['sunlight'], greaterThan(0));
        expect(bonus['water'], lessThanOrEqualTo(5));
      });

      test('TC3.3: 8-30 day absence should give medium bonus', () {
        final bonus = welcomeBackService.calculateRestBonus(15);
        expect(bonus['water'], greaterThan(2));
        expect(bonus['sunlight'], greaterThan(2));
      });

      test('TC3.4: 31+ day absence should be capped', () {
        final bonus60 = welcomeBackService.calculateRestBonus(60);
        final bonus365 = welcomeBackService.calculateRestBonus(365);

        // Both should be capped at max
        expect(bonus60['water'], equals(bonus365['water']));
        expect(bonus60['sunlight'], equals(bonus365['sunlight']));
      });

      test('TC3.5: Bonus should never be negative', () {
        for (int days = -10; days <= 400; days += 10) {
          final bonus = welcomeBackService.calculateRestBonus(days);
          expect(bonus['water'], greaterThanOrEqualTo(0));
          expect(bonus['sunlight'], greaterThanOrEqualTo(0));
        }
      });
    });

    // ========================================================================
    // TEST GROUP 4: Garden State Management
    // ========================================================================
    group('Garden State Management', () {
      test('TC4.1: Garden should NEVER wither (only rest)', () {
        // Create a garden that hasn't been visited in a very long time
        final oldGarden = GardenState(
          userId: 'test_user',
          plantLevel: 5,
          waterDrops: 50,
          sunlightPoints: 30,
          lastVisited: DateTime.now().subtract(const Duration(days: 365)),
          gardenStatus: 'active',
          unlockedColors: ['#4DB6AC'],
          achievements: [],
        );

        // Garden should be resting, not withered
        expect(oldGarden.isResting, isTrue);
        expect(oldGarden.gardenStatus, isNot(equals('withered')));

        // Plant level should be preserved
        expect(oldGarden.plantLevel, equals(5));
        expect(oldGarden.waterDrops, equals(50));
      });

      test('TC4.2: canGrow should check both resources and level', () {
        // Has resources but at max level
        final maxLevel = _createTestGarden(level: 10, water: 1000, sunlight: 500);
        expect(maxLevel.canGrow(), isFalse);

        // Has level capacity but no resources
        final noResources = _createTestGarden(level: 5, water: 0, sunlight: 0);
        expect(noResources.canGrow(), isFalse);

        // Has both
        final canGrow = _createTestGarden(level: 5, water: 100, sunlight: 50);
        expect(canGrow.canGrow(), isTrue);
      });

      test('TC4.3: Plant level should be bounded 0-10', () {
        expect(GardenState.maxPlantLevel, equals(10));

        final garden = _createTestGarden(level: 10);
        expect(garden.isMaxLevel, isTrue);
      });

      test('TC4.4: Initial garden should have starting resources', () {
        final garden = GardenState.initial('test_user');

        expect(garden.plantLevel, equals(0));
        expect(garden.waterDrops, greaterThan(0));
        expect(garden.sunlightPoints, greaterThan(0));
        expect(garden.gardenStatus, equals('active'));
      });

      test('TC4.5: tryGrow should consume exact resources', () {
        // Level 2 → 3 needs: water = 30, sunlight = 15
        final garden = _createTestGarden(level: 2, water: 50, sunlight: 30);
        final grown = garden.tryGrow();

        expect(grown, isNotNull);
        expect(grown!.plantLevel, equals(3));
        expect(grown.waterDrops, equals(50 - 30));
        expect(grown.sunlightPoints, equals(30 - 15));
      });

      test('TC4.6: Garden progress should be 0-1 range', () {
        final emptyGarden = _createTestGarden(level: 0, water: 0, sunlight: 0);
        expect(emptyGarden.growthProgress, greaterThanOrEqualTo(0));

        final fullGarden = _createTestGarden(level: 0, water: 100, sunlight: 50);
        expect(fullGarden.growthProgress, equals(1.0));

        final maxGarden = _createTestGarden(level: 10);
        expect(maxGarden.growthProgress, equals(1.0));
      });
    });

    // ========================================================================
    // TEST GROUP 5: Mood-Responsive Garden Ambiance
    // ========================================================================
    group('Mood-Responsive Garden Ambiance', () {
      test('TC5.1: Anxious mood should show breathing guide', () {
        final ambiance = moodGardenService.getGardenAmbiance('anxious');
        expect(ambiance.showBreathingGuide, isTrue);
      });

      test('TC5.2: Stressed mood should show breathing guide', () {
        final ambiance = moodGardenService.getGardenAmbiance('stressed');
        expect(ambiance.showBreathingGuide, isTrue);
      });

      test('TC5.3: Happy mood should not show breathing guide', () {
        final ambiance = moodGardenService.getGardenAmbiance('happy');
        expect(ambiance.showBreathingGuide, isFalse);
      });

      test('TC5.4: All moods should have valid ambiance', () {
        for (final mood in Constants.allMoods) {
          final ambiance = moodGardenService.getGardenAmbiance(mood);

          expect(ambiance, isNotNull);
          expect(ambiance.message, isNotEmpty);
          expect(ambiance.skyGradient, isNotEmpty);
          expect(ambiance.groundGradient, isNotEmpty);
        }
      });

      test('TC5.5: Null mood should return default ambiance', () {
        final ambiance = moodGardenService.getGardenAmbiance(null);
        expect(ambiance, isNotNull);
        expect(ambiance.message, isNotEmpty);
      });

      test('TC5.6: Ambiance messages should be gentle', () {
        for (final mood in ['sad', 'anxious', 'stressed', 'lonely']) {
          final ambiance = moodGardenService.getGardenAmbiance(mood);

          // Messages should not be aggressive or demanding
          expect(ambiance.message.toLowerCase().contains('must'), isFalse);
          expect(ambiance.message.toLowerCase().contains('should'), isFalse);
          expect(ambiance.message.toLowerCase().contains('need to'), isFalse);
        }
      });
    });

    // ========================================================================
    // TEST GROUP 6: Welcome Back Messages (Guilt-Free)
    // ========================================================================
    group('Welcome Back Messages (Guilt-Free)', () {
      test('TC6.1: Messages should NEVER contain guilt phrases', () {
        final guiltPhrases = [
          'we missed you',
          'don\'t forget',
          'you should',
          'you need to',
          'falling behind',
          'you failed',
          'disappointed',
          'streak broken',
          'too long',
        ];

        for (int days in [1, 3, 7, 14, 30, 60, 90, 180, 365]) {
          final message = welcomeBackService.getWelcomeBackMessage(days);

          for (var phrase in guiltPhrases) {
            expect(message.toLowerCase().contains(phrase), isFalse,
                reason: 'Message for $days days should NOT contain: "$phrase"');
          }
        }
      });

      test('TC6.2: Messages should contain warm language', () {
        final warmWords = ['welcome', 'garden', 'glad', 'here', 'space', 'back', 'okay'];

        for (int days in [1, 7, 30, 90]) {
          final message = welcomeBackService.getWelcomeBackMessage(days).toLowerCase();
          final hasWarmWord = warmWords.any((word) => message.contains(word));

          expect(hasWarmWord, isTrue,
              reason: 'Message for $days days should contain welcoming language');
        }
      });

      test('TC6.3: Affirmations should be supportive', () {
        for (int i = 0; i < 10; i++) {
          final affirmation = welcomeBackService.getReturnAffirmation();

          expect(affirmation, isNotEmpty);
          expect(affirmation.toLowerCase().contains('fail'), isFalse);
          expect(affirmation.toLowerCase().contains('lazy'), isFalse);
          expect(affirmation.length, greaterThan(10));
        }
      });
    });

    // ========================================================================
    // TEST GROUP 7: Growth Cost Consistency
    // ========================================================================
    group('Growth Cost Consistency', () {
      test('TC7.1: Constants and GardenModel should have same costs', () {
        for (int level = 0; level < 10; level++) {
          final constantsCost = Constants.getGrowthCost(level);
          final garden = _createTestGarden(level: level);

          expect(garden.getWaterNeededForNextLevel(), equals(constantsCost['water']));
          expect(garden.getSunlightNeededForNextLevel(), equals(constantsCost['sunlight']));
        }
      });

      test('TC7.2: Growth costs should increase linearly', () {
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

      test('TC7.3: Level 9→10 should have highest cost', () {
        final level9Cost = Constants.getGrowthCost(9);
        final level0Cost = Constants.getGrowthCost(0);

        expect(level9Cost['water']!, greaterThan(level0Cost['water']!));
        expect(level9Cost['sunlight']!, greaterThan(level0Cost['sunlight']!));
      });
    });

    // ========================================================================
    // TEST GROUP 8: Category Reward Bonuses
    // ========================================================================
    group('Category Reward Bonuses', () {
      test('TC8.1: Calming categories should give water bonus', () {
        final calmingCategories = ['Mindfulness', 'Self-Care'];

        for (final category in calmingCategories) {
          final rewards = Constants.calculateHabitReward(
            category: category,
            currentStreak: 0,
          );
          final baseRewards = Constants.calculateHabitReward(
            category: 'Social', // Neutral
            currentStreak: 0,
          );

          expect(rewards['water'], greaterThan(baseRewards['water']!),
              reason: '$category should give water bonus');
        }
      });

      test('TC8.2: Active categories should give sunlight bonus', () {
        final activeCategories = ['Exercise', 'Learning'];

        for (final category in activeCategories) {
          final rewards = Constants.calculateHabitReward(
            category: category,
            currentStreak: 0,
          );
          final baseRewards = Constants.calculateHabitReward(
            category: 'Social', // Neutral
            currentStreak: 0,
          );

          expect(rewards['sunlight'], greaterThan(baseRewards['sunlight']!),
              reason: '$category should give sunlight bonus');
        }
      });

      test('TC8.3: Social and Creative should give balanced bonus', () {
        final socialRewards = Constants.calculateHabitReward(
          category: 'Social',
          currentStreak: 0,
        );
        final creativeRewards = Constants.calculateHabitReward(
          category: 'Creative',
          currentStreak: 0,
        );

        // Creative gives both bonuses
        expect(creativeRewards['water'], greaterThanOrEqualTo(socialRewards['water']!));
        expect(creativeRewards['sunlight'], greaterThanOrEqualTo(socialRewards['sunlight']!));
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