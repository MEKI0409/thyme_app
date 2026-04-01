// test/sentiment_analysis_test.dart
// ============================================================================
// SENTIMENT ANALYSIS SERVICE - COMPREHENSIVE UNIT TESTS
// ============================================================================
//
// SENTIMENT OUTPUT STRUCTURE:
//   {
//     'mood': String,       // happy, sad, anxious, calm, stressed, etc.
//     'score': double,      // Range: -1.0 to 1.0
//     'confidence': double, // Range: 0.0 to 1.0
//     'source': String      // 'gemini', 'keywords', or 'default'
//   }
//
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:thyme_app/services/sentiment_service.dart';
import 'package:thyme_app/utils/constants.dart';

void main() {
  group('Sentiment Analysis Tests', () {
    late SentimentService sentimentService;

    setUp(() {
      sentimentService = SentimentService();
    });

    // ========================================================================
    // TEST GROUP 1: Happy Mood Detection
    // ========================================================================
    group('Happy Mood Detection', () {
      test('TC-SA1.1: Should detect happy mood from explicit positive text', () async {
        final result = await sentimentService.analyzeSentiment(
            'I feel so happy today! Everything is wonderful and amazing!'
        );

        expect(result['mood'], equals('happy'));
        expect(result['score'], greaterThan(0));
      });

      test('TC-SA1.2: Should detect happy mood from joy keywords', () async {
        final result = await sentimentService.analyzeSentiment(
            'I am filled with joy and love for life'
        );

        expect(result['mood'], equals('happy'));
      });

      test('TC-SA1.3: Should detect happy mood from excitement', () async {
        final result = await sentimentService.analyzeSentiment(
            'This is fantastic! I am so excited about today!'
        );

        expect(result['mood'], equals('happy'));
      });

      test('TC-SA1.4: Should detect happy from grateful expressions', () async {
        final result = await sentimentService.analyzeSentiment(
            'I am so grateful and thankful for everything'
        );

        expect(result['mood'], equals('happy'));
        expect(result['score'], greaterThan(0));
      });
    });

    // ========================================================================
    // TEST GROUP 2: Sad Mood Detection
    // ========================================================================
    group('Sad Mood Detection', () {
      test('TC-SA2.1: Should detect sad mood from negative text', () async {
        final result = await sentimentService.analyzeSentiment(
            'I feel so sad and down today. Everything feels miserable.'
        );

        expect(result['mood'], equals('sad'));
        expect(result['score'], lessThan(0));
      });

      test('TC-SA2.2: Should detect sad mood from loneliness', () async {
        final result = await sentimentService.analyzeSentiment(
            'I feel lonely and unhappy. Nobody understands me.'
        );

        expect(['sad', 'lonely'].contains(result['mood']), isTrue);
      });

      test('TC-SA2.3: Should detect sad mood from disappointment', () async {
        final result = await sentimentService.analyzeSentiment(
            'I am so disappointed and hurt by what happened'
        );

        expect(result['mood'], equals('sad'));
      });

      test('TC-SA2.4: Should detect sad from crying expressions', () async {
        final result = await sentimentService.analyzeSentiment(
            'I feel like crying. I am heartbroken.'
        );

        expect(result['mood'], equals('sad'));
        expect(result['score'], lessThan(0));
      });
    });

    // ========================================================================
    // TEST GROUP 3: Anxious Mood Detection
    // ========================================================================
    group('Anxious Mood Detection', () {
      test('TC-SA3.1: Should detect anxious mood from worry text', () async {
        final result = await sentimentService.analyzeSentiment(
            'I am so anxious and worried about everything'
        );

        expect(result['mood'], equals('anxious'));
        expect(result['score'], lessThan(0));
      });

      test('TC-SA3.2: Should detect anxious mood from fear keywords', () async {
        final result = await sentimentService.analyzeSentiment(
            'I feel scared and nervous. There is so much fear in me.'
        );

        expect(result['mood'], equals('anxious'));
      });

      test('TC-SA3.3: Should detect anxious mood from panic', () async {
        final result = await sentimentService.analyzeSentiment(
            'I feel like I might panic. Everything feels tense and uneasy.'
        );

        expect(result['mood'], equals('anxious'));
      });

      test('TC-SA3.4: Should detect anxious from uncertainty', () async {
        final result = await sentimentService.analyzeSentiment(
            'I am uncertain and apprehensive about the future'
        );

        expect(result['mood'], equals('anxious'));
      });
    });

    // ========================================================================
    // TEST GROUP 4: Calm Mood Detection
    // ========================================================================
    group('Calm Mood Detection', () {
      test('TC-SA4.1: Should detect calm mood from peaceful text', () async {
        final result = await sentimentService.analyzeSentiment(
            'I feel calm and peaceful today. Everything is serene.'
        );

        expect(result['mood'], equals('calm'));
        expect(result['score'], greaterThan(0));
      });

      test('TC-SA4.2: Should detect calm mood from relaxation', () async {
        final result = await sentimentService.analyzeSentiment(
            'I am so relaxed and tranquil. Feeling very content.'
        );

        expect(result['mood'], equals('calm'));
      });

      test('TC-SA4.3: Should detect calm mood from comfort', () async {
        final result = await sentimentService.analyzeSentiment(
            'I feel comfortable and at peace with myself'
        );

        expect(result['mood'], equals('calm'));
      });

      test('TC-SA4.4: Should detect calm from meditation expressions', () async {
        final result = await sentimentService.analyzeSentiment(
            'I feel centered and balanced after meditation'
        );

        expect(result['mood'], equals('calm'));
      });
    });

    // ========================================================================
    // TEST GROUP 5: Stressed Mood Detection
    // ========================================================================
    group('Stressed Mood Detection', () {
      test('TC-SA5.1: Should detect stressed mood from overwhelm', () async {
        final result = await sentimentService.analyzeSentiment(
            'I am so stressed and overwhelmed with work'
        );

        expect(result['mood'], equals('stressed'));
        expect(result['score'], lessThan(0));
      });

      test('TC-SA5.2: Should detect stressed mood from pressure', () async {
        final result = await sentimentService.analyzeSentiment(
            'There is too much pressure. I feel burnt out and exhausted.'
        );

        expect(result['mood'], equals('stressed'));
      });

      test('TC-SA5.3: Should detect stressed mood from frustration', () async {
        final result = await sentimentService.analyzeSentiment(
            'I am frustrated with everything. Nothing is working out.'
        );

        expect(result['mood'], equals('stressed'));
      });

      test('TC-SA5.4: Should detect stressed from deadline pressure', () async {
        final result = await sentimentService.analyzeSentiment(
            'The deadlines are killing me. I cannot cope with this workload.'
        );

        expect(result['mood'], equals('stressed'));
      });
    });

    // ========================================================================
    // TEST GROUP 6: Neutral Mood Detection
    // ========================================================================
    group('Neutral Mood Detection', () {
      test('TC-SA6.1: Should detect neutral mood from factual text', () async {
        final result = await sentimentService.analyzeSentiment(
            'I went to the store today. I bought some groceries.'
        );

        expect(result['mood'], equals('neutral'));
      });

      test('TC-SA6.2: Should detect neutral mood from descriptive text', () async {
        final result = await sentimentService.analyzeSentiment(
            'The meeting was about project updates. We discussed schedules.'
        );

        expect(result['mood'], equals('neutral'));
      });

      test('TC-SA6.3: Should detect neutral mood from weather talk', () async {
        final result = await sentimentService.analyzeSentiment(
            'The weather is cloudy. I had lunch at noon.'
        );

        expect(result['mood'], equals('neutral'));
      });
    });

    // ========================================================================
    // TEST GROUP 7: Sentiment Score Range Validation
    // ========================================================================
    group('Sentiment Score Range Validation', () {
      test('TC-SA7.1: Score should always be between -1 and 1', () async {
        final testTexts = [
          'I am extremely happy and joyful!',
          'I feel devastatingly sad and miserable',
          'Just a normal day',
          'Very anxious and worried',
          'Completely calm and peaceful',
        ];

        for (var text in testTexts) {
          final result = await sentimentService.analyzeSentiment(text);

          expect(result['score'], greaterThanOrEqualTo(-1.0),
              reason: 'Score for "$text" should be >= -1.0');
          expect(result['score'], lessThanOrEqualTo(1.0),
              reason: 'Score for "$text" should be <= 1.0');
        }
      });

      test('TC-SA7.2: Positive moods should have positive scores', () async {
        final positiveTexts = [
          'I feel happy and wonderful',
          'Everything is calm and peaceful',
        ];

        for (var text in positiveTexts) {
          final result = await sentimentService.analyzeSentiment(text);

          if (result['mood'] == 'happy' || result['mood'] == 'calm') {
            expect(result['score'], greaterThan(0),
                reason: 'Positive mood should have positive score');
          }
        }
      });

      test('TC-SA7.3: Negative moods should have negative scores', () async {
        final negativeTexts = [
          'I feel sad and depressed',
          'I am anxious and scared',
          'So stressed and overwhelmed',
        ];

        for (var text in negativeTexts) {
          final result = await sentimentService.analyzeSentiment(text);

          expect(result['score'], lessThan(0),
              reason: 'Negative mood should have negative score');
        }
      });

      test('TC-SA7.4: Confidence should be between 0 and 1', () async {
        final result = await sentimentService.analyzeSentiment(
            'I feel happy today'
        );

        expect(result['confidence'], greaterThanOrEqualTo(0.0));
        expect(result['confidence'], lessThanOrEqualTo(1.0));
      });
    });

    // ========================================================================
    // TEST GROUP 8: Edge Cases
    // ========================================================================
    group('Edge Cases', () {
      test('TC-SA8.1: Empty string should return neutral', () async {
        final result = await sentimentService.analyzeSentiment('');

        expect(result['mood'], equals('neutral'));
      });

      test('TC-SA8.2: Mixed emotions should detect dominant mood', () async {
        final result = await sentimentService.analyzeSentiment(
            'I feel happy but also a bit anxious about tomorrow'
        );

        expect(result['mood'], isNotNull);
        expect(['happy', 'anxious', 'neutral'].contains(result['mood']), isTrue);
      });

      test('TC-SA8.3: Analysis should be case insensitive', () async {
        final lowerResult = await sentimentService.analyzeSentiment('i feel happy');
        final upperResult = await sentimentService.analyzeSentiment('I FEEL HAPPY');

        expect(lowerResult['mood'], equals(upperResult['mood']));
      });

      test('TC-SA8.4: Should handle special characters gracefully', () async {
        final result = await sentimentService.analyzeSentiment(
            'I feel happy!!! So wonderful...'
        );

        expect(result['mood'], equals('happy'));
      });

      test('TC-SA8.5: Should handle very long text', () async {
        final longText = 'I feel happy. ' * 100;
        final result = await sentimentService.analyzeSentiment(longText);

        expect(result['mood'], equals('happy'));
      });

      test('TC-SA8.6: Whitespace-only should return neutral', () async {
        final result = await sentimentService.analyzeSentiment('   ');

        expect(result['mood'], equals('neutral'));
      });

      test('TC-SA8.7: Single emoji should return neutral', () async {
        final result = await sentimentService.analyzeSentiment('😊');

        expect(result['mood'], equals('neutral'));
      });

      test('TC-SA8.8: Numbers only should return neutral', () async {
        final result = await sentimentService.analyzeSentiment('12345');

        expect(result['mood'], equals('neutral'));
      });
    });

    // ========================================================================
    // TEST GROUP 9: Source Attribution
    // ========================================================================
    group('Source Attribution', () {
      test('TC-SA9.1: Result should include source information', () async {
        final result = await sentimentService.analyzeSentiment(
            'I feel happy today'
        );

        expect(result.containsKey('source'), isTrue);
        expect(result['source'], isNotNull);
      });

      test('TC-SA9.2: Source should be one of valid values', () async {
        final result = await sentimentService.analyzeSentiment(
            'I am feeling calm'
        );

        final validSources = ['gemini', 'keywords', 'default'];
        expect(validSources.contains(result['source']), isTrue);
      });
    });

    // ========================================================================
    // TEST GROUP 10: Emoji and Color Helpers
    // ========================================================================
    group('Emoji and Color Helpers', () {
      test('TC-SA10.1: Each mood should have a corresponding emoji', () {
        final moodEmojis = {
          'happy': '😊',
          'sad': '😢',
          'anxious': '😰',
          'calm': '😌',
          'stressed': '😫',
          'angry': '😠',
          'tired': '😴',
          'hopeful': '🌟',
          'confused': '😕',
          'lonely': '💙',
          'neutral': '😐',
        };

        for (var entry in moodEmojis.entries) {
          final emoji = sentimentService.getMoodEmoji(entry.key);
          expect(emoji, equals(entry.value),
              reason: 'Mood "${entry.key}" should have emoji "${entry.value}"');
        }
      });

      test('TC-SA10.2: Unknown mood should return default emoji', () {
        final emoji = sentimentService.getMoodEmoji('unknown_mood');

        expect(emoji, equals('😐'));
      });

      test('TC-SA10.3: Each mood should return a valid color code', () {
        final moods = ['happy', 'sad', 'anxious', 'calm', 'stressed', 'neutral'];

        for (var mood in moods) {
          final color = sentimentService.getMoodColor(mood);

          expect(color, isA<int>());
          expect(color, greaterThan(0));
        }
      });

      test('TC-SA10.4: getMoodEmoji should match Constants', () {
        for (final mood in Constants.allMoods) {
          final serviceEmoji = sentimentService.getMoodEmoji(mood);
          final constantsEmoji = Constants.getMoodEmoji(mood);

          expect(serviceEmoji, equals(constantsEmoji),
              reason: 'Mood "$mood" emoji should match Constants');
        }
      });
    });

    // ========================================================================
    // TEST GROUP 11: Integration - Valid Mood Values for Garden
    // ========================================================================
    group('Integration - Valid Mood Values for Garden', () {
      test('TC-SA11.1: Detected mood should be a valid garden mood', () async {
        final testCases = {
          'happy': 'I feel so happy and wonderful!',
          'sad': 'I feel sad and down today',
          'anxious': 'I am worried and anxious',
          'calm': 'Everything feels peaceful and calm',
          'stressed': 'I am so stressed and overwhelmed',
          'neutral': 'Today is an ordinary day',
        };

        for (var entry in testCases.entries) {
          final result = await sentimentService.analyzeSentiment(entry.value);

          expect(Constants.allMoods.contains(result['mood']), isTrue,
              reason: 'Detected mood "${result['mood']}" should be valid');
        }
      });

      test('TC-SA11.2: Mood should map to correct garden ambiance', () async {
        final result = await sentimentService.analyzeSentiment(
            'I feel very anxious and worried'
        );

        final mood = result['mood'] as String;

        // Anxious should map to therapeutic categories
        if (mood == 'anxious') {
          final categories = Constants.getRecommendedCategories(mood);
          expect(categories, contains('Mindfulness'));
        }
      });

      test('TC-SA11.3: All detected moods should have emoji and color', () async {
        final testTexts = [
          'I feel happy',
          'I feel sad',
          'I feel anxious',
          'I feel calm',
          'I feel stressed',
        ];

        for (var text in testTexts) {
          final result = await sentimentService.analyzeSentiment(text);
          final mood = result['mood'] as String;

          expect(sentimentService.getMoodEmoji(mood), isNotEmpty);
          expect(sentimentService.getMoodColor(mood), greaterThan(0));
        }
      });
    });
  });
}