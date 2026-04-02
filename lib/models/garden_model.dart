// models/garden_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

class GardenState {
  final String userId;
  final int plantLevel;
  final int waterDrops;
  final int sunlightPoints;
  final DateTime lastVisited;
  final String gardenStatus;
  final List<String> unlockedColors;
  final List<String> achievements;
  final String? selectedColor;
  final DateTime? lastUpdated;

  static const int maxPlantLevel = 10;
  static const int baseWaterCost = 10;
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
      waterDrops: 5,
      sunlightPoints: 5,
      lastVisited: DateTime.now(),
      gardenStatus: 'active',
      unlockedColors: ['#4DB6AC'],
      achievements: [],
      selectedColor: '#4DB6AC',
      lastUpdated: DateTime.now(),
    );
  }

  factory GardenState.fromMap(Map<String, dynamic> map) {
    return GardenState(
      userId: map['userId'] ?? '',
      plantLevel: (map['plantLevel'] ?? 0).clamp(0, maxPlantLevel),
      waterDrops: (map['waterDrops'] ?? 0).clamp(0, 999999),
      sunlightPoints: (map['sunlightPoints'] ?? 0).clamp(0, 999999),
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

  int getWaterNeededForNextLevel() {
    if (plantLevel >= maxPlantLevel) return 0;
    return baseWaterCost * (plantLevel + 1);
  }

  int getSunlightNeededForNextLevel() {
    if (plantLevel >= maxPlantLevel) return 0;
    return baseSunlightCost * (plantLevel + 1);
  }

  bool hasEnoughResourcesToGrow() {
    return waterDrops >= getWaterNeededForNextLevel() &&
        sunlightPoints >= getSunlightNeededForNextLevel();
  }

  bool canGrow() {
    return plantLevel < maxPlantLevel && hasEnoughResourcesToGrow();
  }

  bool get isMaxLevel => plantLevel >= maxPlantLevel;

  bool canUnlockColor(int cost) {
    return sunlightPoints >= cost;
  }

  double get growthProgress {
    if (plantLevel >= maxPlantLevel) return 1.0;

    final waterNeeded = getWaterNeededForNextLevel();
    final sunlightNeeded = getSunlightNeededForNextLevel();

    if (waterNeeded == 0 || sunlightNeeded == 0) return 1.0;

    final waterProgress = (waterDrops / waterNeeded).clamp(0.0, 1.0);
    final sunlightProgress = (sunlightPoints / sunlightNeeded).clamp(0.0, 1.0);

    return (waterProgress + sunlightProgress) / 2;
  }

  int get daysSinceLastVisit {
    return DateTime.now().difference(lastVisited).inDays;
  }

  bool get isResting {
    return gardenStatus == 'resting' || daysSinceLastVisit > 7;
  }

  String get plantEmoji {
    if (plantLevel <= 0) return '🌱';
    if (plantLevel <= 2) return '🌿';
    if (plantLevel <= 4) return '🌸';
    if (plantLevel <= 6) return '🌺';
    if (plantLevel <= 8) return '🌻';
    return '🌳';
  }

  String get plantStageName {
    return Constants.getPlantStageName(plantLevel);
  }

  String get plantDescription {
    return Constants.getGrowthMessage(plantLevel);
  }


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

  GardenState addResources({int water = 0, int sunlight = 0}) {
    return copyWith(
      waterDrops: waterDrops + water,
      sunlightPoints: sunlightPoints + sunlight,
      lastUpdated: DateTime.now(),
    );
  }

  GardenState consumeResources({int water = 0, int sunlight = 0}) {
    return copyWith(
      waterDrops: (waterDrops - water).clamp(0, 999999),
      sunlightPoints: (sunlightPoints - sunlight).clamp(0, 999999),
      lastUpdated: DateTime.now(),
    );
  }

  GardenState markVisited() {
    return copyWith(
      lastVisited: DateTime.now(),
      gardenStatus: 'active',
      lastUpdated: DateTime.now(),
    );
  }

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