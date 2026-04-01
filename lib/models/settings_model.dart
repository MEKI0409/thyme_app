// models/settings_model.dart
// 用户设置数据模型 ⚙️
// ✅ FIXED: 移除 ReminderTime.isEnabled（冗余字段，与外层 bool 不同步）
// ✅ FIXED: 统一由 NotificationSettings 的 xxxEnabled 控制开关状态
// ✅ IMPROVED: 添加注释说明设计决策

import 'package:flutter/material.dart';

/// 提醒时间模型
/// ⚠️ 注意：isEnabled 已移除，统一由 NotificationSettings 的对应 bool 控制。
///    这里只存储 hour / minute，避免两处 bool 不同步的 bug。
class ReminderTime {
  final int hour;
  final int minute;

  const ReminderTime({
    this.hour = 9,
    this.minute = 0,
  });

  factory ReminderTime.fromMap(Map<String, dynamic> map) {
    return ReminderTime(
      hour: (map['hour'] ?? 9).clamp(0, 23),     // ✅ 防止非法时间值
      minute: (map['minute'] ?? 0).clamp(0, 59),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hour': hour,
      'minute': minute,
    };
  }

  /// 转换为 TimeOfDay（用于 TimePicker）
  TimeOfDay toTimeOfDay() => TimeOfDay(hour: hour, minute: minute);

  /// 从 TimeOfDay 创建新的 ReminderTime
  ReminderTime withTimeOfDay(TimeOfDay time) {
    return ReminderTime(
      hour: time.hour,
      minute: time.minute,
    );
  }

  ReminderTime copyWith({
    int? hour,
    int? minute,
  }) {
    return ReminderTime(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }

  /// 格式化显示时间 (e.g. "09:00 AM")
  String get formatted {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReminderTime &&
        other.hour == hour &&
        other.minute == minute;
  }

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;

  @override
  String toString() => 'ReminderTime($formatted)';
}

/// 通知设置模型
/// ✅ 每种提醒的 enabled 状态统一在这里管理，不在 ReminderTime 内重复存储。
class NotificationSettings {
  final bool habitRemindersEnabled;
  final ReminderTime habitReminderTime;

  final bool journalReminderEnabled;
  final ReminderTime journalReminderTime;

  final bool kindnessReminderEnabled;
  final ReminderTime kindnessReminderTime;

  final bool streakAlertEnabled;

  const NotificationSettings({
    this.habitRemindersEnabled = true,
    this.habitReminderTime = const ReminderTime(hour: 9, minute: 0),
    this.journalReminderEnabled = false,
    this.journalReminderTime = const ReminderTime(hour: 20, minute: 0),
    this.kindnessReminderEnabled = false,
    this.kindnessReminderTime = const ReminderTime(hour: 12, minute: 0),
    this.streakAlertEnabled = true,
  });

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      habitRemindersEnabled: map['habitRemindersEnabled'] ?? true,
      habitReminderTime: map['habitReminderTime'] != null
          ? ReminderTime.fromMap(
          Map<String, dynamic>.from(map['habitReminderTime']))
          : const ReminderTime(hour: 9, minute: 0),

      journalReminderEnabled: map['journalReminderEnabled'] ?? false,
      journalReminderTime: map['journalReminderTime'] != null
          ? ReminderTime.fromMap(
          Map<String, dynamic>.from(map['journalReminderTime']))
          : const ReminderTime(hour: 20, minute: 0),

      kindnessReminderEnabled: map['kindnessReminderEnabled'] ?? false,
      kindnessReminderTime: map['kindnessReminderTime'] != null
          ? ReminderTime.fromMap(
          Map<String, dynamic>.from(map['kindnessReminderTime']))
          : const ReminderTime(hour: 12, minute: 0),

      streakAlertEnabled: map['streakAlertEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'habitRemindersEnabled': habitRemindersEnabled,
      'habitReminderTime': habitReminderTime.toMap(),
      'journalReminderEnabled': journalReminderEnabled,
      'journalReminderTime': journalReminderTime.toMap(),
      'kindnessReminderEnabled': kindnessReminderEnabled,
      'kindnessReminderTime': kindnessReminderTime.toMap(),
      'streakAlertEnabled': streakAlertEnabled,
    };
  }

  NotificationSettings copyWith({
    bool? habitRemindersEnabled,
    ReminderTime? habitReminderTime,
    bool? journalReminderEnabled,
    ReminderTime? journalReminderTime,
    bool? kindnessReminderEnabled,
    ReminderTime? kindnessReminderTime,
    bool? streakAlertEnabled,
  }) {
    return NotificationSettings(
      habitRemindersEnabled:
      habitRemindersEnabled ?? this.habitRemindersEnabled,
      habitReminderTime: habitReminderTime ?? this.habitReminderTime,
      journalReminderEnabled:
      journalReminderEnabled ?? this.journalReminderEnabled,
      journalReminderTime: journalReminderTime ?? this.journalReminderTime,
      kindnessReminderEnabled:
      kindnessReminderEnabled ?? this.kindnessReminderEnabled,
      kindnessReminderTime: kindnessReminderTime ?? this.kindnessReminderTime,
      streakAlertEnabled: streakAlertEnabled ?? this.streakAlertEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationSettings &&
        other.habitRemindersEnabled == habitRemindersEnabled &&
        other.habitReminderTime == habitReminderTime &&
        other.journalReminderEnabled == journalReminderEnabled &&
        other.journalReminderTime == journalReminderTime &&
        other.kindnessReminderEnabled == kindnessReminderEnabled &&
        other.kindnessReminderTime == kindnessReminderTime &&
        other.streakAlertEnabled == streakAlertEnabled;
  }

  @override
  int get hashCode =>
      habitRemindersEnabled.hashCode ^
      habitReminderTime.hashCode ^
      journalReminderEnabled.hashCode ^
      journalReminderTime.hashCode ^
      kindnessReminderEnabled.hashCode ^
      kindnessReminderTime.hashCode ^
      streakAlertEnabled.hashCode;
}

const _sentinel = Object();
/// 完整的用户设置模型
class AppSettings {
  final NotificationSettings notifications;
  final String? locale; // 语言（预留）


  const AppSettings({
    this.notifications = const NotificationSettings(),
    this.locale,
  });

  factory AppSettings.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const AppSettings();

    return AppSettings(
      notifications: map['notifications'] != null
          ? NotificationSettings.fromMap(
          Map<String, dynamic>.from(map['notifications']))
          : const NotificationSettings(),
      locale: map['locale'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notifications': notifications.toMap(),
      'locale': locale,
    };
  }

  AppSettings copyWith({
    NotificationSettings? notifications,
    Object? locale = _sentinel,  // ← sentinel 模式
  }) {
    return AppSettings(
      notifications: notifications ?? this.notifications,
      locale: identical(locale, _sentinel)
          ? this.locale
          : locale as String?,
    );
  }

  @override
  String toString() => 'AppSettings(locale: $locale)';
}