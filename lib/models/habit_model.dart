// models/habit_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Habit {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final List<DateTime> completedDates;
  final List<DateTime> rewardedDates;
  final DateTime createdAt;
  int currentStreak;
  int longestStreak;

  final String? reminderTime;
  final bool isArchived;
  final Map<String, dynamic>? metadata;

  Habit({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.completedDates,
    List<DateTime>? rewardedDates,
    required this.createdAt,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.reminderTime,
    this.isArchived = false,
    this.metadata,
  }) : rewardedDates = rewardedDates ?? [];

  factory Habit.fromMap(Map<String, dynamic> map, String id) {
    try {
      List<DateTime> parsedDates = [];
      if (map['completedDates'] != null) {
        final dates = map['completedDates'] as List<dynamic>;
        parsedDates = dates.map((date) => _parseDateTime(date)).toList();
      }

      List<DateTime> parsedRewardedDates = [];
      if (map['rewardedDates'] != null) {
        final dates = map['rewardedDates'] as List<dynamic>;
        parsedRewardedDates = dates.map((date) => _parseDateTime(date)).toList();
      }

      return Habit(
        id: id,
        userId: map['userId'] ?? '',
        title: map['title'] ?? '',
        description: map['description'] ?? '',
        category: map['category'] ?? 'Self-Care',
        completedDates: parsedDates,
        rewardedDates: parsedRewardedDates,
        createdAt: _parseDateTime(map['createdAt']),
        currentStreak: map['currentStreak'] ?? 0,
        longestStreak: map['longestStreak'] ?? 0,
        reminderTime: map['reminderTime'],
        isArchived: map['isArchived'] ?? false,
        metadata: map['metadata'] != null
            ? Map<String, dynamic>.from(map['metadata'])
            : null,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Error in Habit.fromMap: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      rethrow;
    }
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

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'completedDates':
      completedDates.map((date) => date.toIso8601String()).toList(),
      'rewardedDates':
      rewardedDates.map((date) => date.toIso8601String()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'reminderTime': reminderTime,
      'isArchived': isArchived,
      'metadata': metadata,
    };
  }

  bool isCompletedToday() {
    final today = DateTime.now();
    return completedDates.any((date) => _isSameDay(date, today));
  }

  bool isRewardedToday() {
    final today = DateTime.now();
    return rewardedDates.any((date) => _isSameDay(date, today));
  }

  bool canClaimReward() {
    return isCompletedToday() && !isRewardedToday();
  }

  bool isCompletedOnDate(DateTime date) {
    return completedDates.any((d) => _isSameDay(d, date));
  }

  int get weeklyCompletionCount {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return completedDates
        .where((date) => date.isAfter(weekStart) || _isSameDay(date, weekStart))
        .length;
  }

  int get monthlyCompletionCount {
    final now = DateTime.now();
    return completedDates
        .where((date) => date.year == now.year && date.month == now.month)
        .length;
  }

  double get completionRate {
    final daysSinceCreation = DateTime.now().difference(createdAt).inDays + 1;
    if (daysSinceCreation <= 0) return 0.0;

    final uniqueDays = completedDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .length;

    return (uniqueDays / daysSinceCreation).clamp(0.0, 1.0);
  }

  int? get daysSinceLastCompletion {
    if (completedDates.isEmpty) return null;

    final sortedDates = List<DateTime>.from(completedDates)
      ..sort((a, b) => b.compareTo(a));

    return DateTime.now().difference(sortedDates.first).inDays;
  }

  bool get isAtRisk {
    final days = daysSinceLastCompletion;
    return days != null && days > 2 && currentStreak > 0;
  }

  String get categoryEmoji {
    switch (category) {
      case 'Mindfulness':
        return '🧘';
      case 'Exercise':
        return '💪';
      case 'Social':
        return '👥';
      case 'Creative':
        return '🎨';
      case 'Learning':
        return '📚';
      case 'Self-Care':
        return '💚';
      default:
        return '✨';
    }
  }

  String get streakEmoji {
    if (currentStreak == 0) return '';
    if (currentStreak < 3) return '🔥';
    if (currentStreak < 7) return '🔥🔥';
    if (currentStreak < 14) return '🔥🔥🔥';
    if (currentStreak < 30) return '⭐';
    return '🏆';
  }

  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Habit copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    List<DateTime>? completedDates,
    List<DateTime>? rewardedDates,
    DateTime? createdAt,
    int? currentStreak,
    int? longestStreak,
    String? reminderTime,
    bool? isArchived,
    Map<String, dynamic>? metadata,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      completedDates: completedDates ?? this.completedDates,
      rewardedDates: rewardedDates ?? this.rewardedDates,
      createdAt: createdAt ?? this.createdAt,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      reminderTime: reminderTime ?? this.reminderTime,
      isArchived: isArchived ?? this.isArchived,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Habit && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Habit(id: $id, title: $title, streak: $currentStreak)';
  }
}