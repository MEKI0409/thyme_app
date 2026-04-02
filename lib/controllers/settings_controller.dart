// controllers/settings_controller.dart

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

  Timer? _saveDebouncer;

  bool _hasPendingChanges = false;

  bool _disposed = false;

  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }


  Future<void> loadSettings(String userId) async {
    // 同一用户已成功加载 → 跳过
    if (_userId == userId) return;

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

      _userId = userId;
      _errorMessage = null;
    } catch (e) {
      debugPrint('❌ Error loading settings: $e');
      _errorMessage = 'Failed to load settings';
      _settings = const AppSettings();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> reloadSettings() async {
    if (_userId == null) return;
    final uid = _userId!;
    _userId = null; // 清除缓存标记，允许重新加载
    await loadSettings(uid);
  }

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

  void _debouncedSave() {
    _hasPendingChanges = true; // ✅ 标记有待保存变更
    _saveDebouncer?.cancel();
    _saveDebouncer = Timer(const Duration(milliseconds: 800), () {
      _saveSettings();
    });
  }

  Future<void> flushPendingChanges() async {
    if (_hasPendingChanges) {
      _saveDebouncer?.cancel();
      await _saveSettings();
    }
  }

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

  void setHabitRemindersEnabled(bool enabled) {
    _settings = _settings.copyWith(
      notifications: _settings.notifications.copyWith(
        habitRemindersEnabled: enabled,
      ),
    );
    notifyListeners();
    _debouncedSave();
  }

  Future<bool> setHabitReminderTime(TimeOfDay time) async {
    _settings = _settings.copyWith(
      notifications: _settings.notifications.copyWith(
        habitReminderTime:
        _settings.notifications.habitReminderTime.withTimeOfDay(time),
        habitRemindersEnabled: true, // 选完时间自动开启
      ),
    );
    notifyListeners();
    return await _saveSettings();
  }

  void setJournalReminderEnabled(bool enabled) {
    _settings = _settings.copyWith(
      notifications: _settings.notifications.copyWith(
        journalReminderEnabled: enabled,
      ),
    );
    notifyListeners();
    _debouncedSave();
  }


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

  void setKindnessReminderEnabled(bool enabled) {
    _settings = _settings.copyWith(
      notifications: _settings.notifications.copyWith(
        kindnessReminderEnabled: enabled,
      ),
    );
    notifyListeners();
    _debouncedSave();
  }

  /// 提醒時間
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
      await user.delete();
      try {
        await _firebaseService.deleteUserData(uid);
      } catch (e) {
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
    _hasPendingChanges = false;
    _settings = const AppSettings();
    _isLoading = false;
    _errorMessage = null;
    _successMessage = null;
    _userId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    if (_hasPendingChanges) {
      _saveDebouncer?.cancel();
      _saveSettings();
    } else {
      _saveDebouncer?.cancel();
    }
    super.dispose();
  }
}