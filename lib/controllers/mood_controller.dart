import 'package:flutter/material.dart';
import 'dart:async';
import '../services/firebase_service.dart';
import '../services/sentiment_service.dart';
import '../models/mood_entry_model.dart';

class MoodController extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final SentimentService _sentimentService = SentimentService();

  List<MoodEntry> _moodEntries = [];
  String? _currentMood;
  bool _isLoading = false;
  String? _errorMessage;

  // ✅ 修复：保存订阅以便取消
  StreamSubscription? _moodEntriesSubscription;

  List<MoodEntry> get moodEntries => _moodEntries;
  String? get currentMood => _currentMood;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  MoodEntry? get latestEntry =>
      _moodEntries.isNotEmpty ? _moodEntries.first : null;

  void loadMoodEntries(String userId) {
    _isLoading = true;
    notifyListeners();

    // ✅ 修复：取消之前的订阅
    _moodEntriesSubscription?.cancel();

    _moodEntriesSubscription = _firebaseService.getMoodEntriesForUser(userId).listen(
          (snapshot) {
        _moodEntries = snapshot.docs.map((doc) {
          try {
            return MoodEntry.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          } catch (e) {
            debugPrint('Error parsing mood entry: $e');
            return null;
          }
        }).whereType<MoodEntry>().toList();

        if (_moodEntries.isNotEmpty) {
          _currentMood = _moodEntries.first.detectedMood;
        }

        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load mood entries: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<MoodEntry?> createMoodEntry({
    required String userId,
    required String journalText,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final sentimentResult = await _sentimentService.analyzeSentiment(journalText);

      final detectedMood = sentimentResult['mood'] ?? 'neutral';
      final sentimentScore = sentimentResult['score'] ?? 0.0;
      final confidence = sentimentResult['confidence'] ?? 0.5; // ✅ FIXED: 读取 confidence

      final moodData = {
        'userId': userId,
        'journalText': journalText,
        'detectedMood': detectedMood,
        'sentimentScore': sentimentScore,
        'confidence': confidence, // ✅ FIXED: 写入 confidence
        'createdAt': DateTime.now().toIso8601String(),
      };

      final entryId = await _firebaseService.createMoodEntry(moodData);

      _currentMood = detectedMood;
      _isLoading = false;
      notifyListeners();

      return MoodEntry(
        id: entryId,
        userId: userId,
        journalText: journalText,
        detectedMood: detectedMood,
        sentimentScore: (sentimentScore as num).toDouble(),
        confidence: (confidence as num).toDouble(), // ✅ FIXED: 传入 confidence
        createdAt: DateTime.now(),
      );
    } catch (e) {
      _errorMessage = 'Failed to create mood entry: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Map<String, int> getMoodDistribution() {
    final distribution = <String, int>{};

    for (var entry in _moodEntries) {
      distribution[entry.detectedMood] =
          (distribution[entry.detectedMood] ?? 0) + 1;
    }

    return distribution;
  }

  double getAverageSentiment() {
    if (_moodEntries.isEmpty) return 0.0;

    final sum = _moodEntries.fold<double>(
        0.0, (prev, entry) => prev + entry.sentimentScore);

    return sum / _moodEntries.length;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ✅ 修复：正确取消订阅
  @override
  void dispose() {
    _moodEntriesSubscription?.cancel();
    super.dispose();
  }
}