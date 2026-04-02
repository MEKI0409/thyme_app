// utils/date_utils.dart

import 'package:intl/intl.dart';

/// 時間格式化
class ThymeDateUtils {
  static String formatRelative(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    }
    if (difference.inDays == 1) {
      return 'Yesterday';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }
    return DateFormat('MMM dd').format(time);
  }

  static String formatRelativeCute(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now ✨';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    }
    if (difference.inDays == 1) {
      return 'Yesterday 💫';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }
    return DateFormat('MMM dd').format(time);
  }

  static String formatTodayOrDate(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final timeDate = DateTime(time.year, time.month, time.day);

    if (timeDate == today) {
      return 'Today ${DateFormat('HH:mm').format(time)}';
    }
    if (timeDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ${DateFormat('HH:mm').format(time)}';
    }
    return DateFormat('MMM dd, HH:mm').format(time);
  }

  static String formatFull(DateTime time) {
    return DateFormat('MMMM dd, yyyy').format(time);
  }

  static String formatShort(DateTime time) {
    return DateFormat('MMM dd').format(time);
  }

  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static String formatWithWeekday(DateTime time) {
    return DateFormat('EEEE, MMM dd').format(time);
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) {
      return 'Night owl? 🦉';
    }
    if (hour < 12) {
      return 'Good morning 🌅';
    }
    if (hour < 17) {
      return 'Good afternoon ☀️';
    }
    if (hour < 21) {
      return 'Good evening 🌆';
    }
    return 'Good night 🌙';
  }

  /// 簡單問候語
  static String getSimpleGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Hello';
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    if (hour < 21) return 'Good evening';
    return 'Good night';
  }

  /// 檢查是否今天
  static bool isToday(DateTime time) {
    final now = DateTime.now();
    return time.year == now.year && time.month == now.month && time.day == now.day;
  }

  /// 檢查是否是昨天
  static bool isYesterday(DateTime time) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return time.year == yesterday.year && time.month == yesterday.month && time.day == yesterday.day;
  }

  /// 檢查是否是本周
  static bool isThisWeek(DateTime time) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return time.isAfter(startOfWeek) && time.isBefore(endOfWeek);
  }

  static int daysFromNow(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final timeDate = DateTime(time.year, time.month, time.day);
    return today.difference(timeDate).inDays;
  }

  static String formatStreak(int days) {
    if (days == 0) return 'Start today!';
    if (days == 1) return '1 day';
    return '$days days';
  }

  static String formatStreakCute(int days) {
    if (days == 0) return 'Start today! 🌱';
    if (days == 1) return '1 day 🌿';
    if (days < 7) return '$days days 🌸';
    if (days < 30) return '$days days 🌺';
    return '$days days 🌳';
  }
}