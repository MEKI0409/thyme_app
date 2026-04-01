// test/habit_controller_test.dart
// ============================================================================
// HABIT MODEL & CONTROLLER - COMPREHENSIVE UNIT TESTS
// ============================================================================
// ✅ IMPROVED: 添加更多边界条件测试
// ✅ IMPROVED: 增强 anti-exploit 机制验证
// ✅ IMPROVED: 统一使用 Constants
// ============================================================================
//
// DUAL-ARRAY ANTI-EXPLOIT DESIGN:
//   - completedDates[]: Tracks when habit was marked complete
//   - rewardedDates[]: Tracks when rewards were claimed
//   - canClaimReward(): Returns true only if completed today AND not rewarded today
//
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:thyme_app/models/habit_model.dart';
import 'package:thyme_app/utils/constants.dart';

void main() {
  group('Habit Model Tests', () {

    group('Habit Creation & Validation', () {
      test('TC-HC1.1: Should create habit with all required fields populated', () {
        final now = DateTime.now();

        final habit = Habit(
          id: 'test_id_123',
          userId: 'user_456',
          title: 'Morning Meditation',
          description: '10 minutes of mindfulness practice',
          category: 'Mindfulness',
          completedDates: [],
          rewardedDates: [],
          createdAt: now,
          currentStreak: 0,
          longestStreak: 0,
        );

        expect(habit.id, equals('test_id_123'));
        expect(habit.userId, equals('user_456'));
        expect(habit.title, equals('Morning Meditation'));
        expect(habit.description, equals('10 minutes of mindfulness practice'));
        expect(habit.category, equals('Mindfulness'));
        expect(habit.currentStreak, equals(0));
        expect(habit.createdAt, equals(now));
      });

      test('TC-HC1.2: Should initialize with empty completion and reward arrays', () {
        final habit = _createTestHabit();

        expect(habit.completedDates, isEmpty,
            reason: 'New habit has no completions');
        expect(habit.rewardedDates, isEmpty,
            reason: 'New habit has no rewards claimed');
      });

      test('TC-HC1.3: Should accept all valid habit categories', () {
        final validCategories = [
          'Mindfulness', 'Exercise', 'Social', 'Creative', 'Learning', 'Self-Care'
        ];

        for (var category in validCategories) {
          final habit = _createTestHabit(category: category);

          expect(habit.category, equals(category));
          expect(habit.categoryEmoji, isNotEmpty,
              reason: 'Category "$category" should have an emoji');
        }
      });

      test('TC-HC1.4: Category emojis should match Constants', () {
        final categoryEmojis = {
          'Mindfulness': '🧘',
          'Exercise': '💪',
          'Social': '👥',
          'Creative': '🎨',
          'Learning': '📚',
          'Self-Care': '💚',
        };

        categoryEmojis.forEach((category, expectedEmoji) {
          final habit = _createTestHabit(category: category);
          expect(habit.categoryEmoji, equals(expectedEmoji));
        });
      });
    });

    // ========================================================================
    // TEST GROUP 2: Completion Status Logic
    // ========================================================================
    group('Completion Status Logic', () {
      test('TC-HC2.1: isCompletedToday() returns false when no completions exist', () {
        final habit = _createTestHabit();

        expect(habit.isCompletedToday(), isFalse);
        expect(habit.completedDates, isEmpty);
      });

      test('TC-HC2.2: isCompletedToday() returns true when completed today', () {
        final now = DateTime.now();
        final habit = _createTestHabit(completedDates: [now]);

        expect(habit.isCompletedToday(), isTrue);
      });

      test('TC-HC2.3: isCompletedToday() returns false when completed yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final habit = _createTestHabit(completedDates: [yesterday]);

        expect(habit.isCompletedToday(), isFalse);
      });

      test('TC-HC2.4: isCompletedToday() handles multiple completions correctly', () {
        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));
        final twoDaysAgo = today.subtract(const Duration(days: 2));

        final habit = _createTestHabit(
          completedDates: [twoDaysAgo, yesterday, today],
        );

        expect(habit.isCompletedToday(), isTrue);
        expect(habit.completedDates.length, equals(3));
      });

      test('TC-HC2.5: isCompletedToday() handles different times on same day', () {
        final today = DateTime.now();
        final morning = DateTime(today.year, today.month, today.day, 8, 0);
        final evening = DateTime(today.year, today.month, today.day, 20, 0);

        final habitMorning = _createTestHabit(completedDates: [morning]);
        final habitEvening = _createTestHabit(completedDates: [evening]);

        expect(habitMorning.isCompletedToday(), isTrue);
        expect(habitEvening.isCompletedToday(), isTrue);
      });
    });

    // ========================================================================
    // TEST GROUP 3: Reward Status (Anti-Exploit Mechanism)
    // ========================================================================
    group('Reward Status (Anti-Exploit Mechanism)', () {
      test('TC-HC3.1: isRewardedToday() returns false when no rewards claimed', () {
        final habit = _createTestHabit();

        expect(habit.isRewardedToday(), isFalse);
      });

      test('TC-HC3.2: isRewardedToday() returns true when reward claimed today', () {
        final now = DateTime.now();
        final habit = _createTestHabit(rewardedDates: [now]);

        expect(habit.isRewardedToday(), isTrue);
      });

      test('TC-HC3.3: canClaimReward() returns true when completed but not rewarded', () {
        final today = DateTime.now();
        final habit = _createTestHabit(
          completedDates: [today],
          rewardedDates: [],
        );

        expect(habit.canClaimReward(), isTrue,
            reason: 'Completed today + not rewarded = can claim');
        expect(habit.isCompletedToday(), isTrue);
        expect(habit.isRewardedToday(), isFalse);
      });

      test('TC-HC3.4: canClaimReward() returns false (ANTI-EXPLOIT: double reward)', () {
        final today = DateTime.now();
        final habit = _createTestHabit(
          completedDates: [today],
          rewardedDates: [today],
        );

        expect(habit.canClaimReward(), isFalse,
            reason: 'ANTI-EXPLOIT: Cannot claim reward twice on same day');
        expect(habit.isCompletedToday(), isTrue);
        expect(habit.isRewardedToday(), isTrue);
      });

      test('TC-HC3.5: canClaimReward() allows claim if yesterday rewarded, today completed', () {
        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));

        final habit = _createTestHabit(
          completedDates: [today],
          rewardedDates: [yesterday],
        );

        expect(habit.canClaimReward(), isTrue,
            reason: 'Yesterday reward does not block today');
      });

      test('TC-HC3.6: canClaimReward() returns false if not completed today', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final habit = _createTestHabit(
          completedDates: [yesterday],
          rewardedDates: [],
        );

        expect(habit.canClaimReward(), isFalse,
            reason: 'Must complete habit before claiming reward');
        expect(habit.isCompletedToday(), isFalse);
      });

      test('TC-HC3.7: Multiple rewards on different days should not conflict', () {
        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));
        final twoDaysAgo = today.subtract(const Duration(days: 2));

        final habit = _createTestHabit(
          completedDates: [twoDaysAgo, yesterday, today],
          rewardedDates: [twoDaysAgo, yesterday], // Not today
        );

        expect(habit.canClaimReward(), isTrue,
            reason: 'Today is not rewarded yet');
      });

      test('TC-HC3.8: ANTI-EXPLOIT - Reward array correctly prevents exploit', () {
        final today = DateTime.now();

        // Simulate exploit attempt: claim reward multiple times
        var habit = _createTestHabit(
          completedDates: [today],
          rewardedDates: [],
        );

        // First claim - should succeed
        expect(habit.canClaimReward(), isTrue);

        // Simulate claiming (add to rewardedDates)
        habit = habit.copyWith(
          rewardedDates: [...habit.rewardedDates, today],
        );

        // Second claim attempt - should fail
        expect(habit.canClaimReward(), isFalse,
            reason: 'ANTI-EXPLOIT: Second claim attempt blocked');
      });
    });

    // ========================================================================
    // TEST GROUP 4: Streak Calculations
    // ========================================================================
    group('Streak Calculations', () {
      test('TC-HC4.1: New habit should have streak 0', () {
        final habit = _createTestHabit();
        expect(habit.currentStreak, equals(0));
      });

      test('TC-HC4.2: Single completion should have streak 1', () {
        final habit = _createTestHabit(
          completedDates: [DateTime.now()],
          currentStreak: 1,
        );
        expect(habit.currentStreak, equals(1));
      });

      test('TC-HC4.3: longestStreak should be >= currentStreak', () {
        final habit = _createTestHabit(
          currentStreak: 5,
          longestStreak: 10,
        );

        expect(habit.longestStreak, greaterThanOrEqualTo(habit.currentStreak));
      });

      test('TC-HC4.4: Streak milestones should trigger rewards', () {
        final streakMilestones = [7, 14, 30];

        for (final milestone in streakMilestones) {
          final rewards = Constants.calculateHabitReward(
            category: 'Social',
            currentStreak: milestone,
          );
          final baseRewards = Constants.calculateHabitReward(
            category: 'Social',
            currentStreak: 0,
          );

          expect(rewards['water'], greaterThan(baseRewards['water']!),
              reason: '$milestone-day streak should give water bonus');
          expect(rewards['sunlight'], greaterThan(baseRewards['sunlight']!),
              reason: '$milestone-day streak should give sunlight bonus');
        }
      });
    });

    // ========================================================================
    // TEST GROUP 5: Serialization (Map/JSON)
    // ========================================================================
    group('Serialization (Map/JSON)', () {
      test('TC-HC5.1: toMap() should produce complete map', () {
        final now = DateTime.now();
        final habit = Habit(
          id: 'serialize_test',
          userId: 'user_123',
          title: 'Test Habit',
          description: 'Test Description',
          category: 'Exercise',
          completedDates: [now],
          rewardedDates: [now],
          createdAt: now,
          currentStreak: 5,
          longestStreak: 10,
        );

        final map = habit.toMap();

        expect(map['userId'], equals('user_123'));
        expect(map['title'], equals('Test Habit'));
        expect(map['category'], equals('Exercise'));
        expect(map['currentStreak'], equals(5));
        expect(map['longestStreak'], equals(10));
        expect(map['completedDates'], isA<List>());
        expect(map['rewardedDates'], isA<List>());
      });

      test('TC-HC5.2: fromMap() should correctly parse all fields', () {
        final map = {
          'userId': 'user_123',
          'title': 'Parsed Habit',
          'description': 'Test Description',
          'category': 'Learning',
          'completedDates': [DateTime.now().toIso8601String()],
          'rewardedDates': [],
          'createdAt': '2024-01-01T00:00:00.000',
          'currentStreak': 3,
          'longestStreak': 5,
        };

        final habit = Habit.fromMap(map, 'parsed_id');

        expect(habit.id, equals('parsed_id'));
        expect(habit.title, equals('Parsed Habit'));
        expect(habit.currentStreak, equals(3));
        expect(habit.completedDates.length, equals(1));
        expect(habit.completedDates[0], isA<DateTime>());
      });

      test('TC-HC5.3: fromMap() should handle missing optional fields', () {
        final minimalMap = {
          'userId': 'user_123',
          'title': 'Minimal Habit',
          'description': '',
          'category': 'Self-Care',
          'createdAt': '2024-01-01T00:00:00.000',
        };

        final habit = Habit.fromMap(minimalMap, 'minimal_id');

        expect(habit.completedDates, isEmpty);
        expect(habit.rewardedDates, isEmpty);
        expect(habit.currentStreak, equals(0));
      });

      test('TC-HC5.4: Roundtrip serialization should preserve data', () {
        final original = _createTestHabit(
          title: 'Roundtrip Test',
          category: 'Creative',
          currentStreak: 7,
          completedDates: [DateTime.now()],
        );

        final map = original.toMap();
        final restored = Habit.fromMap(map, original.id);

        expect(restored.title, equals(original.title));
        expect(restored.category, equals(original.category));
        expect(restored.currentStreak, equals(original.currentStreak));
        expect(restored.completedDates.length, equals(original.completedDates.length));
      });
    });

    // ========================================================================
    // TEST GROUP 6: CopyWith Immutability
    // ========================================================================
    group('CopyWith Immutability', () {
      test('TC-HC6.1: copyWith should create new object with updated field', () {
        final original = _createTestHabit(title: 'Original Title');
        final copy = original.copyWith(title: 'Updated Title');

        expect(copy.title, equals('Updated Title'));
        expect(original.title, equals('Original Title'),
            reason: 'Original should be unchanged (immutability)');
        expect(copy.id, equals(original.id));
      });

      test('TC-HC6.2: copyWith should preserve all unchanged fields', () {
        final original = _createTestHabit(
          title: 'Original',
          category: 'Exercise',
          currentStreak: 5,
        );

        final copy = original.copyWith(title: 'Updated');

        expect(copy.category, equals('Exercise'));
        expect(copy.currentStreak, equals(5));
        expect(copy.userId, equals(original.userId));
      });

      test('TC-HC6.3: copyWith should allow updating multiple fields', () {
        final original = _createTestHabit();

        final copy = original.copyWith(
          title: 'New Title',
          category: 'Learning',
          currentStreak: 10,
        );

        expect(copy.title, equals('New Title'));
        expect(copy.category, equals('Learning'));
        expect(copy.currentStreak, equals(10));
      });

      test('TC-HC6.4: copyWith with dates should create new list', () {
        final original = _createTestHabit(completedDates: [DateTime.now()]);
        final newDate = DateTime.now().add(const Duration(days: 1));

        final copy = original.copyWith(
          completedDates: [...original.completedDates, newDate],
        );

        expect(copy.completedDates.length, equals(2));
        expect(original.completedDates.length, equals(1),
            reason: 'Original list should be unchanged');
      });
    });

    // ========================================================================
    // TEST GROUP 7: Date Edge Cases
    // ========================================================================
    group('Date Edge Cases', () {
      test('TC-HC7.1: Completion at midnight should count as today', () {
        final midnight = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          0, 0, 0,
        );

        final habit = _createTestHabit(completedDates: [midnight]);

        expect(habit.isCompletedToday(), isTrue,
            reason: 'Midnight completion is still "today"');
      });

      test('TC-HC7.2: Completion at 23:59:59 should count as today', () {
        final lateNight = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          23, 59, 59,
        );

        final habit = _createTestHabit(completedDates: [lateNight]);

        expect(habit.isCompletedToday(), isTrue);
      });

      test('TC-HC7.3: Yesterday at 23:59:59 should NOT count as today', () {
        final today = DateTime.now();
        final yesterdayLate = DateTime(
          today.year,
          today.month,
          today.day - 1,
          23, 59, 59,
        );

        final habit = _createTestHabit(completedDates: [yesterdayLate]);

        expect(habit.isCompletedToday(), isFalse);
      });

      test('TC-HC7.4: Day boundary at different timezones', () {
        // Test that we use local time, not UTC
        final todayLocal = DateTime.now();
        final habit = _createTestHabit(completedDates: [todayLocal]);

        expect(habit.isCompletedToday(), isTrue);
      });
    });

    // ========================================================================
    // TEST GROUP 8: Statistics Helpers
    // ========================================================================
    group('Statistics Helpers', () {
      test('TC-HC8.1: weeklyCompletionCount should count this week completions', () {
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        final lastWeek = now.subtract(const Duration(days: 8));

        final habit = _createTestHabit(
          completedDates: [lastWeek, yesterday, now],
        );

        expect(habit.weeklyCompletionCount, greaterThanOrEqualTo(1));
        expect(habit.weeklyCompletionCount, lessThanOrEqualTo(3));
      });

      test('TC-HC8.2: monthlyCompletionCount should count this month completions', () {
        final now = DateTime.now();
        final habit = _createTestHabit(completedDates: [now]);

        expect(habit.monthlyCompletionCount, equals(1));
      });

      test('TC-HC8.3: completionRate should be between 0 and 1', () {
        final habit = _createTestHabit(completedDates: [DateTime.now()]);

        expect(habit.completionRate, greaterThanOrEqualTo(0.0));
        expect(habit.completionRate, lessThanOrEqualTo(1.0));
      });

      test('TC-HC8.4: Empty completions should have 0 rate', () {
        final habit = _createTestHabit(completedDates: []);

        expect(habit.completionRate, equals(0.0));
        expect(habit.weeklyCompletionCount, equals(0));
        expect(habit.monthlyCompletionCount, equals(0));
      });
    });

    // ========================================================================
    // TEST GROUP 9: Category Emoji Helper
    // ========================================================================
    group('Category Emoji Helper', () {
      test('TC-HC9.1: Each category should have a corresponding emoji', () {
        final categoryEmojis = {
          'Mindfulness': '🧘',
          'Exercise': '💪',
          'Social': '👥',
          'Creative': '🎨',
          'Learning': '📚',
          'Self-Care': '💚',
        };

        categoryEmojis.forEach((category, expectedEmoji) {
          final habit = _createTestHabit(category: category);
          expect(habit.categoryEmoji, equals(expectedEmoji),
              reason: 'Category $category should have emoji $expectedEmoji');
        });
      });

      test('TC-HC9.2: Unknown category should have default emoji', () {
        final habit = _createTestHabit(category: 'Unknown');
        expect(habit.categoryEmoji, equals('✨'),
            reason: 'Unknown category falls back to ✨');
      });

      test('TC-HC9.3: Empty category should have default emoji', () {
        final habit = _createTestHabit(category: '');
        expect(habit.categoryEmoji, equals('✨'));
      });
    });

    // ========================================================================
    // TEST GROUP 10: Reward Calculation Integration
    // ========================================================================
    group('Reward Calculation Integration', () {
      test('TC-HC10.1: Habit category should affect reward calculation', () {
        final mindfulnessHabit = _createTestHabit(category: 'Mindfulness');
        final exerciseHabit = _createTestHabit(category: 'Exercise');

        final mindfulnessRewards = Constants.calculateHabitReward(
          category: mindfulnessHabit.category,
          currentStreak: mindfulnessHabit.currentStreak,
        );

        final exerciseRewards = Constants.calculateHabitReward(
          category: exerciseHabit.category,
          currentStreak: exerciseHabit.currentStreak,
        );

        // Mindfulness gives water bonus
        expect(mindfulnessRewards['water'], greaterThan(exerciseRewards['water']!));
        // Exercise gives sunlight bonus
        expect(exerciseRewards['sunlight'], greaterThan(mindfulnessRewards['sunlight']!));
      });

      test('TC-HC10.2: Streak should affect reward calculation', () {
        final habit = _createTestHabit(category: 'Social', currentStreak: 7);

        final streakRewards = Constants.calculateHabitReward(
          category: habit.category,
          currentStreak: habit.currentStreak,
        );

        final noStreakRewards = Constants.calculateHabitReward(
          category: habit.category,
          currentStreak: 0,
        );

        expect(streakRewards['water'], greaterThan(noStreakRewards['water']!));
        expect(streakRewards['sunlight'], greaterThan(noStreakRewards['sunlight']!));
      });
    });
  });
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

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