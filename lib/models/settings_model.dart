// models/settings_model.dart

import 'package:flutter/material.dart';

class ReminderTime {
  final int hour;
  final int minute;

  const ReminderTime({
    this.hour = 9,
    this.minute = 0,
  });

  factory ReminderTime.fromMap(Map<String, dynamic> map) {
    return ReminderTime(
      hour: (map['hour'] ?? 9).clamp(0, 23),
      minute: (map['minute'] ?? 0).clamp(0, 59),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hour': hour,
      'minute': minute,
    };
  }

  TimeOfDay toTimeOfDay() => TimeOfDay(hour: hour, minute: minute);

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
class AppSettings {
  final NotificationSettings notifications;
  final String? locale;


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
    Object? locale = _sentinel,
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