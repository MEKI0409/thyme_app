// services/welcome_back_service.dart
// Calm Gamification: No-guilt return - users are always welcome back
// The garden NEVER punishes absence. Plants rest, they don't die.

class WelcomeBackService {
  /// Generate warm welcome back message based on absence duration
  /// NEVER use guilt-inducing language like "we missed you" or "you've been away"
  String getWelcomeBackMessage(int daysSinceLastVisit) {
    if (daysSinceLastVisit <= 1) {
      return "Welcome back. 🌿";
    } else if (daysSinceLastVisit <= 3) {
      return "Hello again. Your garden is happy to see you. 🌱";
    } else if (daysSinceLastVisit <= 7) {
      return "Your garden waited patiently, and it's glad you're here. 💚";
    } else if (daysSinceLastVisit <= 14) {
      return "Welcome back. Your garden has been resting too. "
          "Let's just be here together. 🌿";
    } else if (daysSinceLastVisit <= 30) {
      return "You're back, and that's all that matters. "
          "Your garden never judges. 💚";
    } else if (daysSinceLastVisit <= 90) {
      return "Welcome home. No matter how long you've been away, "
          "this space is always here for you. 🌱";
    } else {
      return "It's been a while, and that's perfectly okay. "
          "Your garden kept a quiet space for you. Welcome back. 🌿";
    }
  }

  /// Get garden status message (NOT punishment, just gentle acknowledgment)
  String getGardenStatusMessage(int daysSinceLastVisit) {
    if (daysSinceLastVisit <= 1) {
      return "Your garden is thriving. 🌸";
    } else if (daysSinceLastVisit <= 7) {
      return "Your garden has been quietly growing. 🌱";
    } else if (daysSinceLastVisit <= 30) {
      return "Your garden took a peaceful rest while you were away. 😴";
    } else {
      return "Your garden entered a gentle hibernation. "
          "It's waking up now that you're here. 🌿";
    }
  }

  /// Get a gentle activity suggestion (invitation, not requirement)
  String? getGentleSuggestion(int daysSinceLastVisit, String? lastMood) {
    // Only suggest if they've been away a while, and keep it optional
    if (daysSinceLastVisit < 3) return null;

    final suggestions = [
      "If you'd like, you could take a moment to check in with how you're feeling. "
          "Or just enjoy the garden. Either is perfect. 💭",
      "Your journal is here if you want to write. "
          "No pressure - sometimes just being here is enough. 📝",
      "Would you like to sit in the garden for a moment? "
          "There's nothing you need to do. 🌿",
    ];

    // Return a gentle suggestion based on day
    return suggestions[daysSinceLastVisit % suggestions.length];
  }

  /// Calculate rest bonus (REWARD for coming back, not punishment for leaving)
  /// This is a calm gamification approach - absence is rewarded, not punished
  Map<String, int> calculateRestBonus(int daysSinceLastVisit) {
    // The idea: your garden "stored up" resources while resting
    // This REWARDS returning, not punishes absence
    if (daysSinceLastVisit <= 1) {
      return {'water': 0, 'sunlight': 0};
    } else if (daysSinceLastVisit <= 7) {
      return {'water': 2, 'sunlight': 2};
    } else if (daysSinceLastVisit <= 30) {
      return {'water': 5, 'sunlight': 5};
    } else {
      // Cap the bonus so it doesn't feel exploitative
      return {'water': 10, 'sunlight': 10};
    }
  }

  /// Get affirmation for returning
  String getReturnAffirmation() {
    final affirmations = [
      "Taking breaks is part of the journey. You're here now, and that matters.",
      "Life happens. Your garden understands. Welcome back.",
      "There's no such thing as 'falling behind' here. You're exactly where you need to be.",
      "Coming back takes courage. We're glad you're here.",
      "This space doesn't keep score. It just keeps space for you.",
      "Every return is a fresh start. No baggage, no guilt.",
      "You showed up for yourself by coming back. That's something to be proud of.",
    ];
    return affirmations[DateTime.now().day % affirmations.length];
  }

  /// Check if user should see onboarding refresh (gentle reminder of features)
  bool shouldShowFeatureRefresh(int daysSinceLastVisit) {
    // If they've been away more than 30 days, gently remind them of features
    return daysSinceLastVisit > 30;
  }

  /// Get feature refresh items (not new feature announcements, just gentle reminders)
  List<FeatureReminder> getFeatureReminders() {
    return [
      FeatureReminder(
        icon: '🌿',
        title: 'Your Garden',
        description: 'A peaceful space that grows with your wellbeing',
      ),
      FeatureReminder(
        icon: '📝',
        title: 'Mood Journal',
        description: 'A place to express how you\'re feeling, without judgment',
      ),
      FeatureReminder(
        icon: '✨',
        title: 'Gentle Habits',
        description: 'Small practices you can do at your own pace',
      ),
      FeatureReminder(
        icon: '💬',
        title: 'AI Companion',
        description: 'A supportive presence when you want to talk',
      ),
    ];
  }
}

/// Feature reminder for onboarding refresh
class FeatureReminder {
  final String icon;
  final String title;
  final String description;

  FeatureReminder({
    required this.icon,
    required this.title,
    required this.description,
  });
}