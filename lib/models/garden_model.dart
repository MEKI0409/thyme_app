// models/garden_model.dart
// ✅ FIXED: 统一 maxPlantLevel = 10，与 Constants 保持一致
// ✅ 添加与 Constants.getGrowthCost 同步的资源计算

import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

class GardenState {
  final String userId;
  final int plantLevel;
  final int waterDrops;
  final int sunlightPoints;
  final DateTime lastVisited;
  final String gardenStatus; // 'active' or 'resting' - NEVER 'withered'
  final List<String> unlockedColors;
  final List<String> achievements;
  final String? selectedColor;
  final DateTime? lastUpdated;

  // ═══════════════════════════════════════════════════════════════════════════
  // ✅ 统一常量 - 与 Constants.maxPlantLevel 保持同步
  // ═══════════════════════════════════════════════════════════════════════════

  /// 最大植物等级 = 10
  /// 等级 0-10 共 11 个阶段
  /// 对应图标: Seedling(1-2), Leaves(3-4), Flower(5-6), BigFlower(7-8), Sunflower(9), Tree(10)
  static const int maxPlantLevel = 10;

  /// 基础水资源消耗（每级 = baseWaterCost * level）
  static const int baseWaterCost = 10;

  /// 基础阳光消耗（每级 = baseSunlightCost * level）
  static const int baseSunlightCost = 5;

  GardenState({
    required this.userId,
    required this.plantLevel,
    required this.waterDrops,
    required this.sunlightPoints,
    required this.lastVisited,
    required this.gardenStatus,
    required this.unlockedColors,
    required this.achievements,
    this.selectedColor,
    this.lastUpdated,
  });

  factory GardenState.initial(String userId) {
    return GardenState(
      userId: userId,
      plantLevel: 0,
      waterDrops: 5, // 初始资源
      sunlightPoints: 5,
      lastVisited: DateTime.now(),
      gardenStatus: 'active',
      unlockedColors: ['#4DB6AC'], // 默认颜色
      achievements: [],
      selectedColor: '#4DB6AC',
      lastUpdated: DateTime.now(),
    );
  }

