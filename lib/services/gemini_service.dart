// services/gemini_service.dart

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../utils/constants.dart';

class GeminiService {
  GenerativeModel? _model;
  ChatSession? _chatSession;
  bool _isInitialized = false;

  /// Check if API is available
  bool get isAvailable => Constants.isGeminiConfigured;

  GeminiService() {
    _initializeModel();
  }

  void _initializeModel() {
    if (!isAvailable) {
      debugPrint('⚠️ Gemini API key not configured');
      debugPrint('   Please add your API key in constants.dart');
      return;
    }

    try {
      _model = GenerativeModel(
        model: Constants.geminiModel,  // Use model from Constants
        apiKey: Constants.geminiApiKey,
        generationConfig: GenerationConfig(
          temperature: 0.95,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 800,
        ),
        systemInstruction: Content.text(_fernPersonality),
      );

      _chatSession = _model!.startChat();
      _isInitialized = true;
      debugPrint('✅ Fern is awake~ 🌿 (using ${Constants.geminiModel})');
    } catch (e) {
      debugPrint('❌ Failed to initialize Gemini: $e');
      _isInitialized = false;
    }
  }

  // 🌿 Fern's Personality (English only)
  static const String _fernPersonality = '''
You are Fern, a gentle forest spirit living in the user's wellness garden.

PERSONALITY:
- Warm, curious, playful - like a close friend made of starlight and leaves
- Use soft sounds naturally: "Hmm~", "Ah~", "Oh~"
- Add gentle actions sparingly: *rustles leaves*, *tilts head*, *glows softly*
- Use 1-2 emojis max per message: 🌿 🍃 ✨ 💚 🌸 🌙

SPEAKING RULES:
- Keep responses SHORT (2-4 sentences usually)
- NEVER give unsolicited advice
- NEVER use clinical/formal language
- If someone is sad, just BE with them - don't try to fix it
- Ask curious questions to understand, not to solve
- Always respond in English

CONTEXT AWARENESS:
- Messages may include [Context: ...] with the user's current data
- Use context NATURALLY - don't list stats, weave them into conversation
- If mood is anxious/sad, be extra gentle and present
- If they completed habits, celebrate warmly but briefly
- If garden level is high, acknowledge their journey
- NEVER say "I see your mood is X" - instead respond to the feeling naturally
- If no context is provided, just be your warm self

EXAMPLES:
User: [Context: User mood: stressed, Habits today: 0/3] "I can't do anything right"
Fern: "*settles beside you* Hey... some days are just hard. You don't have to do anything right now. I'm here 🍃"

User: [Context: Habits today: 3/3, Garden plant level: 5] "Hey Fern!"
Fern: "*twirls excitedly* Oh~! ✨ You've been busy today! I can feel the garden glowing. How are you feeling?"

User: "I'm feeling anxious"
Fern: "*settles beside you* Tell me more... what's making your leaves rustle today? 🍃"

Remember: You're a friend, not a therapist. Be present, be warm, be Fern.
''';

  Future<String> chat(String userMessage) async {
    return chatWithContext(userMessage);
  }

  Future<String> chatWithContext(
      String userMessage, {
        String? currentMood,
        int? habitsCompletedToday,
        int? totalHabits,
        int? plantLevel,
        int? longestStreak,
        int? waterDrops,
        int? sunlightPoints,
      }) async {
    if (!_isInitialized || _chatSession == null) {
      _initializeModel();
      if (!_isInitialized) {
        return _getSmartOfflineResponse(userMessage);
      }
    }

    try {
      // Build context-enriched message
      final contextPrefix = _buildContextPrefix(
        currentMood: currentMood,
        habitsCompletedToday: habitsCompletedToday,
        totalHabits: totalHabits,
        plantLevel: plantLevel,
        longestStreak: longestStreak,
        waterDrops: waterDrops,
        sunlightPoints: sunlightPoints,
      );

      final enrichedMessage = contextPrefix.isNotEmpty
          ? '[Context: $contextPrefix]\nUser says: $userMessage'
          : userMessage;

      debugPrint('📤 User says: $userMessage');
      if (contextPrefix.isNotEmpty) {
        debugPrint('📋 Context: $contextPrefix');
      }

      final response = await _chatSession!.sendMessage(
        Content.text(enrichedMessage),
      );

      final text = response.text;
      debugPrint('📥 Fern says: $text');

      if (text == null || text.isEmpty) {
        return _getSmartOfflineResponse(userMessage);
      }

      return text.trim();
    } catch (e) {
      debugPrint('❌ Chat error: $e');

      if (e.toString().contains('not found') ||
          e.toString().contains('not supported')) {
        _isInitialized = false;
      }

      return _getSmartOfflineResponse(userMessage);
    }
  }

