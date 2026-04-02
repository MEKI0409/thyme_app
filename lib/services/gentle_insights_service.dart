// services/gentle_insights_service.dart

import '../models/habit_model.dart';
import '../models/mood_entry_model.dart';

class GentleInsightsService {
  String generateInsight(List<Habit> habits, List<MoodEntry> moods) {
    final insights = <String>[];


    final favoriteCategory = _findNaturalPreference(habits);
    if (favoriteCategory != null) {
      insights.add(
        "You seem to naturally gravitate towards ${favoriteCategory.toLowerCase()} activities. "
            "That's wonderful self-awareness. 🌱",
      );
    }

    final moodPattern = _observeMoodPattern(moods);
    if (moodPattern != null) {
      insights.add(moodPattern);
    }

    final gentleProgress = _noticeSmallWins(habits);
    if (gentleProgress != null) {
      insights.add(gentleProgress);
    }


    final journalReflection = _reflectOnJournaling(moods);
    if (journalReflection != null) {
      insights.add(journalReflection);
    }

    if (insights.isEmpty) {
      return _getWarmEmptyStateMessage();
    }

    return insights[DateTime.now().day % insights.length];
  }

  /// Find what the user naturally gravitates toward
  String? _findNaturalPreference(List<Habit> habits) {
    if (habits.isEmpty) return null;

    final categoryCount = <String, int>{};
    for (var habit in habits) {
      if (habit.completedDates.isNotEmpty) {
        categoryCount[habit.category] =
            (categoryCount[habit.category] ?? 0) + habit.completedDates.length;
      }
    }

    if (categoryCount.isEmpty) return null;

    return categoryCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Observe mood patterns with compassion
  String? _observeMoodPattern(List<MoodEntry> moods) {
    if (moods.length < 3) return null;

    final recentMoods = moods.take(7).toList();
    final calmCount = recentMoods
        .where((m) => m.detectedMood == 'calm' || m.detectedMood == 'happy')
        .length;

    if (calmCount > recentMoods.length / 2) {
      return "I notice you've been feeling more at peace lately. "
          "Whatever you're doing, it seems to be working for you. 💚";
    }

    final difficultCount = recentMoods
        .where((m) =>
    m.detectedMood == 'anxious' ||
        m.detectedMood == 'stressed' ||
        m.detectedMood == 'sad')
        .length;

    if (difficultCount > recentMoods.length / 2) {
      return "It looks like things have been a bit heavy lately. "
          "Remember, it's okay to just be here. Your garden will wait. 🤍";
    }

    return null;
  }

  /// Notice small wins without making them feel like obligations
  String? _noticeSmallWins(List<Habit> habits) {
    for (var habit in habits) {
      if (habit.completedDates.isNotEmpty) {
        final lastCompletion = habit.completedDates.last;
        final daysSince = DateTime.now().difference(lastCompletion).inDays;

        if (daysSince == 0) {
          return "You showed up for yourself today with ${habit.title}. "
              "That matters. ✨";
        }
      }
    }

    if (habits.isNotEmpty) {
      return "Your garden is here whenever you're ready. "
          "There's no rush, no schedule. 🌿";
    }

    return null;
  }

  String? _reflectOnJournaling(List<MoodEntry> moods) {
    if (moods.isEmpty) return null;

    final recentEntries = moods.where((m) {
      final daysSince = DateTime.now().difference(m.createdAt).inDays;
      return daysSince <= 7;
    }).length;

    if (recentEntries >= 3) {
      return "You've been checking in with yourself this week. "
          "That kind of self-awareness is a gentle gift. 📝";
    }

    return null;
  }

  String _getWarmEmptyStateMessage() {
    final messages = [
      "Your garden is here whenever you need it. No pressure, no rush. 🌿",
      "This is a space just for you. Explore it at your own pace. 🌱",
      "There's no right way to be here. Just being here is enough. 💚",
      "Your wellbeing journey is uniquely yours. Take your time. 🍃",
    ];
    return messages[DateTime.now().hour % messages.length];
  }

  String getDailyReflection() {
    final reflections = [
      "How are you feeling in this moment? 💭",
      "What's one kind thing you could do for yourself today? 🌸",
      "Is there anything weighing on your mind? 🍃",
      "What brought you here today? 💚",
      "Take a breath. You're exactly where you need to be. 🌿",
      "What does your body need right now? 🌱",
      "Is there something you'd like to let go of? 🍂",
    ];
    return reflections[DateTime.now().weekday % reflections.length];
  }

  String getTimeBasedGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return "A gentle morning to you. 🌅";
    } else if (hour >= 12 && hour < 17) {
      return "Taking a moment in your afternoon. ☀️";
    } else if (hour >= 17 && hour < 21) {
      return "An evening pause. 🌆";
    } else {
      return "A quiet moment in the night. 🌙";
    }
  }
}
