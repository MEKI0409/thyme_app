// services/cohere_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class CohereService {
  bool _isInitialized = false;

  bool get isAvailable => Constants.isCohereConfigured;

  CohereService() {
    _checkAvailability();
  }

  void _checkAvailability() {
    if (!isAvailable) {
      if (kDebugMode) {
        debugPrint('⚠️ Cohere API key not configured');
        debugPrint('   Run with: flutter run --dart-define=COHERE_API_KEY=your_key');
      }
      return;
    }
    _isInitialized = true;
    if (kDebugMode) {
      debugPrint('✅ Cohere fallback ready (model: ${Constants.cohereModel})');
    }
  }


  Future<String> chatWithHistory({
    required String systemPrompt,
    required List<Map<String, String>> conversationHistory,
  }) async {
    if (!_isInitialized) {
      _checkAvailability();
      if (!_isInitialized) {
        throw Exception('Cohere not configured');
      }
    }

    // ── Build messages array for Cohere v2 ──
    final messages = <Map<String, dynamic>>[];

    // System message
    messages.add({
      'role': 'system',
      'content': systemPrompt,
    });

    // Conversation history
    for (final entry in conversationHistory) {
      final role = entry['role'] ?? '';
      final text = (entry['text'] ?? '').trim();
      if (text.isEmpty) continue;

      // Map 'model' → 'assistant' for Cohere
      final cohereRole = role == 'model' ? 'assistant' : role;
      if (cohereRole != 'user' && cohereRole != 'assistant') continue;

      // Merge consecutive same-role messages
      if (messages.isNotEmpty && messages.last['role'] == cohereRole) {
        messages.last['content'] = '${messages.last['content']}\n$text';
      } else {
        messages.add({
          'role': cohereRole,
          'content': text,
        });
      }
    }

    if (messages.isEmpty || messages.last['role'] != 'user') {
      throw Exception('No user message found for Cohere');
    }

    try {
      final response = await http
          .post(
        Uri.parse(Constants.cohereEndpoint),
        headers: {
          'Authorization': 'Bearer ${Constants.cohereApiKey}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'model': Constants.cohereModel,
          'messages': messages,
          'temperature': 0.85,
          'max_tokens': 1024,
        }),
      )
          .timeout(Constants.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final message = data['message'];
        if (message != null && message['content'] != null) {
          final contentList = message['content'] as List<dynamic>;
          final textParts = contentList
              .where((c) => c['type'] == 'text')
              .map((c) => c['text'] as String)
              .toList();
          final text = textParts.join('\n').trim();
          if (text.isNotEmpty) {
            if (kDebugMode) {
              debugPrint(
                  '📥 Fern (cohere/${Constants.cohereModel}): '
                      '${text.substring(0, text.length.clamp(0, 80))}...');
            }
            return text;
          }
        }

        throw Exception('Empty response from Cohere');
      }

      if (response.statusCode == 429) {
        throw Exception('Cohere rate limit exceeded');
      }
      if (response.statusCode == 401) {
        throw Exception('Cohere API key invalid');
      }

      throw Exception(
          'Cohere API error ${response.statusCode}: ${response.body}');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Cohere request failed: $e');
      }
      rethrow;
    }
  }


  /// One-shot generation without conversation history.
  Future<String> generate(String prompt, {String? systemPrompt}) async {
    return chatWithHistory(
      systemPrompt: systemPrompt ?? _defaultPersonality,
      conversationHistory: [
        {'role': 'user', 'text': prompt},
      ],
    );
  }


  Future<bool> testConnection() async {
    if (!isAvailable) return false;

    try {
      final result = await generate(
        'Say "hi" in one word.',
        systemPrompt: 'Reply with a single word only.',
      );
      return result.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Cohere connection test failed: $e');
      }
      return false;
    }
  }

  static const String _defaultPersonality = '''
You are Fern, a gentle forest spirit living in the user's wellness garden.
Be warm, genuine, and a little playful — like a close friend. 
Keep responses short (2-4 sentences). Never give unsolicited advice.
If someone is sad, just be present. Use 1-2 emoji max per message.
Always respond in English.
''';
}