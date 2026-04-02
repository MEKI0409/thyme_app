// services/sentiment_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../utils/constants.dart';

class SentimentService {
  GenerativeModel? _model;
  bool _isInitialized = false;
  String _currentModel = '';

  // Configuration
  static const int _maxRetries = 2;
  static const Duration _timeout = Duration(seconds: 10);

  static const List<String> _availableModels = [
    'gemini-2.5-flash-lite',
    'gemini-2.0-flash',
  ];

  SentimentService() {
    _initializeModel();
  }

  void _initializeModel() {
    try {
      debugPrint('🔍 Checking Gemini configuration...');
      debugPrint('   API Key configured: ${Constants.isGeminiConfigured}');

      if (!Constants.isGeminiConfigured) {
        debugPrint('⚠️ Gemini API key not configured, using keyword analysis');
        _isInitialized = false;
        return;
      }

      _currentModel = Constants.geminiModel;

      _model = GenerativeModel(
        model: _currentModel,
        apiKey: Constants.geminiApiKey,
        generationConfig: GenerationConfig(
          temperature: 0.3, // Low temperature for consistency
          maxOutputTokens: 200,
        ),
      );
      _isInitialized = true;
      debugPrint('✅ Sentiment service initialized with model: $_currentModel');
    } catch (e) {
      debugPrint('❌ Gemini initialization failed: $e');
      _isInitialized = false;
    }
  }

  Future<bool> _tryFallbackModel() async {
    final currentIndex = _availableModels.indexOf(_currentModel);

    for (int i = currentIndex + 1; i < _availableModels.length; i++) {
      final fallbackModel = _availableModels[i];
      debugPrint('🔄 Trying fallback model: $fallbackModel');

      try {
        _model = GenerativeModel(
          model: fallbackModel,
          apiKey: Constants.geminiApiKey,
          generationConfig: GenerationConfig(
            temperature: 0.3,
            maxOutputTokens: 200,
          ),
        );

        _currentModel = fallbackModel;
        _isInitialized = true;
        debugPrint('✅ Successfully switched to fallback model: $fallbackModel');
        return true;
      } catch (e) {
        debugPrint('❌ Fallback model $fallbackModel failed: $e');
        continue;
      }
    }

    _isInitialized = false;
    return false;
  }

  Future<Map<String, dynamic>> analyzeSentiment(String text) async {
    if (text.trim().isEmpty) {
      return _getDefaultResult();
    }

    if (_isInitialized && _model != null) {
      try {
        final result = await _analyzeWithGemini(text);
        if (result != null) {
          return result;
        }
      } catch (e) {
        debugPrint('⚠️ Gemini analysis failed, falling back to keywords: $e');
      }
    }

    return _analyzeWithKeywords(text);
  }

