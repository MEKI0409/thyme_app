// services/recommendation_service.dart

import '../models/habit_model.dart';
import '../utils/constants.dart';

class RecommendationService {
  List<Habit> recommendHabits(String mood, List<Habit> allHabits) {
    final recommendedCategories =
        Constants.moodToCategories[mood] ?? ['Self-Care'];

    final recommendedHabits = allHabits.where((habit) {
      return recommendedCategories.contains(habit.category) &&
          !habit.isCompletedToday();
    }).toList();

    recommendedHabits
        .sort((a, b) => b.currentStreak.compareTo(a.currentStreak));

    return recommendedHabits.take(3).toList();
  }

  /// ✅ IMPROVED: Calm, non-pressuring messages
  String getRecommendationMessage(String mood) {
    final messages = {
      'anxious':
      'When you\'re ready, these gentle practices might feel grounding:',
      'stressed':
      'No pressure, but these might offer a moment of calm:',
      'sad':
      'If it feels right, these practices are here for you:',
      'happy':
      'If you\'d like, here are some ways to savor this feeling:',
      'calm':
      'Some gentle options, if you\'re in the mood:',
      'neutral':
      'Here are some practices that might resonate today:',
      'angry':
      'When you\'re ready, these might help you process:',
      'tired':
      'Rest is always an option. If you do want to try something gentle:',
      'hopeful':
      'Some practices that might nurture that feeling:',
      'confused':
      'No need to figure it all out. If it helps, you could try:',
      'lonely':
      'Connection looks different for everyone. These might feel supportive:',
    };

    return messages[mood] ?? 'Here are some gentle options for today:';
  }

  /// Reflective quotes instead of motivational
  String getReflectiveQuote(String mood) {
    final quotes = {
      'anxious':
      '"Breathing in, I calm my body. Breathing out, I smile." - Thich Nhat Hanh',
      'stressed':
      '"Almost everything will work again if you unplug it for a few minutes, including you." - Anne Lamott',
      'sad':
      '"The wound is the place where the Light enters you." - Rumi',
      'happy':
      '"This is enough." - A gentle reminder',
      'calm':
      '"In the midst of movement and chaos, keep stillness inside of you." - Deepak Chopra',
      'neutral':
      '"Just being here is enough." - A gentle truth',
      'angry':
      '"Between stimulus and response there is a space. In that space is our power to choose." - Viktor Frankl',
      'tired':
      '"Rest when you\'re weary. Refresh and renew yourself." - Ralph Marston',
      'hopeful':
      '"Hope is a waking dream." - Aristotle',
      'confused':
      '"Not knowing is most intimate." - Zen proverb',
      'lonely':
      '"The most terrible poverty is loneliness, and the feeling of being unloved." - Mother Teresa',
    };

    return quotes[mood] ?? '"This moment is enough." - A gentle reminder';
  }

  /// Get gentle encouragement (not motivation)
  String getGentleEncouragement(String mood) {
    final encouragements = {
      'anxious': 'Your garden is a safe space. Take all the time you need.',
      'stressed': 'It\'s okay to put things down for a moment.',
      'sad': 'All feelings are welcome here. You don\'t have to be okay.',
      'happy': 'This feeling is worth noticing.',
      'calm': 'What a gift this moment is.',
      'neutral': 'You\'re here, and that\'s what matters.',
      'angry': 'Anger is valid. It\'s telling you something important.',
      'tired': 'Rest is productive too.',
      'hopeful': 'Hold onto this feeling gently.',
      'confused': 'Clarity will come. For now, just be.',
      'lonely': 'You\'re not alone in feeling alone.',
    };

    return encouragements[mood] ?? 'You\'re doing just fine. 💚';
  }

  /// Get activity suggestions based on energy level (not mood)
  List<String> getEnergyBasedSuggestions(String energyLevel) {
    switch (energyLevel.toLowerCase()) {
      case 'low':
        return [
          'Rest or nap',
          'Gentle stretching',
          'Listen to calming music',
          'Breathe slowly for a minute',
        ];
      case 'medium':
        return [
          'A short walk outside',
          'Journal a few thoughts',
          'Tidy one small area',
          'Call a friend',
        ];
      case 'high':
        return [
          'Exercise or movement',
          'Creative project',
          'Learn something new',
          'Help someone',
        ];
      default:
        return [
          'Whatever feels right for you',
          'Trust your body\'s signals',
        ];
    }
  }

  /// Check if recommendation should be shown
  /// (Respects user's space - doesn't always push recommendations)
  bool shouldShowRecommendation(
      String? currentMood,
      DateTime? lastActivityTime,
      int habitsCompletedToday,
      ) {
    // Don't recommend if user just completed something
    if (lastActivityTime != null) {
      final minutesSince = DateTime.now().difference(lastActivityTime).inMinutes;
      if (minutesSince < 30) return false;
    }

    // Don't overwhelm - limit daily recommendations
    if (habitsCompletedToday >= 3) return false;

    // For stressed/anxious moods, be more conservative
    if (currentMood == 'anxious' || currentMood == 'stressed') {
      return false; // Let them initiate
    }

    return true;
  }

  /// Get time-appropriate suggestions
  String getTimeBasedMessage() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 9) {
      return 'A gentle start to your day. No rush.';
    } else if (hour >= 9 && hour < 12) {
      return 'The morning is unfolding. What feels right?';
    } else if (hour >= 12 && hour < 14) {
      return 'A midday pause might be nice.';
    } else if (hour >= 14 && hour < 17) {
      return 'The afternoon is here. How are you feeling?';
    } else if (hour >= 17 && hour < 20) {
      return 'Evening is settling in. Time to wind down?';
    } else if (hour >= 20 && hour < 23) {
      return 'The day is ending. Be gentle with yourself.';
    } else {
      return 'Late night thoughts? This space is here for you.';
    }
  }
}
