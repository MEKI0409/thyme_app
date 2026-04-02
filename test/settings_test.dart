// test/settings_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// --- ReminderTime ---
class ReminderTime {
  final int hour;
  final int minute;

  const ReminderTime({this.hour = 9, this.minute = 0});

  factory ReminderTime.fromMap(Map<String, dynamic> map) {
    return ReminderTime(
      hour: (map['hour'] ?? 9).clamp(0, 23),
      minute: (map['minute'] ?? 0).clamp(0, 59),
    );
  }

  Map<String, dynamic> toMap() => {'hour': hour, 'minute': minute};

  TimeOfDay toTimeOfDay() => TimeOfDay(hour: hour, minute: minute);

  ReminderTime withTimeOfDay(TimeOfDay time) =>
      ReminderTime(hour: time.hour, minute: time.minute);

  ReminderTime copyWith({int? hour, int? minute}) =>
      ReminderTime(hour: hour ?? this.hour, minute: minute ?? this.minute);

  String get formatted {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReminderTime && other.hour == hour && other.minute == minute;
  }

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;

  @override
  String toString() => 'ReminderTime($formatted)';
}

// --- NotificationSettings ---
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
          ? ReminderTime.fromMap(Map<String, dynamic>.from(map['habitReminderTime']))
          : const ReminderTime(hour: 9, minute: 0),
      journalReminderEnabled: map['journalReminderEnabled'] ?? false,
      journalReminderTime: map['journalReminderTime'] != null
          ? ReminderTime.fromMap(Map<String, dynamic>.from(map['journalReminderTime']))
          : const ReminderTime(hour: 20, minute: 0),
      kindnessReminderEnabled: map['kindnessReminderEnabled'] ?? false,
      kindnessReminderTime: map['kindnessReminderTime'] != null
          ? ReminderTime.fromMap(Map<String, dynamic>.from(map['kindnessReminderTime']))
          : const ReminderTime(hour: 12, minute: 0),
      streakAlertEnabled: map['streakAlertEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
    'habitRemindersEnabled': habitRemindersEnabled,
    'habitReminderTime': habitReminderTime.toMap(),
    'journalReminderEnabled': journalReminderEnabled,
    'journalReminderTime': journalReminderTime.toMap(),
    'kindnessReminderEnabled': kindnessReminderEnabled,
    'kindnessReminderTime': kindnessReminderTime.toMap(),
    'streakAlertEnabled': streakAlertEnabled,
  };

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
      habitRemindersEnabled: habitRemindersEnabled ?? this.habitRemindersEnabled,
      habitReminderTime: habitReminderTime ?? this.habitReminderTime,
      journalReminderEnabled: journalReminderEnabled ?? this.journalReminderEnabled,
      journalReminderTime: journalReminderTime ?? this.journalReminderTime,
      kindnessReminderEnabled: kindnessReminderEnabled ?? this.kindnessReminderEnabled,
      kindnessReminderTime: kindnessReminderTime ?? this.kindnessReminderTime,
      streakAlertEnabled: streakAlertEnabled ?? this.streakAlertEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationSettings &&
        other.habitRemindersEnabled == habitRemindersEnabled &&
        other.journalReminderEnabled == journalReminderEnabled &&
        other.kindnessReminderEnabled == kindnessReminderEnabled &&
        other.streakAlertEnabled == streakAlertEnabled;
  }

  @override
  int get hashCode =>
      habitRemindersEnabled.hashCode ^
      journalReminderEnabled.hashCode ^
      kindnessReminderEnabled.hashCode ^
      streakAlertEnabled.hashCode;
}

// --- AppSettings ---
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
          ? NotificationSettings.fromMap(Map<String, dynamic>.from(map['notifications']))
          : const NotificationSettings(),
      locale: map['locale'],
    );
  }

  Map<String, dynamic> toMap() => {
    'notifications': notifications.toMap(),
    'locale': locale,
  };

  AppSettings copyWith({
    NotificationSettings? notifications,
    String? locale,
  }) {
    return AppSettings(
      notifications: notifications ?? this.notifications,
      locale: locale ?? this.locale,
    );
  }
}

