// models/kindness_chain_model.dart
// 善意链数据模型 🌸
// ✅ FIXED: 添加安全的 Timestamp 解析，与其他 model 保持一致

import 'package:cloud_firestore/cloud_firestore.dart';

/// 善意行为模型
class KindnessAct {
  final String id;
  final String userId;
  final String description;
  final String category;
  final DateTime createdAt;
  final bool isPublic;
  final int rippleCount;

  KindnessAct({
    required this.id,
    required this.userId,
    required this.description,
    required this.category,
    required this.createdAt,
    this.isPublic = false,
    this.rippleCount = 0,
  });

  factory KindnessAct.fromMap(Map<String, dynamic> map, String docId) {
    return KindnessAct(
      id: docId,
      userId: map['userId'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'other',
      createdAt: _parseDateTime(map['createdAt']),
      isPublic: map['isPublic'] ?? false,
      rippleCount: map['rippleCount'] ?? 0,
    );
  }

  /// ✅ FIXED: 安全的 DateTime 解析，处理 Timestamp / String / DateTime
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    if (value is DateTime) return value;
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'description': description,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'isPublic': isPublic,
      'rippleCount': rippleCount,
    };
  }

  KindnessAct copyWith({
    String? id,
    String? userId,
    String? description,
    String? category,
    DateTime? createdAt,
    bool? isPublic,
    int? rippleCount,
  }) {
    return KindnessAct(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isPublic: isPublic ?? this.isPublic,
      rippleCount: rippleCount ?? this.rippleCount,
    );
  }

  /// ✅ NEW: Equality and hashCode
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KindnessAct && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'KindnessAct(id: $id, category: $category, ripples: $rippleCount)';
  }
}

/// 善意类别定义
class KindnessCategory {
  /// 所有善意类别及其显示文字
  static const Map<String, String> categories = {
    'self': '💚 Self',
    'family': '👨‍👩‍👧 Family',
    'friends': '👥 Friends',
    'stranger': '🌍 Stranger',
    'nature': '🌿 Nature',
    'community': '🏘️ Community',
    'other': '✨ Other',
  };

  /// 获取类别的 emoji
  static String getEmoji(String category) {
    switch (category) {
      case 'self':
        return '💚';
      case 'family':
        return '👨‍👩‍👧';
      case 'friends':
        return '👥';
      case 'stranger':
        return '🌍';
      case 'nature':
        return '🌿';
      case 'community':
        return '🏘️';
      case 'other':
      default:
        return '✨';
    }
  }

  /// 获取类别的显示标签
  static String getLabel(String category) {
    switch (category) {
      case 'self':
        return 'Self-care';
      case 'family':
        return 'Family';
      case 'friends':
        return 'Friends';
      case 'stranger':
        return 'Stranger';
      case 'nature':
        return 'Nature';
      case 'community':
        return 'Community';
      case 'other':
      default:
        return 'Other';
    }
  }

  /// 获取类别的温柔描述
  static String getDescription(String category) {
    switch (category) {
      case 'self':
        return 'Being kind to yourself 💚';
      case 'family':
        return 'Warmth for family 🏠';
      case 'friends':
        return 'Caring for friends 👥';
      case 'stranger':
        return 'Kindness to strangers 🌍';
      case 'nature':
        return 'Caring for nature 🌿';
      case 'community':
        return 'Building community 🏘️';
      case 'other':
      default:
        return 'Every kindness matters ✨';
    }
  }

  /// 获取类别对应的花园奖励类型
  static String getRewardType(String category) {
    switch (category) {
      case 'self':
        return 'water'; // 自我关怀 → 水滴（滋养）
      case 'nature':
        return 'water'; // 自然 → 水滴
      case 'stranger':
        return 'sunlight'; // 陌生人 → 阳光（温暖传播最远）
      case 'family':
        return 'sunlight'; // 家庭 → 阳光（温暖）
      case 'community':
        return 'sunlight'; // 社区 → 阳光
      default:
        return 'both'; // 其他 → 平衡
    }
  }
}