  Future<Map<String, dynamic>?> _analyzeWithGemini(String text) async {
    int attempts = 0;

    while (attempts < _maxRetries) {
      try {
        final prompt = '''Analyze the emotional sentiment of this text and respond ONLY with a JSON object (no markdown, no explanation).

Text: "$text"

Respond with this exact JSON format:
{"mood":"one of: happy, sad, anxious, calm, stressed, angry, tired, hopeful, confused, lonely, neutral","score":number from -1.0 to 1.0 where -1 is very negative and 1 is very positive,"confidence":number from 0.0 to 1.0}

Rules:
- mood must be exactly one of the listed options
- score must be a decimal number
- confidence indicates how certain you are
- Respond ONLY with the JSON, nothing else''';

        final content = [Content.text(prompt)];
        final response = await _model!
            .generateContent(content)
            .timeout(_timeout);

        final responseText = response.text?.trim() ?? '';

        String cleanJson = responseText;
        if (cleanJson.startsWith('```')) {
          cleanJson = cleanJson.replaceAll(RegExp(r'^```json?\n?'), '');
          cleanJson = cleanJson.replaceAll(RegExp(r'\n?```$'), '');
        }
        cleanJson = cleanJson.trim();

        final parsed = jsonDecode(cleanJson) as Map<String, dynamic>;

        final mood = _validateMood(parsed['mood']?.toString());
        final score = _parseDouble(parsed['score'], 0.0).clamp(-1.0, 1.0);
        final confidence = _parseDouble(parsed['confidence'], 0.7).clamp(0.0, 1.0);

        debugPrint('🧠 Gemini sentiment ($_currentModel): mood=$mood, score=$score, confidence=$confidence');

        return {
          'mood': mood,
          'score': score,
          'confidence': confidence,
          'source': 'gemini',
        };
      } on TimeoutException {
        debugPrint('⏱️ Gemini sentiment analysis timed out');
        attempts++;
      } on GenerativeAIException catch (e) {
        debugPrint('🤖 Gemini API error: ${e.message}');

        if (e.message.contains('not found') ||
            e.message.contains('not supported') ||
            e.message.contains('does not exist')) {
          debugPrint('🔄 Model not available, trying fallback...');
          final success = await _tryFallbackModel();
          if (success) {
            continue;
          }
        }
        return null;
      } on FormatException catch (e) {
        debugPrint('❌ Failed to parse Gemini response: $e');
        return null;
      } catch (e) {
        debugPrint('❌ Gemini sentiment error: $e');
        attempts++;
      }

      if (attempts < _maxRetries) {
        await Future.delayed(Duration(seconds: attempts));
      }
    }

    return null;
  }

  /// Validate mood value
  String _validateMood(String? mood) {
    const validMoods = [
      'happy', 'sad', 'anxious', 'calm', 'stressed',
      'angry', 'tired', 'hopeful', 'confused', 'lonely', 'neutral'
    ];

    if (mood == null) return 'neutral';
    final normalized = mood.toLowerCase().trim();
    return validMoods.contains(normalized) ? normalized : 'neutral';
  }

  double _parseDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  Map<String, dynamic> _analyzeWithKeywords(String text) {
    final normalizedText = text.toLowerCase();
    final words = _tokenize(normalizedText);

    final Map<String, double> moodScores = {
      'happy': 0.0,
      'sad': 0.0,
      'anxious': 0.0,
      'calm': 0.0,
      'stressed': 0.0,
      'angry': 0.0,
      'tired': 0.0,
      'hopeful': 0.0,
      'confused': 0.0,
      'lonely': 0.0,
    };

    int totalMatches = 0;

    for (int i = 0; i < words.length; i++) {
      final word = words[i];

      for (final mood in moodScores.keys) {
        final keywords = _moodKeywords[mood] ?? {};

        if (keywords.containsKey(word)) {
          double score = keywords[word]!;

          // Check negation
          bool isNegated = _checkNegation(words, i);
          if (isNegated) {
            score = -score * 0.5;
          }

          double intensityMultiplier = _getIntensityMultiplier(words, i);
          score *= intensityMultiplier;

          moodScores[mood] = moodScores[mood]! + score;
          totalMatches++;
        }
      }
    }

    _adjustNegatedScores(moodScores);

    String dominantMood = 'neutral';
    double maxScore = 0.0;

    moodScores.forEach((mood, score) {
      if (score > maxScore) {
        maxScore = score;
        dominantMood = mood;
      }
    });

    double sentimentScore = _calculateSentimentScore(moodScores);
    double confidence = _calculateConfidence(moodScores, totalMatches, words.length);

    return {
      'mood': dominantMood,
      'score': sentimentScore.clamp(-1.0, 1.0),
      'confidence': confidence.clamp(0.0, 1.0),
      'source': 'keywords',
    };
  }
  Map<String, dynamic> _getDefaultResult() {
    return {
      'mood': 'neutral',
      'score': 0.0,
      'confidence': 0.3,
      'source': 'default',
    };
  }

  static final List<String> _negationWords = [
    'not', 'no', 'never', 'dont', 'doesnt', 'didnt', 'wont',
    'wouldnt', 'couldnt', 'shouldnt', 'isnt', 'arent', 'wasnt',
    'werent', 'havent', 'hasnt', 'hadnt', 'barely', 'hardly',
    'scarcely', 'neither', 'nor', 'nobody', 'nothing', 'nowhere',
    'without', 'cannot', 'cant',
  ];

