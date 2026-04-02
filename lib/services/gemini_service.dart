// services/gemini_service.dart
//
// 🌿 Fern's AI service — multi-provider fallback chain
//
// Priority: Gemini (primary) → Gemini fallback → Cohere → offline responses
//
// This keeps the same public API so existing screens don't need changes.

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../utils/constants.dart';
import 'cohere_service.dart';

class GeminiService {
  bool _geminiInitialized = false;

  /// Cohere fallback provider — lazy-initialized
  CohereService? _cohereService;

  /// Check if any AI provider is available
  bool get isAvailable => Constants.isGeminiConfigured || Constants.isCohereConfigured;

  /// Specifically check Gemini
  bool get isGeminiAvailable => Constants.isGeminiConfigured;

  /// Specifically check Cohere
  bool get isCohereAvailable => _cohereService?.isAvailable ?? Constants.isCohereConfigured;

  GeminiService() {
    _initialize();
  }

  void _initialize() {
    // Initialize Gemini
    if (Constants.isGeminiConfigured) {
      _geminiInitialized = true;
      if (kDebugMode) {
        debugPrint('✅ Fern is awake~ 🌿 (primary: ${Constants.geminiModel})');
      }
    } else {
      if (kDebugMode) {
        debugPrint('⚠️ Gemini API key not configured');
        debugPrint('   Run with: flutter run --dart-define=GEMINI_API_KEY=your_key');
      }
    }

    // Initialize Cohere fallback
    if (Constants.isCohereConfigured) {
      _cohereService = CohereService();
      if (kDebugMode) {
        debugPrint('✅ Cohere fallback ready~ 🍃 (model: ${Constants.cohereModel})');
      }
    } else {
      if (kDebugMode) {
        debugPrint('⚠️ Cohere fallback not configured (optional)');
        debugPrint('   Run with: flutter run --dart-define=COHERE_API_KEY=your_key');
      }
    }

    if (!isAvailable) {
      if (kDebugMode) {
        debugPrint('❌ No AI provider configured — Fern will use offline responses only');
      }
    }
  }

  // ─────────────────────────────────────────────
  // Multi-turn chat with full conversation history
  // ─────────────────────────────────────────────

  /// Send a message with full conversation history.
  ///
  /// Fallback chain: Gemini primary → Gemini fallback → Cohere → offline
  Future<String> chatWithHistory({
    required String systemPrompt,
    required List<Map<String, String>> conversationHistory,
  }) async {
    // Extract last user message for offline fallback
    final lastUserMsg = conversationHistory
        .lastWhere((e) => e['role'] == 'user', orElse: () => {'text': ''});
    final userText = lastUserMsg['text'] ?? '';

    // If nothing is configured, go straight to offline
    if (!isAvailable) {
      return _getSmartOfflineResponse(userText);
    }

    // ── Step 1: Try Gemini models ──
    Object? lastError;
    if (_geminiInitialized) {
      final geminiResult = await _tryGeminiChat(
        systemPrompt: systemPrompt,
        conversationHistory: conversationHistory,
      );

      if (geminiResult.success) {
        return geminiResult.text!;
      }
      lastError = geminiResult.error;

      // If it's an API key / permission error, skip to Cohere immediately
      // (no point retrying Gemini)
    }

    // ── Step 2: Try Cohere fallback ──
    if (_cohereService != null && _cohereService!.isAvailable) {
      if (kDebugMode) {
        debugPrint('🔄 Falling back to Cohere...');
      }
      try {
        final result = await _cohereService!.chatWithHistory(
          systemPrompt: systemPrompt,
          conversationHistory: conversationHistory,
        );
        if (result.isNotEmpty) {
          return result;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Cohere fallback also failed: $e');
        }
        lastError = e;
      }
    }

    // ── Step 3: All providers failed ──
    if (kDebugMode) {
      debugPrint('❌ All AI providers failed. Last error: $lastError');
    }

    // For quota / rate-limit / region errors, degrade gracefully to offline
    final errStr = (lastError ?? '').toString();
    if (_isRecoverableError(errStr)) {
      if (kDebugMode) {
        debugPrint('🌿 Using offline Fern response (recoverable error)');
      }
      return _getSmartOfflineResponse(userText);
    }

    // For truly unexpected errors, still return offline (don't crash the UI)
    // but also throw so the screen's retry logic can kick in
    throw Exception('All AI providers failed: $lastError');
  }

