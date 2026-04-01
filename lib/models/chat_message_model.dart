// models/chat_message_model.dart
// ✅ IMPROVED: Added id, status, copyWith, better structure
// ✅ FIXED (v2): _generateId 使用随机数避免 Web 平台碰撞

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

/// Message status enum
enum MessageStatus {
  sending,
  sent,
  failed,
  delivered,
}

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final MessageStatus status;
  final String? errorMessage; // ✅ NEW: Store error if failed
  final Map<String, dynamic>? metadata; // ✅ NEW: Additional data

  ChatMessage({
    String? id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.errorMessage,
    this.metadata,
  }) : id = id ?? _generateId();

  /// ✅ FIXED (v2): 使用 milliseconds + 随机数生成唯一 ID
  /// 原实现在 Web 平台 microsecondsSinceEpoch 精度不足会碰撞
  static final _random = Random();
  static String _generateId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final rand = _random.nextInt(999999).toString().padLeft(6, '0');
    return '${now}_$rand';
  }

  /// ✅ FIXED: Safe parsing from Firestore
  factory ChatMessage.fromMap(Map<String, dynamic> map, [String? docId]) {
    return ChatMessage(
      id: docId ?? map['id'] ?? _generateId(),
      text: map['text'] ?? '',
      isUser: map['isUser'] ?? false,
      timestamp: _parseDateTime(map['timestamp']),
      status: _parseStatus(map['status']),
      errorMessage: map['errorMessage'],
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
    );
  }

  /// ✅ NEW: Safe DateTime parsing
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

  /// ✅ NEW: Parse status from string
  static MessageStatus _parseStatus(dynamic value) {
    if (value == null) return MessageStatus.sent;
    if (value is MessageStatus) return value;
    if (value is String) {
      switch (value) {
        case 'sending':
          return MessageStatus.sending;
        case 'sent':
          return MessageStatus.sent;
        case 'failed':
          return MessageStatus.failed;
        case 'delivered':
          return MessageStatus.delivered;
        default:
          return MessageStatus.sent;
      }
    }
    return MessageStatus.sent;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'errorMessage': errorMessage,
      'metadata': metadata,
    };
  }

  /// ✅ NEW: copyWith method
  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    MessageStatus? status,
    String? errorMessage,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      metadata: metadata ?? this.metadata,
    );
  }

  /// ✅ NEW: Create a user message
  factory ChatMessage.user(String text) {
    return ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );
  }

  /// ✅ NEW: Create an AI message
  factory ChatMessage.ai(String text) {
    return ChatMessage(
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );
  }

  /// ✅ NEW: Create a sending message (for optimistic UI)
  factory ChatMessage.sending(String text) {
    return ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );
  }

  /// ✅ NEW: Create a failed message
  factory ChatMessage.failed(String text, String error) {
    return ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      status: MessageStatus.failed,
      errorMessage: error,
    );
  }

  /// ✅ NEW: Check if message is sending
  bool get isSending => status == MessageStatus.sending;

  /// ✅ NEW: Check if message failed
  bool get isFailed => status == MessageStatus.failed;

  /// ✅ NEW: Get formatted timestamp
  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChatMessage(id: $id, isUser: $isUser, status: $status)';
  }
}