  static final Map<String, double> _intensityModifiers = {
    'very': 1.5,
    'really': 1.5,
    'extremely': 2.0,
    'incredibly': 2.0,
    'absolutely': 2.0,
    'completely': 1.8,
    'totally': 1.8,
    'so': 1.4,
    'quite': 1.3,
    'pretty': 1.2,
    'fairly': 1.1,
    'somewhat': 0.8,
    'slightly': 0.5,
    'super': 1.6,
    'bit': 0.6,
    'little': 0.6,
  };

  static final Map<String, Map<String, double>> _moodKeywords = {
    'happy': {
      'happy': 1.0, 'joy': 1.2, 'joyful': 1.2, 'excited': 1.0,
      'great': 0.8, 'wonderful': 1.0, 'amazing': 1.0, 'love': 0.9,
      'fantastic': 1.0, 'awesome': 0.9, 'delighted': 1.1, 'thrilled': 1.2,
      'grateful': 0.9, 'blessed': 0.8, 'cheerful': 0.9, 'content': 0.7,
      'pleased': 0.8, 'glad': 0.8, 'elated': 1.3, 'ecstatic': 1.5,
    },
    'sad': {
      'sad': 1.0, 'down': 0.7, 'depressed': 1.3, 'unhappy': 0.9,
      'miserable': 1.2, 'crying': 1.0, 'lonely': 0.9, 'hurt': 0.8,
      'disappointed': 0.8, 'heartbroken': 1.3, 'grief': 1.2, 'sorrow': 1.1,
      'melancholy': 0.9, 'blue': 0.6, 'gloomy': 0.8, 'hopeless': 1.2,
      'despair': 1.4, 'loss': 0.7, 'empty': 0.8,
      'upset': 0.9, 'gutted': 1.0, 'devastated': 1.3, 'mourning': 1.1,
    },
    'anxious': {
      'anxious': 1.0, 'worried': 0.9, 'nervous': 0.9, 'scared': 1.0,
      'panic': 1.3, 'panicking': 1.3, 'fear': 1.0, 'fearful': 1.0,
      'uneasy': 0.7, 'tense': 0.8, 'restless': 0.7, 'apprehensive': 0.8,
      'dread': 1.1, 'terrified': 1.4, 'paranoid': 1.1, 'overthinking': 0.8,
      'anxiousness': 0.9, 'freaking': 1.0, 'shaking': 0.8, 'spiraling': 1.0,
    },
    'calm': {
      'calm': 1.0, 'peaceful': 1.1, 'relaxed': 1.0, 'serene': 1.2,
      'tranquil': 1.2, 'comfortable': 0.7, 'chill': 0.7, 'mellow': 0.8,
      'soothing': 0.9, 'zen': 1.0, 'centered': 0.9, 'grounded': 0.9,
      'balanced': 0.8,
    },
    'stressed': {
      'stressed': 1.0, 'overwhelmed': 1.2, 'pressure': 0.9, 'exhausted': 1.0,
      'frantic': 1.1, 'busy': 0.5, 'overworked': 1.0, 'burnout': 1.3,
      'swamped': 0.9, 'drowning': 1.1, 'struggling': 0.8,
      'deadline': 0.9, 'deadlines': 0.9,
      'frustrated': 1.0, 'frustrating': 0.9, 'frustration': 1.0,
      'overloaded': 1.0, 'chaotic': 0.8, 'hectic': 0.7, 'stressful': 1.0,
    },
    'angry': {
      'angry': 1.0, 'mad': 0.9, 'furious': 1.4, 'rage': 1.5,
      'irritated': 0.7, 'annoyed': 0.6, 'pissed': 1.0,
      'livid': 1.3, 'outraged': 1.2, 'resentful': 0.9, 'bitter': 0.8,
      'hate': 1.1, 'hostile': 1.0,
      'enraged': 1.4, 'fuming': 1.1, 'infuriated': 1.3,
    },
    'tired': {
      'tired': 1.0, 'exhausted': 1.2, 'sleepy': 0.8, 'drained': 1.0,
      'fatigued': 1.0, 'weary': 0.9, 'worn': 0.8, 'sluggish': 0.7,
      'burnedout': 1.1, 'lethargic': 0.9, 'drowsy': 0.7,
    },
    'hopeful': {
      'hopeful': 1.0, 'optimistic': 1.1, 'positive': 0.9, 'encouraged': 0.9,
      'motivated': 0.8, 'inspired': 1.0, 'eager': 0.8,
      'anticipating': 0.9,
    },
    'confused': {
      'confused': 1.0, 'lost': 0.8, 'uncertain': 0.7, 'puzzled': 0.8,
      'bewildered': 1.0, 'perplexed': 0.9, 'unsure': 0.7, 'torn': 0.8,
    },
    'lonely': {
      'lonely': 1.0, 'alone': 0.8, 'isolated': 1.0, 'disconnected': 0.9,
      'abandoned': 1.1, 'forgotten': 0.9, 'excluded': 0.8,
      'invisible': 0.8, 'unwanted': 1.0, 'ignored': 0.8,
    },
  };