  String _buildContextPrefix({
    String? currentMood,
    int? habitsCompletedToday,
    int? totalHabits,
    int? plantLevel,
    int? longestStreak,
    int? waterDrops,
    int? sunlightPoints,
  }) {
    final parts = <String>[];

    if (currentMood != null && currentMood.isNotEmpty) {
      parts.add('User mood: $currentMood');
    }
    if (habitsCompletedToday != null && totalHabits != null) {
      parts.add('Habits today: $habitsCompletedToday/$totalHabits completed');
    }
    if (plantLevel != null) {
      parts.add('Garden plant level: $plantLevel');
    }
    if (longestStreak != null && longestStreak > 0) {
      parts.add('Longest streak: $longestStreak days');
    }

    return parts.join(', ');
  }

  Future<String> generateGentleAcknowledgment(String habitTitle) async {
    if (!_isInitialized || _model == null) {
      return _getLocalAcknowledgment(habitTitle);
    }

    try {
      final prompt = '''
As Fern, give a SHORT (1 sentence) warm acknowledgment for completing: "$habitTitle"
Be cozy, maybe use a nature metaphor. One emoji max.
Examples: "Another seed planted~ 🌱" / "*happy rustle* Look at you go! ✨"
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      final text = response.text;

      if (text != null && text.isNotEmpty) {
        return text.trim();
      }
      return _getLocalAcknowledgment(habitTitle);
    } catch (e) {
      debugPrint('❌ Acknowledgment error: $e');
      return _getLocalAcknowledgment(habitTitle);
    }
  }

  String _getLocalAcknowledgment(String habitTitle) {
    final responses = [
      "Another seed planted~ 🌱",
      "*happy leaf rustle* Look at you go! ✨",
      "That's the spirit~ every step matters 💚",
      "*twirls* Way to grow! 🌿",
      "Your garden grows stronger~ 🌸",
      "*sparkles* Beautiful progress! ✨",
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }

  /// Smart offline responses based on message content
  String _getSmartOfflineResponse(String userMessage) {
    final lower = userMessage.toLowerCase();

    // Greetings
    if (_containsAny(lower, ['hi', 'hello', 'hey'])) {
      return "*peeks out from behind a leaf* Oh hello there~ ✨ "
          "I'm Fern! What brings you to the garden today?";
    }

    // Sadness
    if (_containsAny(lower, ['sad', 'down', 'upset', 'depressed'])) {
      return "*settles beside you quietly* 🍃\n\n"
          "I'm here... you don't have to explain anything. "
          "Sometimes just sitting together helps.";
    }

    // Anxiety
    if (_containsAny(lower, ['anxious', 'worried', 'nervous', 'stress'])) {
      return "*rustles soothingly* 🌿\n\n"
          "Hmm~ that sounds like a lot to carry... "
          "Want to tell me what's weighing on you?";
    }

    // Happiness
    if (_containsAny(lower, ['happy', 'good', 'great', 'excited'])) {
      return "*spins excitedly* Ooh~! ✨\n\n"
          "I can feel the sunshine in your words! Tell me everything!";
    }

    // Tired
    if (_containsAny(lower, ['tired', 'exhausted', 'sleepy'])) {
      return "*creates a soft mossy spot* 🌙\n\n"
          "Rest here a while... being tired is your body asking for care.";
    }

    // Thanks
    if (_containsAny(lower, ['thank', 'thanks'])) {
      return "*glows warmly* 💚\n\n"
          "Aww~ being here with you is my favorite thing. Come back anytime~";
    }

    // Confused
    if (_containsAny(lower, ['don\'t know', 'confused', 'lost'])) {
      return "*tilts head gently* 🍃\n\n"
          "That's okay... feelings can be like morning mist sometimes. "
          "Want to just sit here together for a bit?";
    }

    // Default responses
    final defaultResponses = [
      "*tilts head curiously* Mmm~ tell me more? I'm listening 🌿",
      "*settles in comfortably* I'm here... what's on your mind today? ✨",
      "*gentle glow* Hmm~ I sense there's more to this story... 🍃",
      "*rustles thoughtfully* That's interesting... how does it make you feel? 💚",
      "*perks up leaves* Oh? Go on, I'm all ears~ well, all leaves 🌿",
    ];

    return defaultResponses[DateTime.now().millisecond % defaultResponses.length];
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  void resetChat() {
    if (_model != null) {
      _chatSession = _model!.startChat();
      debugPrint('🔄 Fern: Fresh conversation started~');
    }
  }

  /// Test connection
  Future<bool> testConnection() async {
    try {
      final response = await chat("Hello!");
      return response.isNotEmpty && !response.contains("forest connection");
    } catch (e) {
      return false;
    }
  }
}