// models/mood_entry_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class MoodEntry {
  final String id;
  final String userId;
  final String journalText;
  final String detectedMood;
  final double sentimentScore;
  final double confidence;
  final DateTime createdAt;
  final List<String>? tags;
  final bool isDeleted;

  MoodEntry({
    required this.id,
    required this.userId,
    required this.journalText,
    required this.detectedMood,
    required this.sentimentScore,
    this.confidence = 0.5,
    required this.createdAt,
    this.tags,
    this.isDeleted = false,
  });

  factory MoodEntry.fromMap(Map<String, dynamic> map, String id) {
    return MoodEntry(
      id: id,
      userId: map['userId'] ?? '',
      journalText: map['journalText'] ?? '',
      detectedMood: map['detectedMood'] ?? 'neutral',
      sentimentScore: _parseDouble(map['sentimentScore']),
      confidence: _parseDouble(map['confidence'], defaultValue: 0.5),
      createdAt: _parseDateTime(map['createdAt']),
      tags: map['tags'] != null ? List<String>.from(map['tags']) : null,
      isDeleted: map['isDeleted'] ?? false,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();

    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    } else if (value is DateTime) {
      return value;
    }

    return DateTime.now();
  }

  static double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'journalText': journalText,
      'detectedMood': detectedMood,
      'sentimentScore': sentimentScore,
      'confidence': confidence,
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
      'isDeleted': isDeleted,
    };
  }

  MoodEntry copyWith({
    String? id,
    String? userId,
    String? journalText,
    String? detectedMood,
    double? sentimentScore,
    double? confidence,
    DateTime? createdAt,
    List<String>? tags,
    bool? isDeleted,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      journalText: journalText ?? this.journalText,
      detectedMood: detectedMood ?? this.detectedMood,
      sentimentScore: sentimentScore ?? this.sentimentScore,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  String get moodEmoji {
    switch (detectedMood.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'calm':
        return '😌';
      case 'sad':
        return '😢';
      case 'anxious':
        return '😰';
      case 'stressed':
        return '😫';
      case 'angry':
        return '😠';
      case 'tired':
        return '😴';
      case 'hopeful':
        return '🌟';
      case 'confused':
        return '😕';
      case 'lonely':
        return '💙';
      default:
        return '😐';
    }
  }

  bool get isRecent {
    return DateTime.now().difference(createdAt).inHours < 1;
  }

  String get formattedDate {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
    final calendarDayDiff = todayDate.difference(entryDate).inDays;

    if (calendarDayDiff == 0) {
      final difference = now.difference(createdAt);
      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else {
        return '${difference.inHours}h ago';
      }
    } else if (calendarDayDiff == 1) {
      return 'Yesterday';
    } else if (calendarDayDiff < 7) {
      return '$calendarDayDiff days ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MoodEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MoodEntry(id: $id, mood: $detectedMood, score: $sentimentScore)';
  }
}