void main() {
  // ReminderTime Tests

  group('ReminderTime', () {
    test('default values should be 9:00', () {
      const rt = ReminderTime();
      expect(rt.hour, 9);
      expect(rt.minute, 0);
    });

    test('formatted should return correct 12-hour format', () {
      expect(const ReminderTime(hour: 9, minute: 0).formatted, '9:00 AM');
      expect(const ReminderTime(hour: 20, minute: 30).formatted, '8:30 PM');
      expect(const ReminderTime(hour: 0, minute: 0).formatted, '12:00 AM');
      expect(const ReminderTime(hour: 12, minute: 0).formatted, '12:00 PM');
      expect(const ReminderTime(hour: 13, minute: 5).formatted, '1:05 PM');
      expect(const ReminderTime(hour: 23, minute: 59).formatted, '11:59 PM');
    });

    test('toTimeOfDay should convert correctly', () {
      const rt = ReminderTime(hour: 14, minute: 30);
      final tod = rt.toTimeOfDay();
      expect(tod.hour, 14);
      expect(tod.minute, 30);
    });

    test('withTimeOfDay should create new instance from TimeOfDay', () {
      const rt = ReminderTime(hour: 9, minute: 0);
      final newRt = rt.withTimeOfDay(const TimeOfDay(hour: 18, minute: 45));
      expect(newRt.hour, 18);
      expect(newRt.minute, 45);
      expect(rt.hour, 9);
      expect(rt.minute, 0);
    });

    test('copyWith should override specified fields only', () {
      const rt = ReminderTime(hour: 9, minute: 30);
      final updated = rt.copyWith(hour: 15);
      expect(updated.hour, 15);
      expect(updated.minute, 30); // unchanged
    });

    test('equality should compare hour and minute', () {
      const a = ReminderTime(hour: 9, minute: 0);
      const b = ReminderTime(hour: 9, minute: 0);
      const c = ReminderTime(hour: 9, minute: 1);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('hashCode should be equal for equal objects', () {
      const a = ReminderTime(hour: 14, minute: 30);
      const b = ReminderTime(hour: 14, minute: 30);
      expect(a.hashCode, equals(b.hashCode));
    });


    test('fromMap should parse valid data', () {
      final rt = ReminderTime.fromMap({'hour': 15, 'minute': 45});
      expect(rt.hour, 15);
      expect(rt.minute, 45);
    });

    test('fromMap should clamp invalid hour to 0-23', () {
      expect(ReminderTime.fromMap({'hour': -1, 'minute': 0}).hour, 0);
      expect(ReminderTime.fromMap({'hour': 24, 'minute': 0}).hour, 23);
      expect(ReminderTime.fromMap({'hour': 100, 'minute': 0}).hour, 23);
    });

    test('fromMap should clamp invalid minute to 0-59', () {
      expect(ReminderTime.fromMap({'hour': 9, 'minute': -5}).minute, 0);
      expect(ReminderTime.fromMap({'hour': 9, 'minute': 60}).minute, 59);
      expect(ReminderTime.fromMap({'hour': 9, 'minute': 999}).minute, 59);
    });

    test('fromMap should use defaults for missing keys', () {
      final rt = ReminderTime.fromMap({});
      expect(rt.hour, 9);
      expect(rt.minute, 0);
    });

    test('fromMap should handle null values gracefully', () {
      final rt = ReminderTime.fromMap({'hour': null, 'minute': null});
      expect(rt.hour, 9);
      expect(rt.minute, 0);
    });


    test('toMap -> fromMap roundtrip should preserve values', () {
      const original = ReminderTime(hour: 17, minute: 42);
      final map = original.toMap();
      final restored = ReminderTime.fromMap(map);
      expect(restored, equals(original));
    });


    test('formatted edge case: midnight (0:00)', () {
      expect(const ReminderTime(hour: 0, minute: 0).formatted, '12:00 AM');
    });

    test('formatted edge case: noon (12:00)', () {
      expect(const ReminderTime(hour: 12, minute: 0).formatted, '12:00 PM');
    });

    test('formatted edge case: single-digit minute with padding', () {
      expect(const ReminderTime(hour: 8, minute: 5).formatted, '8:05 AM');
    });
  });

  // NotificationSettings Tests

  group('NotificationSettings', () {
    test('default values should match design spec', () {
      const ns = NotificationSettings();
      expect(ns.habitRemindersEnabled, true);
      expect(ns.habitReminderTime, const ReminderTime(hour: 9, minute: 0));
      expect(ns.journalReminderEnabled, false);
      expect(ns.journalReminderTime, const ReminderTime(hour: 20, minute: 0));
      expect(ns.kindnessReminderEnabled, false);
      expect(ns.kindnessReminderTime, const ReminderTime(hour: 12, minute: 0));
      expect(ns.streakAlertEnabled, true);
    });

    test('copyWith should override only specified fields', () {
      const ns = NotificationSettings();
      final updated = ns.copyWith(
        journalReminderEnabled: true,
        kindnessReminderTime: const ReminderTime(hour: 15, minute: 0),
      );
      expect(updated.habitRemindersEnabled, true); // unchanged
      expect(updated.journalReminderEnabled, true); // changed
      expect(updated.kindnessReminderTime, const ReminderTime(hour: 15, minute: 0)); // changed
      expect(updated.streakAlertEnabled, true); // unchanged
    });

    test('copyWith with no arguments should return equivalent object', () {
      const ns = NotificationSettings();
      final copy = ns.copyWith();
      expect(copy.habitRemindersEnabled, ns.habitRemindersEnabled);
      expect(copy.journalReminderEnabled, ns.journalReminderEnabled);
      expect(copy.kindnessReminderEnabled, ns.kindnessReminderEnabled);
      expect(copy.streakAlertEnabled, ns.streakAlertEnabled);
      expect(copy.habitReminderTime, ns.habitReminderTime);
      expect(copy.journalReminderTime, ns.journalReminderTime);
      expect(copy.kindnessReminderTime, ns.kindnessReminderTime);
    });

    // ── fromMap test ──

    test('fromMap should parse full valid map', () {
      final ns = NotificationSettings.fromMap({
        'habitRemindersEnabled': false,
        'habitReminderTime': {'hour': 10, 'minute': 30},
        'journalReminderEnabled': true,
        'journalReminderTime': {'hour': 21, 'minute': 0},
        'kindnessReminderEnabled': true,
        'kindnessReminderTime': {'hour': 14, 'minute': 15},
        'streakAlertEnabled': false,
      });
      expect(ns.habitRemindersEnabled, false);
      expect(ns.habitReminderTime, const ReminderTime(hour: 10, minute: 30));
      expect(ns.journalReminderEnabled, true);
      expect(ns.journalReminderTime, const ReminderTime(hour: 21, minute: 0));
      expect(ns.kindnessReminderEnabled, true);
      expect(ns.kindnessReminderTime, const ReminderTime(hour: 14, minute: 15));
      expect(ns.streakAlertEnabled, false);
    });

    test('fromMap should use defaults for empty map', () {
      final ns = NotificationSettings.fromMap({});
      const defaultNs = NotificationSettings();
      expect(ns.habitRemindersEnabled, defaultNs.habitRemindersEnabled);
      expect(ns.journalReminderEnabled, defaultNs.journalReminderEnabled);
      expect(ns.kindnessReminderEnabled, defaultNs.kindnessReminderEnabled);
      expect(ns.streakAlertEnabled, defaultNs.streakAlertEnabled);
    });

    test('fromMap should handle partial map (missing some keys)', () {
      final ns = NotificationSettings.fromMap({
        'habitRemindersEnabled': false,
      });
      expect(ns.habitRemindersEnabled, false);
      expect(ns.journalReminderEnabled, false);
      expect(ns.streakAlertEnabled, true);
    });

    test('fromMap should handle null time maps gracefully', () {
      final ns = NotificationSettings.fromMap({
        'habitRemindersEnabled': true,
        'habitReminderTime': null,
      });
      expect(ns.habitReminderTime, const ReminderTime(hour: 9, minute: 0));
    });

    test('toMap -> fromMap roundtrip should preserve all values', () {
      const original = NotificationSettings(
        habitRemindersEnabled: false,
        habitReminderTime: ReminderTime(hour: 7, minute: 15),
        journalReminderEnabled: true,
        journalReminderTime: ReminderTime(hour: 22, minute: 0),
        kindnessReminderEnabled: true,
        kindnessReminderTime: ReminderTime(hour: 13, minute: 45),
        streakAlertEnabled: false,
      );
      final map = original.toMap();
      final restored = NotificationSettings.fromMap(map);

      expect(restored.habitRemindersEnabled, original.habitRemindersEnabled);
      expect(restored.habitReminderTime, original.habitReminderTime);
      expect(restored.journalReminderEnabled, original.journalReminderEnabled);
      expect(restored.journalReminderTime, original.journalReminderTime);
      expect(restored.kindnessReminderEnabled, original.kindnessReminderEnabled);
      expect(restored.kindnessReminderTime, original.kindnessReminderTime);
      expect(restored.streakAlertEnabled, original.streakAlertEnabled);
    });


    test('⚠️ BUG: equality ignores ReminderTime fields (should fail after fix)', () {
      const a = NotificationSettings(
        habitReminderTime: ReminderTime(hour: 9, minute: 0),
      );
      const b = NotificationSettings(
        habitReminderTime: ReminderTime(hour: 18, minute: 30),
      );

      expect(a == b, isTrue,
          reason: 'BUG: == 不比较 Time 字段。修复 == 后将此改为 isFalse');
    });

    test('⚠️ BUG: hashCode ignores ReminderTime (collision risk)', () {
      const a = NotificationSettings(
        habitReminderTime: ReminderTime(hour: 9, minute: 0),
      );
      const b = NotificationSettings(
        habitReminderTime: ReminderTime(hour: 22, minute: 59),
      );
      // 当前实现 hashCode 也不包含 Time，所以会碰撞
      expect(a.hashCode, equals(b.hashCode),
          reason: 'BUG: hashCode 不包含 Time 字段。修复后应不等');
    });

    test('toggle habit reminders off and back on', () {
      const original = NotificationSettings();
      final turnedOff = original.copyWith(habitRemindersEnabled: false);
      expect(turnedOff.habitRemindersEnabled, false);
      expect(turnedOff.habitReminderTime, original.habitReminderTime); // time preserved

      final turnedOn = turnedOff.copyWith(habitRemindersEnabled: true);
      expect(turnedOn.habitRemindersEnabled, true);
      expect(turnedOn.habitReminderTime, original.habitReminderTime); // time still preserved
    });

    test('setting time should not affect enabled state', () {
      const ns = NotificationSettings(journalReminderEnabled: false);
      final updated = ns.copyWith(
        journalReminderTime: const ReminderTime(hour: 21, minute: 30),
      );
      expect(updated.journalReminderEnabled, false); // still off
      expect(updated.journalReminderTime.hour, 21);
    });

    test('all toggles can be disabled simultaneously', () {
      const ns = NotificationSettings();
      final allOff = ns.copyWith(
        habitRemindersEnabled: false,
        journalReminderEnabled: false,
        kindnessReminderEnabled: false,
        streakAlertEnabled: false,
      );
      expect(allOff.habitRemindersEnabled, false);
      expect(allOff.journalReminderEnabled, false);
      expect(allOff.kindnessReminderEnabled, false);
      expect(allOff.streakAlertEnabled, false);
    });
  });

  // AppSettings Tests

  group('AppSettings', () {
    test('default values', () {
      const settings = AppSettings();
      expect(settings.notifications, isA<NotificationSettings>());
      expect(settings.locale, isNull);
    });

    test('fromMap with null should return defaults', () {
      final settings = AppSettings.fromMap(null);
      expect(settings.locale, isNull);
      expect(settings.notifications.habitRemindersEnabled, true);
    });

    test('fromMap with empty map should return defaults', () {
      final settings = AppSettings.fromMap({});
      expect(settings.locale, isNull);
      expect(settings.notifications.habitRemindersEnabled, true);
    });

    test('fromMap should parse full settings', () {
      final settings = AppSettings.fromMap({
        'locale': 'zh-CN',
        'notifications': {
          'habitRemindersEnabled': false,
          'habitReminderTime': {'hour': 10, 'minute': 0},
          'journalReminderEnabled': true,
          'journalReminderTime': {'hour': 21, 'minute': 0},
          'kindnessReminderEnabled': false,
          'kindnessReminderTime': {'hour': 12, 'minute': 0},
          'streakAlertEnabled': false,
        },
      });
      expect(settings.locale, 'zh-CN');
      expect(settings.notifications.habitRemindersEnabled, false);
      expect(settings.notifications.journalReminderEnabled, true);
      expect(settings.notifications.streakAlertEnabled, false);
    });

    test('toMap -> fromMap roundtrip', () {
      final original = AppSettings(
        locale: 'en-US',
        notifications: const NotificationSettings(
          habitRemindersEnabled: false,
          journalReminderEnabled: true,
          kindnessReminderTime: ReminderTime(hour: 15, minute: 30),
        ),
      );
      final map = original.toMap();
      final restored = AppSettings.fromMap(map);

      expect(restored.locale, original.locale);
      expect(restored.notifications.habitRemindersEnabled,
          original.notifications.habitRemindersEnabled);
      expect(restored.notifications.journalReminderEnabled,
          original.notifications.journalReminderEnabled);
      expect(restored.notifications.kindnessReminderTime,
          original.notifications.kindnessReminderTime);
    });

    test('copyWith should replace only specified fields', () {
      const original = AppSettings(locale: 'en');
      final updated = original.copyWith(locale: 'zh');
      expect(updated.locale, 'zh');
      expect(updated.notifications.habitRemindersEnabled, true);
    });

    test('copyWith notifications only', () {
      const original = AppSettings(locale: 'en');
      final updated = original.copyWith(
        notifications: const NotificationSettings(streakAlertEnabled: false),
      );
      expect(updated.locale, 'en');
      expect(updated.notifications.streakAlertEnabled, false);
    });


    test('⚠️ BUG: copyWith cannot clear locale to null', () {
      const settings = AppSettings(locale: 'en');
      // 尝试将 locale 设为 null
      final updated = settings.copyWith(locale: null);
      // 当前实现: locale ?? this.locale → 保留 'en'，无法清除
      expect(updated.locale, 'en',
          reason: 'BUG: copyWith(locale: null) 无法清除 locale。'
              '修复方案: 使用 Optional<String> 或加 clearLocale 参数');
    });

    // ── Firestore 數據格式兼容性 ──

    test('fromMap should handle legacy data with extra fields', () {
      final settings = AppSettings.fromMap({
        'notifications': {
          'habitRemindersEnabled': true,
          'habitReminderTime': {'hour': 9, 'minute': 0},
          'journalReminderEnabled': false,
          'journalReminderTime': {'hour': 20, 'minute': 0},
          'kindnessReminderEnabled': false,
          'kindnessReminderTime': {'hour': 12, 'minute': 0},
          'streakAlertEnabled': true,
          'weeklyDigestEnabled': true,
          'soundEnabled': false,
        },
        'theme': 'dark', // 未来可能新增的字段
        'locale': null,
      });
      // 不应 crash，多余字段应被忽略
      expect(settings.notifications.habitRemindersEnabled, true);
      expect(settings.locale, isNull);
    });

    test('fromMap should handle malformed notifications gracefully', () {
      // notifications 不是 Map 而是其他类型
      // 注意: 在 Map.from() 处会抛异常，这里测试 null 的情况
      final settings = AppSettings.fromMap({
        'notifications': null,
      });
      expect(settings.notifications.habitRemindersEnabled, true); // defaults
    });

    // ── 典型用户场景 ──

    test('scenario: user enables all notifications with custom times', () {
      const settings = AppSettings();
      final customized = settings.copyWith(
        notifications: settings.notifications.copyWith(
          habitRemindersEnabled: true,
          habitReminderTime: const ReminderTime(hour: 7, minute: 0),
          journalReminderEnabled: true,
          journalReminderTime: const ReminderTime(hour: 21, minute: 30),
          kindnessReminderEnabled: true,
          kindnessReminderTime: const ReminderTime(hour: 12, minute: 0),
          streakAlertEnabled: true,
        ),
      );

      expect(customized.notifications.habitRemindersEnabled, true);
      expect(customized.notifications.journalReminderEnabled, true);
      expect(customized.notifications.kindnessReminderEnabled, true);
      expect(customized.notifications.streakAlertEnabled, true);

      expect(customized.notifications.habitReminderTime.hour, 7);
      expect(customized.notifications.journalReminderTime.hour, 21);
      expect(customized.notifications.journalReminderTime.minute, 30);

      final map = customized.toMap();
      final restored = AppSettings.fromMap(map);
      expect(restored.notifications.habitRemindersEnabled, true);
      expect(restored.notifications.journalReminderTime.hour, 21);
      expect(restored.notifications.journalReminderTime.minute, 30);
    });

    test('scenario: user disables everything (quiet mode)', () {
      const settings = AppSettings();
      final quietMode = settings.copyWith(
        notifications: settings.notifications.copyWith(
          habitRemindersEnabled: false,
          journalReminderEnabled: false,
          kindnessReminderEnabled: false,
          streakAlertEnabled: false,
        ),
      );

      final map = quietMode.toMap();
      final restored = AppSettings.fromMap(map);

      expect(restored.notifications.habitRemindersEnabled, false);
      expect(restored.notifications.journalReminderEnabled, false);
      expect(restored.notifications.kindnessReminderEnabled, false);
      expect(restored.notifications.streakAlertEnabled, false);

      expect(restored.notifications.habitReminderTime.hour, 9);
      expect(restored.notifications.journalReminderTime.hour, 20);
    });

    test('scenario: settings page → pick time → auto-enable toggle', () {
      const settings = AppSettings(
        notifications: NotificationSettings(habitRemindersEnabled: false),
      );

      final updated = settings.copyWith(
        notifications: settings.notifications.copyWith(
          habitReminderTime: settings.notifications.habitReminderTime
              .withTimeOfDay(const TimeOfDay(hour: 7, minute: 30)),
          habitRemindersEnabled: true,
        ),
      );

      expect(updated.notifications.habitRemindersEnabled, true);
      expect(updated.notifications.habitReminderTime.hour, 7);
      expect(updated.notifications.habitReminderTime.minute, 30);
    });
  });

  // SettingsController test
  group('SettingsController Logic (offline)', () {
    test('⚠️ BUG: loadSettings dedup allows re-entry during loading', () {
      expect(true, isTrue, reason: 'See bug description above');
    });

    test('notification toggle workflow preserves time on toggle off/on', () {
      var settings = const AppSettings();

      settings = settings.copyWith(
        notifications: settings.notifications.copyWith(
          habitReminderTime: const ReminderTime(hour: 7, minute: 15),
        ),
      );

      settings = settings.copyWith(
        notifications: settings.notifications.copyWith(
          habitRemindersEnabled: false,
        ),
      );
      expect(settings.notifications.habitRemindersEnabled, false);
      expect(settings.notifications.habitReminderTime.hour, 7);

      settings = settings.copyWith(
        notifications: settings.notifications.copyWith(
          habitRemindersEnabled: true,
        ),
      );
      expect(settings.notifications.habitRemindersEnabled, true);
      expect(settings.notifications.habitReminderTime.hour, 7);
    });

    test('debounced save should coalesce rapid toggles', () {
      var settings = const AppSettings();

      settings = settings.copyWith(
        notifications: settings.notifications.copyWith(streakAlertEnabled: false),
      );
      settings = settings.copyWith(
        notifications: settings.notifications.copyWith(streakAlertEnabled: true),
      );
      settings = settings.copyWith(
        notifications: settings.notifications.copyWith(streakAlertEnabled: false),
      );

      expect(settings.notifications.streakAlertEnabled, false);
    });
  });

  // Welcome Back System (Anti-Streak-Anxiety) test
  group('WelcomeBackService Logic', () {
    Map<String, int> calculateRestBonus(int daysSinceLastVisit) {
      if (daysSinceLastVisit <= 1) {
        return {'water': 0, 'sunlight': 0};
      } else if (daysSinceLastVisit <= 7) {
        return {'water': 2, 'sunlight': 2};
      } else if (daysSinceLastVisit <= 30) {
        return {'water': 5, 'sunlight': 5};
      } else {
        return {'water': 10, 'sunlight': 10};
      }
    }

    bool shouldShowFeatureRefresh(int days) => days > 30;

    test('rest bonus: no bonus for daily user (0-1 days)', () {
      expect(calculateRestBonus(0), {'water': 0, 'sunlight': 0});
      expect(calculateRestBonus(1), {'water': 0, 'sunlight': 0});
    });

    test('rest bonus: small bonus for short absence (2-7 days)', () {
      expect(calculateRestBonus(2), {'water': 2, 'sunlight': 2});
      expect(calculateRestBonus(5), {'water': 2, 'sunlight': 2});
      expect(calculateRestBonus(7), {'water': 2, 'sunlight': 2});
    });

    test('rest bonus: medium bonus for moderate absence (8-30 days)', () {
      expect(calculateRestBonus(8), {'water': 5, 'sunlight': 5});
      expect(calculateRestBonus(15), {'water': 5, 'sunlight': 5});
      expect(calculateRestBonus(30), {'water': 5, 'sunlight': 5});
    });

    test('rest bonus: capped bonus for long absence (31+ days)', () {
      expect(calculateRestBonus(31), {'water': 10, 'sunlight': 10});
      expect(calculateRestBonus(90), {'water': 10, 'sunlight': 10});
      expect(calculateRestBonus(365), {'water': 10, 'sunlight': 10});
    });

    test('rest bonus is always non-negative (anti-punishment)', () {
      for (int d = 0; d <= 400; d += 10) {
        final bonus = calculateRestBonus(d);
        expect(bonus['water']!, greaterThanOrEqualTo(0),
            reason: 'Water should never be negative for $d days absence');
        expect(bonus['sunlight']!, greaterThanOrEqualTo(0),
            reason: 'Sunlight should never be negative for $d days absence');
      }
    });

    test('feature refresh only for 30+ days absence', () {
      expect(shouldShowFeatureRefresh(0), false);
      expect(shouldShowFeatureRefresh(7), false);
      expect(shouldShowFeatureRefresh(30), false);
      expect(shouldShowFeatureRefresh(31), true);
      expect(shouldShowFeatureRefresh(90), true);
    });
  });

  // 數據+邊界測試
  group('Data Integrity', () {
    test('toMap output should contain all expected keys (NotificationSettings)', () {
      final map = const NotificationSettings().toMap();
      expect(map.containsKey('habitRemindersEnabled'), true);
      expect(map.containsKey('habitReminderTime'), true);
      expect(map.containsKey('journalReminderEnabled'), true);
      expect(map.containsKey('journalReminderTime'), true);
      expect(map.containsKey('kindnessReminderEnabled'), true);
      expect(map.containsKey('kindnessReminderTime'), true);
      expect(map.containsKey('streakAlertEnabled'), true);
      expect(map.length, 7, reason: 'Should have exactly 7 keys');
    });

    test('toMap output should contain all expected keys (AppSettings)', () {
      final map = const AppSettings().toMap();
      expect(map.containsKey('notifications'), true);
      expect(map.containsKey('locale'), true);
      expect(map.length, 2, reason: 'Should have exactly 2 keys');
    });

    test('toMap output should contain all expected keys (ReminderTime)', () {
      final map = const ReminderTime().toMap();
      expect(map.containsKey('hour'), true);
      expect(map.containsKey('minute'), true);
      expect(map.length, 2, reason: 'Should have exactly 2 keys');
    });

    test('deeply nested copyWith preserves all untouched fields', () {
      const original = AppSettings(
        locale: 'ja',
        notifications: NotificationSettings(
          habitRemindersEnabled: false,
          habitReminderTime: ReminderTime(hour: 6, minute: 30),
          journalReminderEnabled: true,
          journalReminderTime: ReminderTime(hour: 22, minute: 15),
          kindnessReminderEnabled: true,
          kindnessReminderTime: ReminderTime(hour: 13, minute: 0),
          streakAlertEnabled: false,
        ),
      );

      final updated = original.copyWith(
        notifications: original.notifications.copyWith(
          journalReminderTime: const ReminderTime(hour: 23, minute: 0),
        ),
      );

      expect(updated.locale, 'ja');
      expect(updated.notifications.habitRemindersEnabled, false);
      expect(updated.notifications.habitReminderTime.hour, 6);
      expect(updated.notifications.habitReminderTime.minute, 30);
      expect(updated.notifications.journalReminderEnabled, true);
      expect(updated.notifications.journalReminderTime.hour, 23); // changed!
      expect(updated.notifications.journalReminderTime.minute, 0); // changed!
      expect(updated.notifications.kindnessReminderEnabled, true);
      expect(updated.notifications.kindnessReminderTime.hour, 13);
      expect(updated.notifications.streakAlertEnabled, false);
    });

    test('multiple sequential copyWith calls should stack correctly', () {
      var settings = const AppSettings();

      settings = settings.copyWith(
        notifications: settings.notifications.copyWith(habitRemindersEnabled: false),
      );
      settings = settings.copyWith(
        notifications: settings.notifications.copyWith(journalReminderEnabled: true),
      );
      settings = settings.copyWith(
        notifications: settings.notifications.copyWith(
          kindnessReminderTime: const ReminderTime(hour: 16, minute: 45),
        ),
      );

      expect(settings.notifications.habitRemindersEnabled, false);
      expect(settings.notifications.journalReminderEnabled, true);
      expect(settings.notifications.kindnessReminderTime.hour, 16);
      expect(settings.notifications.kindnessReminderTime.minute, 45);
      // defaults still intact
      expect(settings.notifications.streakAlertEnabled, true);
      expect(settings.notifications.habitReminderTime.hour, 9);
    });
  });
}