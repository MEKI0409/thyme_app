// models/user_model.dart
// ✅ IMPROVED: Safe timestamp parsing, copyWith, additional fields

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final DateTime createdAt;
  final String? photoUrl;
  final Map<String, dynamic>? settings;
  final DateTime? lastActiveAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
    this.photoUrl,
    this.settings,
    this.lastActiveAt,
  });

  /// ✅ FIXED: Safe parsing of timestamps from Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      createdAt: _parseDateTime(map['createdAt']),
      photoUrl: map['photoUrl'],
      settings: map['settings'] != null
          ? Map<String, dynamic>.from(map['settings'])
          : null,
      lastActiveAt: map['lastActiveAt'] != null
          ? _parseDateTime(map['lastActiveAt'])
          : null,
    );
  }

  /// ✅ NEW: Safe DateTime parsing that handles multiple formats
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
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt.toIso8601String(),
      'photoUrl': photoUrl,
      'settings': settings,
      'lastActiveAt': lastActiveAt?.toIso8601String(),
    };
  }

  /// ✅ NEW: copyWith method for immutable updates
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    DateTime? createdAt,
    String? photoUrl,
    Map<String, dynamic>? settings,
    DateTime? lastActiveAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      photoUrl: photoUrl ?? this.photoUrl,
      settings: settings ?? this.settings,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName)';
  }
}