  /// Internal: attempt Gemini primary + fallback models
  Future<_GeminiResult> _tryGeminiChat({
    required String systemPrompt,
    required List<Map<String, String>> conversationHistory,
  }) async {
    // ── Sanitize history for Gemini ──
    final sanitized = _sanitizeHistory(conversationHistory);
    if (sanitized.isEmpty || sanitized.last['role'] != 'user') {
      return _GeminiResult.failure('No valid user message after sanitization');
    }

    // Build Gemini Content objects
    final allContents = sanitized.map((entry) {
      return Content(entry['role']!, [TextPart(entry['text']!)]);
    }).toList();

    final history = allContents.length > 1
        ? allContents.sublist(0, allContents.length - 1)
        : <Content>[];
    final lastContent = allContents.last;

    // Try each Gemini model
    final models = [Constants.geminiModel, Constants.geminiModelFallback];
    Object? lastError;

    for (final modelName in models) {
      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: Constants.geminiApiKey,
          generationConfig: GenerationConfig(
            temperature: 0.85,
            topK: 40,
            topP: 0.92,
            maxOutputTokens: 1024,
          ),
          systemInstruction: Content.system(systemPrompt),
        );

        final chat = model.startChat(history: history);
        final response = await chat.sendMessage(lastContent);
        final text = response.text?.trim() ?? '';

        if (text.isNotEmpty) {
          if (kDebugMode) {
            debugPrint(
                '📥 Fern ($modelName): ${text.substring(0, text.length.clamp(0, 80))}...');
          }
          return _GeminiResult.ok(text);
        }

        if (kDebugMode) {
          debugPrint('⚠️ Empty response from $modelName, trying next...');
        }
        continue;
      } catch (e) {
        lastError = e;
        final errStr = e.toString();
        if (kDebugMode) {
          debugPrint('⚠️ $modelName failed: $e');
        }

        // Auth/config error → stop trying Gemini entirely
        if (errStr.contains('API key') || errStr.contains('permission')) {
          break;
        }

        // Region block → stop trying Gemini (both models share same region rules)
        if (errStr.contains('UnsupportedUserLocation')) {
          if (kDebugMode) {
            debugPrint('🌍 Region not supported for Gemini — skipping all Gemini models');
          }
          break;
        }

        // Quota → try next Gemini model, then Cohere
        if (_isQuotaError(errStr)) {
          if (kDebugMode) {
            debugPrint('⚠️ Quota exhausted for $modelName, trying next...');
          }
          continue;
        }

        continue;
      }
    }

    return _GeminiResult.failure(lastError);
  }

  /// Sanitize conversation history for Gemini:
  /// - Drop empty entries
  /// - Drop leading 'model' entries (Gemini needs 'user' first)
  /// - Merge consecutive same-role entries
  List<Map<String, String>> _sanitizeHistory(
      List<Map<String, String>> conversationHistory) {
    final sanitized = <Map<String, String>>[];

    for (final entry in conversationHistory) {
      final role = entry['role'] ?? '';
      final text = (entry['text'] ?? '').trim();
      if (text.isEmpty) continue;
      if (role != 'user' && role != 'model') continue;

      // Drop leading model messages
      if (sanitized.isEmpty && role == 'model') continue;

      // Merge consecutive same-role
      if (sanitized.isNotEmpty && sanitized.last['role'] == role) {
        sanitized.last['text'] = '${sanitized.last['text']}\n$text';
      } else {
        sanitized.add({'role': role, 'text': text});
      }
    }

    return sanitized;
  }

  // ─────────────────────────────────────────────
  // Legacy methods (backward compatible)
  // ─────────────────────────────────────────────

  /// Simple one-shot chat (no history).
  Future<String> chat(String userMessage) async {
    return chatWithContext(userMessage);
  }

  /// One-shot chat with context.
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
    if (!isAvailable) {
      return _getSmartOfflineResponse(userMessage);
    }

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

    // Use the unified fallback chain via chatWithHistory
    try {
      return await chatWithHistory(
        systemPrompt: _fallbackPersonality,
        conversationHistory: [
          {'role': 'user', 'text': enrichedMessage},
        ],
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ chatWithContext error: $e');
      }
      return _getSmartOfflineResponse(userMessage);
    }
  }

  // ─────────────────────────────────────────────
  // Habit acknowledgment
  // ─────────────────────────────────────────────

  Future<String> generateGentleAcknowledgment(String habitTitle) async {
    if (!isAvailable) {
      return _getLocalAcknowledgment(habitTitle);
    }

    try {
      final prompt =
          'As Fern (a cozy forest spirit), give a SHORT (1 sentence max) warm '
          'acknowledgment for completing: "$habitTitle"\n'
          'Be genuine, maybe a little playful. One emoji max.';

      // Try Gemini first
      if (_geminiInitialized) {
        final models = [Constants.geminiModel, Constants.geminiModelFallback];
        for (final modelName in models) {
          try {
            final model = GenerativeModel(
              model: modelName,
              apiKey: Constants.geminiApiKey,
              generationConfig: GenerationConfig(
                temperature: 0.9,
                maxOutputTokens: 60,
              ),
            );
            final response =
            await model.generateContent([Content.text(prompt)]);
            final text = response.text?.trim() ?? '';
            if (text.isNotEmpty) return text;
          } catch (e) {
            if (kDebugMode) {
              debugPrint('⚠️ Acknowledgment $modelName failed: $e');
            }
            // Region block → skip remaining Gemini models
            if (e.toString().contains('UnsupportedUserLocation')) break;
            continue;
          }
        }
      }

      // Try Cohere fallback
      if (_cohereService != null && _cohereService!.isAvailable) {
        try {
          final result = await _cohereService!.generate(prompt);
          if (result.isNotEmpty) return result;
        } catch (e) {
          if (kDebugMode) {
            debugPrint('⚠️ Cohere acknowledgment failed: $e');
          }
        }
      }

      return _getLocalAcknowledgment(habitTitle);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Acknowledgment error: $e');
      }
      return _getLocalAcknowledgment(habitTitle);
    }
  }

  // ─────────────────────────────────────────────
  // Connection test
  // ─────────────────────────────────────────────

  /// Test connection to any available provider.
  /// Returns a map with provider status details.
  Future<bool> testConnection() async {
    if (!isAvailable) return false;

    // Try Gemini
    if (_geminiInitialized) {
      try {
        final model = GenerativeModel(
          model: Constants.geminiModel,
          apiKey: Constants.geminiApiKey,
          generationConfig: GenerationConfig(maxOutputTokens: 10),
        );
        final response = await model.generateContent([
          Content.text('Say "hi" in one word.'),
        ]);
        if (response.text?.isNotEmpty ?? false) return true;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Gemini connection test failed: $e');
        }
      }
    }

    // Try Cohere
    if (_cohereService != null) {
      final ok = await _cohereService!.testConnection();
      if (ok) return true;
    }

    return false;
  }

  /// Detailed connection status for debug / settings screen
  Future<Map<String, dynamic>> getProviderStatus() async {
    final status = <String, dynamic>{
      'gemini_configured': Constants.isGeminiConfigured,
      'gemini_model': Constants.geminiModel,
      'cohere_configured': Constants.isCohereConfigured,
      'cohere_model': Constants.cohereModel,
      'any_available': isAvailable,
    };

    // Quick connectivity check (don't await both — try in order)
    if (_geminiInitialized) {
      try {
        final model = GenerativeModel(
          model: Constants.geminiModel,
          apiKey: Constants.geminiApiKey,
          generationConfig: GenerationConfig(maxOutputTokens: 10),
        );
        final response = await model
            .generateContent([Content.text('hi')])
            .timeout(const Duration(seconds: 8));
        status['gemini_connected'] = response.text?.isNotEmpty ?? false;
      } catch (e) {
        status['gemini_connected'] = false;
        status['gemini_error'] = e.toString();
      }
    }

    if (_cohereService != null && _cohereService!.isAvailable) {
      status['cohere_connected'] = await _cohereService!.testConnection();
    }

    return status;
  }

  // ─────────────────────────────────────────────
  // Reset
  // ─────────────────────────────────────────────

  void resetChat() {
    if (kDebugMode) {
      debugPrint('🔄 Fern: Ready for a fresh conversation~');
    }
  }

  // ─────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────

  static const String _fallbackPersonality = '''
You are Fern, a gentle forest spirit living in the user's wellness garden.
Be warm, genuine, and a little playful — like a close friend. 
Keep responses short (2-4 sentences). Never give unsolicited advice.
If someone is sad, just be present. Use 1-2 emoji max per message.
Always respond in English.
''';

  bool _isQuotaError(String errStr) {
    return errStr.contains('quota') ||
        errStr.contains('rate limit') ||
        errStr.contains('429') ||
        errStr.contains('RESOURCE_EXHAUSTED');
  }

  bool _isRecoverableError(String errStr) {
    return _isQuotaError(errStr) ||
        errStr.contains('UnsupportedUserLocation') ||
        errStr.contains('timeout') ||
        errStr.contains('SocketException') ||
        errStr.contains('HandshakeException');
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

    if (_containsAny(lower, ['hi', 'hello', 'hey'])) {
      return "*peeks out from behind a leaf* Oh hello there~ ✨ "
          "I'm Fern! What brings you to the garden today?";
    }

    if (_containsAny(lower, ['sad', 'down', 'upset', 'depressed', 'lonely'])) {
      return "*settles beside you quietly* 🍃\n\n"
          "I'm here... you don't have to explain anything. "
          "Sometimes just sitting together helps.";
    }

    if (_containsAny(
        lower, ['anxious', 'worried', 'nervous', 'stress', 'panic'])) {
      return "*rustles soothingly* 🌿\n\n"
          "Hmm~ that sounds like a lot to carry... "
          "Want to tell me what's weighing on you?";
    }

    if (_containsAny(
        lower, ['happy', 'good', 'great', 'excited', 'amazing'])) {
      return "*spins excitedly* Ooh~! ✨\n\n"
          "I can feel the sunshine in your words! Tell me everything!";
    }

    if (_containsAny(
        lower, ['angry', 'mad', 'furious', 'annoyed', 'frustrated'])) {
      return "*sits with you firmly* 🍃\n\n"
          "I hear you... that sounds really frustrating. "
          "Let it out, I'm not going anywhere.";
    }

    if (_containsAny(lower, ['tired', 'exhausted', 'sleepy', 'drained'])) {
      return "*creates a soft mossy spot* 🌙\n\n"
          "Rest here a while... being tired is your body asking for care.";
    }

    if (_containsAny(lower, ['thank', 'thanks'])) {
      return "*glows warmly* 💚\n\n"
          "Aww~ being here with you is my favorite thing. Come back anytime~";
    }

    if (_containsAny(lower, ['don\'t know', 'confused', 'lost', 'unsure'])) {
      return "*tilts head gently* 🍃\n\n"
          "That's okay... feelings can be like morning mist sometimes. "
          "Want to just sit here together for a bit?";
    }

    if (_containsAny(
        lower, ['breath', 'breathing', 'calm down', 'relax'])) {
      return "*sways gently* 🫧\n\n"
          "Let's try this... breathe in slowly like the wind through leaves... "
          "and let it out like a quiet stream. Again?";
    }

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
}

// ─────────────────────────────────────────────
// Internal result type for Gemini attempts
// ─────────────────────────────────────────────

class _GeminiResult {
  final bool success;
  final String? text;
  final Object? error;

  _GeminiResult._({required this.success, this.text, this.error});

  factory _GeminiResult.ok(String text) =>
      _GeminiResult._(success: true, text: text);

  factory _GeminiResult.failure(Object? error) =>
      _GeminiResult._(success: false, error: error);
}