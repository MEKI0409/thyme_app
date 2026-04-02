// services/journal_prompts_service.dart

import 'dart:math';

class JournalPromptsService {
  static final Random _random = Random();

  /// Get gentle journal prompts - never demanding, always inviting
  static List<String> getGentlePrompts() {
    return [
      "What's on your mind right now? No need to organize your thoughts.",
      "How does your body feel in this moment?",
      "Is there something you'd like to let go of today?",
      "What's one small thing that brought you comfort recently?",
      "What would you tell a friend who felt the way you do now?",
      "What do you need right now? It's okay if you don't know.",
      "Describe your current mood as a weather pattern.",
      "What's something you're carrying that feels heavy?",
      "Is there a feeling you've been avoiding? It's safe here.",
      "What would 'enough' look like for you today?",
      "What sounds does your body want to hear right now?",
      "If your feelings had a color, what would it be?",
      "What's something gentle you could do for yourself today?",
      "What are you grateful for, even in difficult times?",
      "What's one boundary you could set to protect your peace?",
    ];
  }

  static String getRandomPrompt() {
    final prompts = getGentlePrompts();
    return prompts[_random.nextInt(prompts.length)];
  }

  /// Get prompt based on mood - supportive, not prescriptive
  static String getPromptForMood(String? mood) {
    switch (mood?.toLowerCase()) {
      case 'anxious':
        return "What's making you feel unsettled? "
            "You don't need to solve it, just name it. 💭";

      case 'sad':
        return "Sadness is welcome here. "
            "What does yours want to say? 🤍";

      case 'stressed':
        return "What's weighing on you? "
            "Let the words flow without judgment. 📝";

      case 'happy':
        return "What's bringing lightness to your day? "
            "Let's savor this feeling. ✨";

      case 'calm':
        return "In this peaceful moment, what comes to mind? "
            "There's no wrong answer. 🌿";

      case 'angry':
        return "Anger often protects something softer underneath. "
            "What might that be? 🔥";

      case 'tired':
        return "Rest is a form of self-care. "
            "What kind of rest does your soul need? 😴";

      case 'hopeful':
        return "What seeds of hope are you planting? "
            "What might they grow into? 🌱";

      case 'confused':
        return "It's okay not to have answers. "
            "What questions are swirling in your mind? 🌀";

      case 'lonely':
        return "Loneliness is a signal, not a flaw. "
            "What connection are you missing? 💙";

      default:
        return "How are you, really? Take your time. "
            "This space is here to listen. 💚";
    }
  }

  static String getCompletionResponse() {
    final responses = [
      "Thank you for sharing. Your words matter. 💚",
      "Writing takes courage. This was a gift to yourself.",
      "Your garden heard you. 🌿",
      "These words are safe here.",
      "You showed up for yourself. That's enough.",
      "Taking time to reflect is an act of self-care. 🌱",
      "Whatever you wrote, it was exactly what you needed to express.",
    ];
    return responses[_random.nextInt(responses.length)];
  }

  /// Get prompts for specific situations (gentle invitations)
  static String getMorningPrompt() {
    final prompts = [
      "How did you sleep? How are you entering this day?",
      "What's one intention you'd like to hold gently today?",
      "Good morning. What's the first feeling you notice?",
      "A new day begins. What are you carrying from yesterday?",
    ];
    return prompts[_random.nextInt(prompts.length)];
  }

  static String getEveningPrompt() {
    final prompts = [
      "How was your day? What moments stood out?",
      "What can you release before sleep?",
      "Is there anything unfinished that needs acknowledgment?",
      "What's one thing from today you'd like to remember?",
    ];
    return prompts[_random.nextInt(prompts.length)];
  }

  static List<String> getFollowUpPrompts(String originalEntry) {
    return [
      "Is there more you'd like to explore about this?",
      "What does this feeling remind you of?",
      "If you could tell someone about this, who would it be?",
      "What would help right now, if anything?",
    ];
  }

  /// Check if prompt should be shown
  static bool shouldShowPrompt(DateTime? lastJournalEntry) {
    // Don't prompt if they just journaled
    if (lastJournalEntry != null) {
      final hoursSince = DateTime.now().difference(lastJournalEntry).inHours;
      if (hoursSince < 4) return false;
    }
    return true;
  }

  /// Get a gentle nudge
  static String? getGentleNudge(int daysSinceLastEntry) {
    if (daysSinceLastEntry <= 1) return null;

    if (daysSinceLastEntry <= 3) {
      return "Your journal is here if you want to write. "
          "No pressure — sometimes just being here is enough. 📝";
    } else if (daysSinceLastEntry <= 7) {
      return "It's been a few days. "
          "Would you like to check in with yourself? 💭";
    } else {
      return null;
    }
  }
}