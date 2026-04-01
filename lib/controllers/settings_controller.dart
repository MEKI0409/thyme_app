// controllers/settings_controller.dart
// 设置控制器 ⚙️
// ✅ 管理个人资料、通知、隐私安全相关操作
// ✅ FIXED: 移除 ReminderTime.copyWith(isEnabled) 调用（字段已删除）
// ✅ FIXED: 通知开关防抖，避免连续 Firestore 写入
// ✅ FIXED: loadSettings 重复调用去重保护
// ✅ IMPROVED: 统一错误处理，_isLoading 状态更一致
// ✅ FIXED (v2): loadSettings 首次失败后可重试（_userId 延迟赋值）
// ✅ FIXED (v2): dispose 时立即 flush 待保存数据，防止丢失

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../models/settings_model.dart';
import '../services/firebase_service.dart';

class SettingsController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseService _firebaseService = FirebaseService();

  AppSettings _settings = const AppSettings();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  String? _userId;

  // ✅ NEW: 防抖 Timer，避免开关快速切换时连续写入 Firestore
  Timer? _saveDebouncer;

  // ✅ FIXED (v2): 追踪是否有待保存的变更
  bool _hasPendingChanges = false;

  // ✅ FIXED (v3): 防止 dispose 后调用 notifyListeners 崩溃
  bool _disposed = false;

  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// ✅ FIXED (v3): 安全的 notifyListeners，dispose 后不再调用
  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 初始化 & 加载
  // ═══════════════════════════════════════════════════════════════════════════

  /// 从 Firestore 加载用户设置
  /// ✅ FIXED (v2): _userId 在成功后才赋值，失败时可重试
  Future<void> loadSettings(String userId) async {
    // 同一用户已成功加载 → 跳过
    if (_userId == userId) return;

    // ✅ FIXED: 正在加载中 → 跳过（防止并发）
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _settings = AppSettings.fromMap(
          data['settings'] as Map<String, dynamic>?,
        );
      } else {
        _settings = const AppSettings();
      }

      // ✅ FIXED (v2): 只在成功后赋值，失败时 _userId 仍为 null，允许重试
      _userId = userId;
      _errorMessage = null;
    } catch (e) {
      debugPrint('❌ Error loading settings: $e');
      _errorMessage = 'Failed to load settings';
      _settings = const AppSettings();
      // ✅ FIXED (v2): 不赋值 _userId，下次调用可重试
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 强制重新加载（用于刷新场景）
  Future<void> reloadSettings() async {
    if (_userId == null) return;
    final uid = _userId!;
    _userId = null; // 清除缓存标记，允许重新加载
    await loadSettings(uid);
  }

  /// 保存设置到 Firestore
  /// ✅ FIXED (v3): 使用 _safeNotify 防止 dispose 后崩溃
  Future<bool> _saveSettings() async {
    final uid = _userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _errorMessage = 'Not signed in';
      _safeNotify();
      return false;
    }

    try {
      await _firestore.collection('users').doc(uid).set(
        {'settings': _settings.toMap()},
        SetOptions(merge: true),
      );
      _hasPendingChanges = false;
      return true;
    } catch (e) {
      debugPrint('❌ Error saving settings: $e');
      _errorMessage = 'Failed to save settings. Please try again.';
      _safeNotify();
      return false;
    }
  }

  /// ✅ FIXED (v2): 防抖保存 - 连续调用时只执行最后一次（延迟 800ms）
  /// 用于开关切换，避免快速点击产生多次 Firestore 写入
  void _debouncedSave() {
    _hasPendingChanges = true; // ✅ 标记有待保存变更
    _saveDebouncer?.cancel();
    _saveDebouncer = Timer(const Duration(milliseconds: 800), () {
      _saveSettings();
    });
  }

  /// ✅ FIXED (v2): 立即 flush 待保存数据（用于 dispose 或页面退出前）
  Future<void> flushPendingChanges() async {
    if (_hasPendingChanges) {
      _saveDebouncer?.cancel();
      await _saveSettings();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 个人资料
  // ═══════════════════════════════════════════════════════════════════════════

  /// 更新显示名称
  Future<bool> updateDisplayName(String newName) async {
    final trimmed = newName.trim();

    if (trimmed.isEmpty) {
      _errorMessage = 'Display name cannot be empty';
      notifyListeners();
      return false;
    }

    if (trimmed.length > 30) {
      _errorMessage = 'Display name is too long (max 30 characters)';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _errorMessage = 'Not signed in';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final uid = _userId ?? user.uid;

      await user.updateDisplayName(trimmed);
      await user.reload();

      await _firestore.collection('users').doc(uid).set(
        {'displayName': trimmed},
        SetOptions(merge: true),
      );

      _userId ??= uid;
      _successMessage = 'Display name updated~ ✨';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Failed to update display name: $e');
      _isLoading = false;
      _errorMessage = 'Failed to update display name';
      notifyListeners();
      return false;
    }
  }

  /// 更新头像 URL
  Future<bool> updatePhotoUrl(String? photoUrl) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _errorMessage = 'Not signed in';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final uid = _userId ?? user.uid;

      await user.updatePhotoURL(photoUrl);
      await user.reload();

      await _firestore.collection('users').doc(uid).set(
        {'photoUrl': photoUrl},
        SetOptions(merge: true),
      );

      _userId ??= uid;
      _successMessage = 'Profile photo updated~ 📸';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Failed to update photo URL: $e');
      _isLoading = false;
      _errorMessage = 'Failed to update profile photo';
      notifyListeners();
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 通知设置
  // ✅ 开关类操作使用防抖保存；时间选择立即保存（用户主动操作）
  // ═══════════════════════════════════════════════════════════════════════════

  /// 习惯提醒开关
  void setHabitRemindersEnabled(bool enabled) {
    _settings = _settings.copyWith(
      notifications: _settings.notifications.copyWith(
        habitRemindersEnabled: enabled,
      ),
    );
    notifyListeners();
    _debouncedSave(); // ✅ 防抖：快速切换时只保存最后状态
  }

  /// 习惯提醒时间
  /// ✅ FIXED: 移除 .copyWith(isEnabled: true)（字段已从 ReminderTime 删除）
  Future<bool> setHabitReminderTime(TimeOfDay time) async {
    _settings = _settings.copyWith(
      notifications: _settings.notifications.copyWith(
        habitReminderTime:
        _settings.notifications.habitReminderTime.withTimeOfDay(time),
        habitRemindersEnabled: true, // 选完时间自动开启
      ),
    );
    notifyListeners();
    return await _saveSettings(); // 时间选择立即保存
  }

  /// 日记提醒开关
  void setJournalReminderEnabled(bool enabled) {
    _settings = _settings.copyWith(
      notifications: _settings.notifications.copyWith(
        journalReminderEnabled: enabled,
      ),
    );
    notifyListeners();
    _debouncedSave();
  }

  /// 日记提醒时间
  /// ✅ FIXED: 移除 .copyWith(isEnabled: true)
  Future<bool> setJournalReminderTime(TimeOfDay time) async {
    _settings = _settings.copyWith(
      notifications: _settings.notifications.copyWith(
        journalReminderTime:
        _settings.notifications.journalReminderTime.withTimeOfDay(time),
        journalReminderEnabled: true,
      ),
    );
    notifyListeners();
    return await _saveSettings();
  }

  /// 善意提醒开关
  void setKindnessReminderEnabled(bool enabled) {
    _settings = _settings.copyWith(
      notifications: _settings.notifications.copyWith(
        kindnessReminderEnabled: enabled,
      ),
    );
    notifyListeners();
    _debouncedSave();
  }

  /// 善意提醒时间
  /// ✅ FIXED: 移除 .copyWith(isEnabled: true)
  Future<bool> setKindnessReminderTime(TimeOfDay time) async {
    _settings = _settings.copyWith(
      notifications: _settings.notifications.copyWith(
        kindnessReminderTime:
        _settings.notifications.kindnessReminderTime.withTimeOfDay(time),
        kindnessReminderEnabled: true,
      ),
    );
    notifyListeners();
    return await _saveSettings();
  }

  /// 连续打卡提醒开关
  void setStreakAlertEnabled(bool enabled) {
    _settings = _settings.copyWith(
      notifications: _settings.notifications.copyWith(
        streakAlertEnabled: enabled,
      ),
    );
    notifyListeners();
    _debouncedSave();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 隐私安全
  // ═══════════════════════════════════════════════════════════════════════════

  /// 修改密码
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (newPassword.length < 6) {
      _errorMessage = 'New password must be at least 6 characters';
      notifyListeners();
      return false;
    }

    if (currentPassword == newPassword) {
      _errorMessage = 'New password must be different from current password';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        _errorMessage = 'Not signed in';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      _successMessage = 'Password updated successfully~ 🔒';
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getAuthErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to change password. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// 发送邮箱验证
  Future<bool> sendEmailVerification() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _errorMessage = 'Not signed in';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (user.emailVerified) {
        _successMessage = 'Email is already verified~ ✅';
        _isLoading = false;
        notifyListeners();
        return true;
      }

      await user.sendEmailVerification();

      _successMessage = 'Verification email sent! Check your inbox~ 📧';
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.code == 'too-many-requests'
          ? 'Too many requests. Please wait a moment.'
          : 'Failed to send verification email';
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to send verification email';
      notifyListeners();
      return false;
    }
  }

  /// 检查邮箱验证状态（刷新）
  Future<bool> checkEmailVerified() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      await user.reload();
      return FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    } catch (e) {
      debugPrint('❌ Error checking email verification: $e');
      return false;
    }
  }

  /// 删除账户
  /// ✅ 顺序：先重新认证 → 删除 Auth → best-effort 清理 Firestore
  Future<bool> deleteAccount(String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        _errorMessage = 'Not signed in';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      final uid = user.uid;

      // 先删除 Auth 账户
      await user.delete();

      // 再清理 Firestore 数据（best effort）
      try {
        await _firebaseService.deleteUserData(uid);
      } catch (e) {
        // ✅ 记录清理失败，不影响主流程
        // 可考虑写入 'pending_cleanup' 集合供后台处理
        debugPrint('⚠️ Firestore cleanup failed for uid $uid: $e');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getAuthErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete account. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 辅助方法
  // ═══════════════════════════════════════════════════════════════════════════

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'wrong-password':
        return 'Incorrect current password';
      case 'invalid-credential':
        return 'Invalid credentials. Please try again.';
      case 'weak-password':
        return 'New password is too weak (min 6 characters)';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void reset() {
    _saveDebouncer?.cancel();
    _hasPendingChanges = false; // ✅ FIXED (v2): 重置待保存标志
    _settings = const AppSettings();
    _isLoading = false;
    _errorMessage = null;
    _successMessage = null;
    _userId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // ✅ FIXED (v3): 先标记 disposed，防止 fire-and-forget 的 _saveSettings 中
    // 调用 notifyListeners 导致 "used after being disposed" 崩溃
    _disposed = true;
    if (_hasPendingChanges) {
      _saveDebouncer?.cancel();
      _saveSettings(); // fire-and-forget: 尽力保存，_safeNotify 不会崩溃
    } else {
      _saveDebouncer?.cancel();
    }
    super.dispose();
  }
}