  List<String> _tokenize(String text) {
    return text
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
  }

  bool _checkNegation(List<String> words, int index) {
    final start = (index - 3).clamp(0, words.length);
    for (int i = start; i < index; i++) {
      if (_negationWords.contains(words[i])) {
        return true;
      }
    }
    return false;
  }

  double _getIntensityMultiplier(List<String> words, int index) {
    if (index == 0) return 1.0;
    final prevWord = words[index - 1];
    if (_intensityModifiers.containsKey(prevWord)) {
      return _intensityModifiers[prevWord]!;
    }
    return 1.0;
  }

  void _adjustNegatedScores(Map<String, double> scores) {
    if (scores['happy']! < 0) {
      scores['sad'] = scores['sad']! + scores['happy']!.abs() * 0.3;
      scores['happy'] = 0;
    }
    if (scores['calm']! < 0) {
      scores['anxious'] = scores['anxious']! + scores['calm']!.abs() * 0.3;
      scores['stressed'] = scores['stressed']! + scores['calm']!.abs() * 0.2;
      scores['calm'] = 0;
    }
  }

  double _calculateSentimentScore(Map<String, double> scores) {
    double positive = (scores['happy'] ?? 0) +
        (scores['calm'] ?? 0) +
        (scores['hopeful'] ?? 0);
    double negative = (scores['sad'] ?? 0) +
        (scores['anxious'] ?? 0) +
        (scores['stressed'] ?? 0) +
        (scores['angry'] ?? 0) +
        (scores['lonely'] ?? 0);

    if (positive + negative == 0) return 0.0;
    return (positive - negative) / (positive + negative + 1);
  }

  double _calculateConfidence(
      Map<String, double> scores, int matchCount, int wordCount) {
    if (matchCount == 0) return 0.2;

    double matchDensity = (matchCount / wordCount).clamp(0.0, 0.5) * 2;

    final sortedScores = scores.values.toList()
      ..sort((a, b) => b.compareTo(a));
    double clarity = 0.5;
    if (sortedScores.length >= 2 && sortedScores[0] > 0) {
      clarity = 1 - (sortedScores[1] / sortedScores[0]).clamp(0.0, 1.0);
    }

    double strength = (sortedScores[0] / 3).clamp(0.0, 1.0);

    return (matchDensity * 0.3 + clarity * 0.4 + strength * 0.3)
        .clamp(0.3, 0.95);
  }


  String getMoodEmoji(String mood) {
    return Constants.getMoodEmoji(mood);
  }

  int getMoodColor(String mood) {
    final color = Constants.getMoodColor(mood);
    return color.value;
  }

  bool get isAvailable => _isInitialized && _model != null;

  String get currentModel => _currentModel;

  void reinitialize() {
    _isInitialized = false;
    _model = null;
    _currentModel = '';
    _initializeModel();
  }
}