  factory GardenState.fromMap(Map<String, dynamic> map) {
    return GardenState(
      userId: map['userId'] ?? '',
      plantLevel: (map['plantLevel'] ?? 0).clamp(0, maxPlantLevel), // ✅ FIXED: 防止非法等级
      waterDrops: (map['waterDrops'] ?? 0).clamp(0, 999999), // ✅ FIXED: 防止负数
      sunlightPoints: (map['sunlightPoints'] ?? 0).clamp(0, 999999), // ✅ FIXED: 防止负数
      lastVisited: _parseDateTime(map['lastVisited']),
      gardenStatus: map['gardenStatus'] ?? 'active',
      unlockedColors: map['unlockedColors'] != null
          ? List<String>.from(map['unlockedColors'])
          : ['#4DB6AC'],
      achievements: map['achievements'] != null
          ? List<String>.from(map['achievements'])
          : [],
      selectedColor: map['selectedColor'],
      lastUpdated: map['lastUpdated'] != null
          ? _parseDateTime(map['lastUpdated'])
          : null,
    );
  }

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
      'plantLevel': plantLevel,
      'waterDrops': waterDrops,
      'sunlightPoints': sunlightPoints,
      'lastVisited': lastVisited.toIso8601String(),
      'gardenStatus': gardenStatus,
      'unlockedColors': unlockedColors,
      'achievements': achievements,
      'selectedColor': selectedColor,
      'lastUpdated': (lastUpdated ?? DateTime.now()).toIso8601String(),
    };
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 资源计算 - ✅ 与 Constants.getGrowthCost 保持同步
  // ═══════════════════════════════════════════════════════════════════════════

  /// 下一级所需水资源
  /// 公式: baseWaterCost * (currentLevel + 1)
  /// 例: Level 0 → Level 1 需要 10 水
  ///     Level 5 → Level 6 需要 60 水
  int getWaterNeededForNextLevel() {
    if (plantLevel >= maxPlantLevel) return 0;
    return baseWaterCost * (plantLevel + 1);
  }

  /// 下一级所需阳光
  /// 公式: baseSunlightCost * (currentLevel + 1)
  int getSunlightNeededForNextLevel() {
    if (plantLevel >= maxPlantLevel) return 0;
    return baseSunlightCost * (plantLevel + 1);
  }

  /// 检查是否有足够资源升级
  bool hasEnoughResourcesToGrow() {
    return waterDrops >= getWaterNeededForNextLevel() &&
        sunlightPoints >= getSunlightNeededForNextLevel();
  }

  /// 是否可以升级（未达到最大等级且资源足够）
  bool canGrow() {
    return plantLevel < maxPlantLevel && hasEnoughResourcesToGrow();
  }

  /// 是否已达到最大等级
  bool get isMaxLevel => plantLevel >= maxPlantLevel;

  /// 检查是否可以解锁颜色
  bool canUnlockColor(int cost) {
    return sunlightPoints >= cost;
  }

  /// 获取升级进度 (0.0 - 1.0)
  double get growthProgress {
    if (plantLevel >= maxPlantLevel) return 1.0;

    final waterNeeded = getWaterNeededForNextLevel();
    final sunlightNeeded = getSunlightNeededForNextLevel();

    if (waterNeeded == 0 || sunlightNeeded == 0) return 1.0;

    final waterProgress = (waterDrops / waterNeeded).clamp(0.0, 1.0);
    final sunlightProgress = (sunlightPoints / sunlightNeeded).clamp(0.0, 1.0);

    return (waterProgress + sunlightProgress) / 2;
  }

  /// 距离上次访问的天数
  int get daysSinceLastVisit {
    return DateTime.now().difference(lastVisited).inDays;
  }

  /// 花园是否在休息（温柔的说法表示"不活跃"）
  bool get isResting {
    return gardenStatus == 'resting' || daysSinceLastVisit > 7;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 植物阶段 - ✅ 与图标系统对应
  // ═══════════════════════════════════════════════════════════════════════════

  /// 获取植物 emoji
  String get plantEmoji {
    if (plantLevel <= 0) return '🌱';
    if (plantLevel <= 2) return '🌿';
    if (plantLevel <= 4) return '🌸';
    if (plantLevel <= 6) return '🌺';
    if (plantLevel <= 8) return '🌻';
    return '🌳';
  }

  /// 获取植物阶段名称
  /// ✅ FIXED: 使用 Constants.getPlantStageName 统一名称
  String get plantStageName {
    return Constants.getPlantStageName(plantLevel);
  }

  /// 获取详细的植物描述
  /// ✅ FIXED: 使用 Constants.getGrowthMessage 统一描述
  String get plantDescription {
    return Constants.getGrowthMessage(plantLevel);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CopyWith 和辅助方法
  // ═══════════════════════════════════════════════════════════════════════════

  GardenState copyWith({
    String? userId,
    int? plantLevel,
    int? waterDrops,
    int? sunlightPoints,
    DateTime? lastVisited,
    String? gardenStatus,
    List<String>? unlockedColors,
    List<String>? achievements,
    String? selectedColor,
    DateTime? lastUpdated,
  }) {
    return GardenState(
      userId: userId ?? this.userId,
      plantLevel: plantLevel ?? this.plantLevel,
      waterDrops: waterDrops ?? this.waterDrops,
      sunlightPoints: sunlightPoints ?? this.sunlightPoints,
      lastVisited: lastVisited ?? this.lastVisited,
      gardenStatus: gardenStatus ?? this.gardenStatus,
      unlockedColors: unlockedColors ?? this.unlockedColors,
      achievements: achievements ?? this.achievements,
      selectedColor: selectedColor ?? this.selectedColor,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// 添加资源（完成习惯后）
  GardenState addResources({int water = 0, int sunlight = 0}) {
    return copyWith(
      waterDrops: waterDrops + water,
      sunlightPoints: sunlightPoints + sunlight,
      lastUpdated: DateTime.now(),
    );
  }

  /// 消耗资源（升级时）
  GardenState consumeResources({int water = 0, int sunlight = 0}) {
    return copyWith(
      waterDrops: (waterDrops - water).clamp(0, 999999),
      sunlightPoints: (sunlightPoints - sunlight).clamp(0, 999999),
      lastUpdated: DateTime.now(),
    );
  }

  /// 标记为已访问
  GardenState markVisited() {
    return copyWith(
      lastVisited: DateTime.now(),
      gardenStatus: 'active',
      lastUpdated: DateTime.now(),
    );
  }

  /// 升级植物（如果可以）
  GardenState? tryGrow() {
    if (!canGrow()) return null;

    return copyWith(
      plantLevel: plantLevel + 1,
      waterDrops: waterDrops - getWaterNeededForNextLevel(),
      sunlightPoints: sunlightPoints - getSunlightNeededForNextLevel(),
      lastUpdated: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'GardenState(level: $plantLevel/$maxPlantLevel, water: $waterDrops, sunlight: $sunlightPoints, stage: $plantStageName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GardenState &&
        other.userId == userId &&
        other.plantLevel == plantLevel &&
        other.waterDrops == waterDrops &&
        other.sunlightPoints == sunlightPoints;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
    plantLevel.hashCode ^
    waterDrops.hashCode ^
    sunlightPoints.hashCode;
  }
}