// controllers/habit_controller.dart
// ✅ IMPROVED: Fixed streak calculation edge cases, better error handling
// ✅ FIXED: getHabitById 使用 indexWhere 替代 try-catch，效率更高
// ✅ FIXED (v2): completeHabit 加锁防止双击竞态

import 'package:flutter/foundation.dart';
import 'dart:async';
import '../services/firebase_service.dart';
import '../models/habit_model.dart';

class HabitController extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  List<Habit> _habits = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _habitsSubscription;
  String? _currentUserId;

  // ✅ FIXED (v2): 防止同一 habit 同时被完成多次
  final Set<String> _completingHabitIds = {};

  List<Habit> get habits => List.unmodifiable(_habits); // ✅ FIXED: 防止外部直接修改内部列表
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ✅ Filter getters
  List<Habit> get activeHabits =>
      _habits.where((h) => !h.isArchived).toList();

  List<Habit> get completedTodayHabits =>
      activeHabits.where((h) => h.isCompletedToday()).toList();

  List<Habit> get pendingHabits =>
      activeHabits.where((h) => !h.isCompletedToday()).toList();

  List<Habit> get archivedHabits =>
      _habits.where((h) => h.isArchived).toList();

  // ✅ Statistics
  int get totalHabits => activeHabits.length;
  int get completedToday => completedTodayHabits.length;
  double get completionRate =>
      totalHabits > 0 ? completedToday / totalHabits : 0.0;

  int get totalStreakDays =>
      activeHabits.fold(0, (sum, h) => sum + h.currentStreak);

  int get longestCurrentStreak => activeHabits.isEmpty
      ? 0
      : activeHabits.map((h) => h.currentStreak).reduce((a, b) => a > b ? a : b);

  // ✅ Debug logging
  void _log(String message) {
    if (kDebugMode) {
      debugPrint('🎯 HabitController: $message');
    }
  }

  void _logError(String message, [dynamic error]) {
    if (kDebugMode) {
      debugPrint('❌ HabitController Error: $message');
      if (error != null) {
        debugPrint('Error details: $error');
      }
    }
  }

  void loadHabits(String userId) {
    _currentUserId = userId;
    _log('Loading habits for user: $userId');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Cancel previous subscription
    _habitsSubscription?.cancel();

    _habitsSubscription = _firebaseService.getHabitsForUser(userId).listen(
          (snapshot) {
        try {
          _log('Received ${snapshot.docs.length} documents from Firestore');

          _habits = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Habit.fromMap(data, doc.id);
          }).toList();

          // Sort by creation date (newest first) or by category
          _habits.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          _log('Successfully loaded ${_habits.length} habits');
          _isLoading = false;
          _errorMessage = null;
          notifyListeners();
        } catch (e, stackTrace) {
          _logError('Failed to parse habits', e);
          if (kDebugMode) {
            debugPrint('Stack trace: $stackTrace');
          }
          _errorMessage = 'Failed to parse habits';
          _isLoading = false;
          notifyListeners();
        }
      },
      onError: (error) {
        _logError('Failed to load habits from Firestore', error);
        _errorMessage = 'Failed to load habits. Please check your connection.';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> createHabit({
    required String userId,
    required String title,
    required String description,
    required String category,
    String? reminderTime,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final habitData = {
        'userId': userId,
        'title': title.trim(),
        'description': description.trim(),
        'category': category,
        'completedDates': [],
        'rewardedDates': [],
        'createdAt': DateTime.now().toIso8601String(),
        'currentStreak': 0,
        'longestStreak': 0,
        'reminderTime': reminderTime,
        'isArchived': false,
      };

      _log('Creating habit: $title');
      await _firebaseService.createHabit(habitData);
      _log('Habit created successfully');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _logError('Failed to create habit', e);
      _errorMessage = 'Failed to create habit. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// ✅ Complete habit and return reward info
  /// ✅ FIXED (v2): 加锁防止双击 / 高频并发导致重复完成
  Future<Map<String, dynamic>> completeHabit(Habit habit) async {
    // ✅ FIXED (v2): 如果已经在处理中，直接返回
    if (_completingHabitIds.contains(habit.id)) {
      _log('Habit ${habit.title} is already being completed, skipping');
      return {'success': false, 'shouldReward': false, 'reason': 'in_progress'};
    }

    try {
      _completingHabitIds.add(habit.id); // ✅ 加锁

      if (habit.isCompletedToday()) {
        _log('Habit already completed today: ${habit.title}');
        return {'success': false, 'shouldReward': false, 'reason': 'already_completed'};
      }

      final now = DateTime.now();
      final updatedDates = [...habit.completedDates, now];

      // ✅ FIXED: Calculate streak properly
      final newStreak = _calculateStreak(updatedDates);
      final newLongest = newStreak > habit.longestStreak
          ? newStreak
          : habit.longestStreak;

      // ✅ Check if should reward (not rewarded today)
      final shouldReward = !habit.isRewardedToday();

      // Update rewarded dates if should reward
      List<String> updatedRewardedDates = habit.rewardedDates
          .map((date) => date.toIso8601String())
          .toList();

      if (shouldReward) {
        updatedRewardedDates.add(now.toIso8601String());
      }

      _log('Completing habit: ${habit.title}, new streak: $newStreak, shouldReward: $shouldReward');

      await _firebaseService.updateHabit(habit.id, {
        'completedDates': updatedDates
            .map((date) => date.toIso8601String())
            .toList(),
        'rewardedDates': updatedRewardedDates,
        'currentStreak': newStreak,
        'longestStreak': newLongest,
      });

      return {
        'success': true,
        'shouldReward': shouldReward,
        'newStreak': newStreak,
        'isNewRecord': newStreak > habit.longestStreak,
      };
    } catch (e) {
      _logError('Failed to complete habit', e);
      _errorMessage = 'Failed to complete habit';
      notifyListeners();
      return {'success': false, 'shouldReward': false, 'error': e.toString()};
    } finally {
      _completingHabitIds.remove(habit.id); // ✅ 解锁
    }
  }

  /// ✅ Uncomplete habit (rewards are NOT returned - anti-exploit)
  Future<bool> uncompleteHabit(Habit habit) async {
    try {
      if (!habit.isCompletedToday()) {
        _log('Habit not completed today: ${habit.title}');
        return false;
      }

      // Remove today's completion
      final today = DateTime.now();
      final updatedDates = habit.completedDates.where((date) {
        return !(date.year == today.year &&
            date.month == today.month &&
            date.day == today.day);
      }).toList();

      final newStreak = _calculateStreak(updatedDates);

      _log('Uncompleting habit: ${habit.title}');

      // ⚠️ NOTE: rewardedDates is NOT modified - rewards are not returned
      await _firebaseService.updateHabit(habit.id, {
        'completedDates': updatedDates
            .map((date) => date.toIso8601String())
            .toList(),
        'currentStreak': newStreak,
      });

      return true;
    } catch (e) {
      _logError('Failed to uncomplete habit', e);
      _errorMessage = 'Failed to uncomplete habit';
      notifyListeners();
      return false;
    }
  }

  /// ✅ Archive habit instead of delete (soft delete)
  Future<bool> archiveHabit(String habitId) async {
    try {
      _log('Archiving habit: $habitId');
      await _firebaseService.updateHabit(habitId, {
        'isArchived': true,
      });
      return true;
    } catch (e) {
      _logError('Failed to archive habit', e);
      _errorMessage = 'Failed to archive habit';
      notifyListeners();
      return false;
    }
  }

  /// ✅ Restore archived habit
  Future<bool> restoreHabit(String habitId) async {
    try {
      _log('Restoring habit: $habitId');
      await _firebaseService.updateHabit(habitId, {
        'isArchived': false,
      });
      return true;
    } catch (e) {
      _logError('Failed to restore habit', e);
      _errorMessage = 'Failed to restore habit';
      notifyListeners();
      return false;
    }
  }

  /// Permanently delete habit
  Future<bool> deleteHabit(String habitId) async {
    try {
      _log('Deleting habit: $habitId');
      await _firebaseService.deleteHabit(habitId);
      _log('Habit deleted successfully');
      return true;
    } catch (e) {
      _logError('Failed to delete habit', e);
      _errorMessage = 'Failed to delete habit';
      notifyListeners();
      return false;
    }
  }

  /// ✅ Update habit details
  Future<bool> updateHabit(
      String habitId, {
        String? title,
        String? description,
        String? category,
        String? reminderTime,
      }) async {
    try {
      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title.trim();
      if (description != null) updates['description'] = description.trim();
      if (category != null) updates['category'] = category;
      if (reminderTime != null) updates['reminderTime'] = reminderTime;

      if (updates.isEmpty) return true;

      _log('Updating habit: $habitId');
      await _firebaseService.updateHabit(habitId, updates);
      return true;
    } catch (e) {
      _logError('Failed to update habit', e);
      _errorMessage = 'Failed to update habit';
      notifyListeners();
      return false;
    }
  }

  /// ✅ FIXED: Calculate streak with proper edge case handling
  int _calculateStreak(List<DateTime> completedDates) {
    if (completedDates.isEmpty) return 0;

    // ✅ FIXED: 先去重归一化再排序（移除不必要的第一次排序）
    final normalizedDates = completedDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (normalizedDates.isEmpty) return 0;

    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    // ✅ FIX: Check if most recent completion is today or yesterday
    final lastCompletion = normalizedDates.first;
    final daysSinceLastCompletion = today.difference(lastCompletion).inDays;

    // If last completion was more than 1 day ago, streak is broken
    if (daysSinceLastCompletion > 1) {
      return 0;
    }

    // Count consecutive days
    int streak = 1;
    for (int i = 0; i < normalizedDates.length - 1; i++) {
      final current = normalizedDates[i];
      final next = normalizedDates[i + 1];
      final diff = current.difference(next).inDays;

      if (diff == 1) {
        streak++;
      } else {
        // Gap found, stop counting
        break;
      }
    }

    return streak;
  }

  /// ✅ FIXED: Get habit by ID - 使用 indexWhere 替代 try-catch，效率更高
  Habit? getHabitById(String habitId) {
    final index = _habits.indexWhere((h) => h.id == habitId);
    return index != -1 ? _habits[index] : null;
  }

  /// ✅ Get habits by category
  List<Habit> getHabitsByCategory(String category) {
    return activeHabits.where((h) => h.category == category).toList();
  }

  /// ✅ Refresh habits
  Future<void> refresh() async {
    if (_currentUserId != null) {
      loadHabits(_currentUserId!);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// ✅ Reset controller state
  void reset() {
    _habitsSubscription?.cancel();
    _habits = [];
    _isLoading = false;
    _errorMessage = null;
    _currentUserId = null;
    _completingHabitIds.clear(); // ✅ FIXED (v2): 清理锁
    notifyListeners();
  }

  @override
  void dispose() {
    _log('Disposing HabitController');
    _habitsSubscription?.cancel();
    super.dispose();
  }
}