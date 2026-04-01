// controllers/auth_controller.dart
// ✅ FIXED: 修复异常类型，添加密码重置、邮箱验证功能

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../services/firebase_service.dart';
import '../models/user_model.dart';

class AuthController extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  User? _currentUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  // ✅ 保存订阅以便取消
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription? _userDocSubscription;

  User? get currentUser => _currentUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // ✅ 检查邮箱是否已验证
  bool get isEmailVerified => _currentUser?.emailVerified ?? false;

  AuthController() {
    _initAuthListener();
  }

  void _initAuthListener() {
    _authSubscription = _firebaseService.authStateChanges.listen((User? user) {
      _currentUser = user;
      if (user != null) {
        _loadUserModel(user.uid);
      } else {
        _userModel = null;
        _userDocSubscription?.cancel();
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserModel(String uid) async {
    // ✅ 取消之前的订阅
    _userDocSubscription?.cancel();

    _userDocSubscription = _firebaseService.getUserDocument(uid).listen(
          (snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          _userModel = UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
          notifyListeners();
        }
      },
      onError: (error) {
        debugPrint('Error loading user model: $error');
      },
    );
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firebaseService.signInWithEmail(email, password);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      // ✅ FIXED: FirebaseAuthException 是正确的类型
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred. Please try again.';
      debugPrint('Sign in error: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String displayName) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userCredential = await _firebaseService.signUpWithEmail(email, password);

      if (userCredential.user == null) {
        throw Exception('User creation failed');
      }

      final userModel = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      await _firebaseService.createUserDocument(
        userCredential.user!.uid,
        userModel.toMap(),
      );

      // ✅ FIXED: 直接使用 userCredential.user 发送验证邮件，避免依赖异步 auth listener
      try {
        if (userCredential.user != null && !userCredential.user!.emailVerified) {
          await userCredential.user!.sendEmailVerification();
        }
      } catch (e) {
        debugPrint('Email verification send failed (non-fatal): $e');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred. Please try again.';
      debugPrint('Sign up error: $e');
      notifyListeners();
      return false;
    }
  }

  /// ✅ 发送密码重置邮件
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firebaseService.sendPasswordResetEmail(email);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to send reset email. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// ✅ 发送邮箱验证
  Future<bool> sendEmailVerification() async {
    try {
      if (_currentUser != null && !_currentUser!.emailVerified) {
        await _currentUser!.sendEmailVerification();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Email verification error: $e');
      return false;
    }
  }

  /// ✅ 重新加载用户以检查邮箱验证状态
  Future<void> reloadUser() async {
    try {
      await _currentUser?.reload();
      _currentUser = FirebaseAuth.instance.currentUser;
      notifyListeners();
    } catch (e) {
      debugPrint('Reload user error: $e');
    }
  }

  /// ✅ 更新显示名称
  Future<bool> updateDisplayName(String displayName) async {
    try {
      if (_currentUser == null) return false;

      await _currentUser!.updateDisplayName(displayName);

      // 同时更新 Firestore
      await _firebaseService.updateUserDocument(
        _currentUser!.uid,
        {'displayName': displayName},
      );

      await reloadUser();
      return true;
    } catch (e) {
      debugPrint('Update display name error: $e');
      return false;
    }
  }

  /// ✅ 更新密码
  Future<bool> updatePassword(String currentPassword, String newPassword) async {
    try {
      if (_currentUser == null || _currentUser!.email == null) return false;

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // 重新认证用户
      final credential = EmailAuthProvider.credential(
        email: _currentUser!.email!,
        password: currentPassword,
      );
      await _currentUser!.reauthenticateWithCredential(credential);

      // 更新密码
      await _currentUser!.updatePassword(newPassword);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update password. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _userDocSubscription?.cancel(); // ✅ FIXED: 先取消订阅再登出
    await _firebaseService.signOut();
    _currentUser = null;
    _userModel = null;
    _errorMessage = null; // ✅ FIXED: 清除残留错误信息
    notifyListeners();
  }

  /// ✅ 删除账户
  Future<bool> deleteAccount(String password) async {
    try {
      if (_currentUser == null || _currentUser!.email == null) return false;

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // 重新认证用户
      final credential = EmailAuthProvider.credential(
        email: _currentUser!.email!,
        password: password,
      );
      await _currentUser!.reauthenticateWithCredential(credential);

      // ✅ FIXED: 保存 uid，先删账户再清理数据
      // 如果账户删除失败，用户数据保持完整可重试
      // 如果数据清理失败，仅留下孤儿数据（可由后端清理）
      final uid = _currentUser!.uid;

      // 先删除用户账户（不可逆操作）
      await _currentUser!.delete();

      // 再清理 Firestore 数据（best effort）
      try {
        await _firebaseService.deleteUserData(uid);
      } catch (e) {
        debugPrint('⚠️ Firestore cleanup failed (account already deleted): $e');
      }

      _currentUser = null;
      _userModel = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete account. Please try again.';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  // ✅ 正确取消所有订阅
  @override
  void dispose() {
    _authSubscription?.cancel();
    _userDocSubscription?.cancel();
    super.dispose();
  }
}