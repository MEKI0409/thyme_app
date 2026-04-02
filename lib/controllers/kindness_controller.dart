// controllers/kindness_controller.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/kindness_chain_model.dart';

class KindnessController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> Function(int sunlight, int water)? onRewardEarned;

  List<KindnessAct> _myKindnessActs = [];
  List<KindnessAct> _communityKindnessActs = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _myActsSubscription;
  StreamSubscription? _communitySubscription;

  int _totalKindnessCount = 0;
  int _weeklyKindnessCount = 0;
  int _currentStreak = 0;

  Map<String, dynamic>? _lastRewardInfo;

  int _previousStreak = 0;
  int? _newMilestone;
  static const List<int> _milestones = [3, 7, 14, 30];

  List<KindnessAct> get myKindnessActs => _myKindnessActs;
  List<KindnessAct> get communityKindnessActs => _communityKindnessActs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalKindnessCount => _totalKindnessCount;
  int get weeklyKindnessCount => _weeklyKindnessCount;
  int get currentStreak => _currentStreak;
  Map<String, dynamic>? get lastRewardInfo => _lastRewardInfo;

  int? consumeMilestone() {
    final m = _newMilestone;
    _newMilestone = null;
    return m;
  }

  void loadKindnessActs(String userId) {
    _isLoading = true;
    notifyListeners();

    // 加载个人善意行为
    _myActsSubscription?.cancel();
    _myActsSubscription = _firestore
        .collection('kindness')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .listen(
          (snapshot) {
        _myKindnessActs = snapshot.docs
            .map((doc) => KindnessAct.fromMap(doc.data(), doc.id))
            .toList();
        _calculateStats();
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load kindness acts: $error';
        _isLoading = false;
        notifyListeners();
      },
    );

    _communitySubscription?.cancel();
    _communitySubscription = _firestore
        .collection('kindness')
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots()
        .listen(
          (snapshot) {
        _communityKindnessActs = snapshot.docs
            .map((doc) => KindnessAct.fromMap(doc.data(), doc.id))
            .toList();
        notifyListeners();
      },
      onError: (error) {
        final errorStr = error.toString();
        if (errorStr.contains('failed-precondition') || errorStr.contains('requires an index')) {
          debugPrint('⚠️ Community kindness query requires a Firestore composite index.');
          debugPrint('   Please create it in Firebase Console:');
          debugPrint('   Collection: kindness | Fields: isPublic (Asc) + createdAt (Desc)');
          debugPrint('   Or click the link in the error message above.');
          _communityKindnessActs = [];
          notifyListeners();
        } else {
          debugPrint('Failed to load community kindness: $error');
        }
      },
    );
  }

  void _calculateStats() {
    _totalKindnessCount = _myKindnessActs.length;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    _weeklyKindnessCount = _myKindnessActs
        .where((act) => act.createdAt.isAfter(weekStart))
        .length;

    _previousStreak = _currentStreak;

    _currentStreak = _calculateStreak();

    for (final milestone in _milestones) {
      if (_currentStreak >= milestone && _previousStreak < milestone) {
        _newMilestone = milestone;
        break;
      }
    }
  }

  int _calculateStreak() {
    if (_myKindnessActs.isEmpty) return 0;

    final sortedDates = _myKindnessActs
        .map((act) => DateTime(
        act.createdAt.year, act.createdAt.month, act.createdAt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (sortedDates.isEmpty) return 0;

    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (!sortedDates.contains(today) && !sortedDates.contains(yesterday)) {
      return 0;
    }

    int streak = 1;
    for (int i = 0; i < sortedDates.length - 1; i++) {
      final diff = sortedDates[i].difference(sortedDates[i + 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  Future<bool> addKindnessAct({
    required String userId,
    required String description,
    required String category,
    bool isPublic = false,
  }) async {
    try {

      final now = DateTime.now();
      final actData = {
        'userId': userId,
        'description': description,
        'category': category,
        'createdAt': now.toIso8601String(),
        'isPublic': isPublic,
        'rippleCount': 0,
      };

      final optimisticAct = KindnessAct(
        id: 'temp_${now.millisecondsSinceEpoch}',
        userId: userId,
        description: description,
        category: category,
        createdAt: now,
        isPublic: isPublic,
        rippleCount: 0,
      );
      _myKindnessActs.insert(0, optimisticAct);
      _calculateStats();
      notifyListeners();

      await _firestore.collection('kindness').add(actData);
      _lastRewardInfo = _calculateKindnessRewards(category, isPublic);

      if (onRewardEarned != null) {
        try {
          await onRewardEarned!(
            _lastRewardInfo!['sunlight'] as int? ?? 2,
            _lastRewardInfo!['water'] as int? ?? 1,
          );
        } catch (e) {
          debugPrint('⚠️ Failed to apply kindness reward to garden: $e');
        }
      }

      return true;

    } catch (e) {
      _myKindnessActs.removeWhere((act) => act.id.startsWith('temp_'));
      _calculateStats();
      _errorMessage = 'Failed to add kindness act: $e';
      _lastRewardInfo = null;
      notifyListeners();
      return false;
    }
  }

  Map<String, dynamic> _calculateKindnessRewards(String category, bool isPublic) {
    int sunlight = 2;
    int water = 1;
    String message = '';
    String bonusType = 'normal';

    switch (category) {
      case 'self':
        water += 1;
        message = 'Self-love nurtures your garden~ 💚';
        bonusType = 'self_care';
        break;
      case 'family':
        sunlight += 1;
        message = 'Family warmth makes flowers bloom~ 🌸';
        bonusType = 'warmth';
        break;
      case 'friends':
        sunlight += 1;
        water += 1;
        message = 'Friendship grows both ways~ 💫';
        bonusType = 'friendship';
        break;
      case 'stranger':
        sunlight += 2;
        message = 'Your kindness ripples outward~ 🌊';
        bonusType = 'ripple';
        break;
      case 'nature':
        water += 2;
        message = 'Nature thanks you gently~ 🌿';
        bonusType = 'nature';
        break;
      case 'community':
        sunlight += 1;
        message = 'Community grows stronger~ 🏡';
        bonusType = 'community';
        break;
      default:
        message = 'Every kindness matters~ ✨';
    }

    if (isPublic) {
      sunlight += 1;
    }

    if (_currentStreak >= 7) {
      sunlight += 1;
      water += 1;
      bonusType = 'streak';
    }

    return {
      'sunlight': sunlight,
      'water': water,
      'message': message,
      'bonusType': bonusType,
    };
  }

  Map<String, int> getLastRewardValues() {
    if (_lastRewardInfo == null) {
      return {'sunlight': 2, 'water': 1};
    }
    return {
      'sunlight': _lastRewardInfo!['sunlight'] as int? ?? 2,
      'water': _lastRewardInfo!['water'] as int? ?? 1,
    };
  }

  Future<bool> rippleKindness(String kindnessId, {String? currentUserId}) async {
    try {
      if (currentUserId != null) {
        final doc = await _firestore.collection('kindness').doc(kindnessId).get();
        if (doc.exists && doc.data()?['userId'] == currentUserId) {
          debugPrint('⚠️ Cannot ripple your own kindness act');
          return false;
        }
      }

      await _firestore.collection('kindness').doc(kindnessId).update({
        'rippleCount': FieldValue.increment(1),
      });
      return true;
    } catch (e) {
      debugPrint('Failed to ripple kindness: $e');
      return false;
    }
  }

  Future<bool> deleteKindnessAct(String actId) async {
    try {
      await _firestore.collection('kindness').doc(actId).delete();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete kindness act: $e';
      notifyListeners();
      return false;
    }
  }

  String getDailyPrompt() {
    final prompts = [
      'What tiny kindness could brighten someone\'s day? 🌸',
      'Even a smile counts as kindness~ 💫',
      'Being gentle with yourself is kindness too 🌿',
      'Who might need a warm word today? 💌',
      'Small ripples create big waves~ 🌊',
      'Your presence is already a gift 🎁',
      'What made you smile? Pass it on~ 😊',
      'Kindness doesn\'t need to be big to matter 🦋',
      'How did someone show you kindness lately? 💝',
      'Nature appreciates your gentle steps 🍃',
    ];
    final index = (DateTime.now().day + DateTime.now().hour) % prompts.length;
    return prompts[index];
  }

  String getMoodAwarePrompt(String? currentMood) {
    switch (currentMood?.toLowerCase()) {
      case 'sad':
      case 'lonely':
        return 'Being kind to yourself counts too. '
            'What\'s one gentle thing you could do for yourself? 💚';
      case 'anxious':
      case 'stressed':
        return 'Kindness can be grounding. '
            'Even a small act can help you feel more connected 🌿';
      case 'angry':
        return 'It\'s okay to feel what you feel first. '
            'When you\'re ready, kindness is here 🍃';
      case 'happy':
        return 'Your joy is contagious! '
            'What kindness could you spread today? ✨';
      default:
        return getDailyPrompt();
    }
  }

  static List<String> getQuickSuggestions(String category) {
    switch (category) {
      case 'self':
        return [
          'Took a break when I needed it',
          'Said something kind to myself',
          'Made my favorite drink',
          'Let go of something I couldn\'t control',
        ];
      case 'family':
        return [
          'Called a family member to check in',
          'Cooked a meal for someone',
          'Gave a family member a genuine compliment',
          'Helped with a chore without being asked',
        ];
      case 'friends':
        return [
          'Texted a friend to see how they\'re doing',
          'Listened to a friend who needed to talk',
          'Made someone laugh',
          'Shared something that reminded me of them',
        ];
      case 'stranger':
        return [
          'Held the door for someone',
          'Smiled at a stranger',
          'Let someone go ahead in line',
          'Gave a genuine compliment to someone',
        ];
      case 'nature':
        return [
          'Picked up litter',
          'Watered a plant',
          'Fed the birds',
          'Chose to walk instead of drive',
        ];
      case 'community':
        return [
          'Helped a neighbor',
          'Donated something I didn\'t need',
          'Left a positive review for a small business',
          'Shared helpful info in a group',
        ];
      default:
        return [
          'Did something kind today',
          'Helped someone in a small way',
          'Spread a little joy',
        ];
    }
  }

  static String getMilestoneMessage(int milestone) {
    switch (milestone) {
      case 3:
        return '3 days of kindness! 🌸\nYou\'re building a beautiful habit~';
      case 7:
        return 'A whole week of kindness! 🌟\nYour garden is glowing with warmth~';
      case 14:
        return '2 weeks of spreading love! 💝\nYou\'re making the world softer~';
      case 30:
        return '30 days of kindness! 🏆\nYou\'ve grown a forest of compassion~';
      default:
        return '$milestone day streak! ✨\nEvery day counts~';
    }
  }

  String getEncouragementMessage() {
    if (_currentStreak >= 7) {
      return 'A whole week of kindness! Your garden glows~ 🌟';
    } else if (_currentStreak >= 3) {
      return '$_currentStreak days of spreading love~ 💕';
    } else if (_totalKindnessCount >= 10) {
      return '$_totalKindnessCount acts of kindness! Amazing~ ✨';
    } else if (_totalKindnessCount > 0) {
      return 'Every kindness plants a seed~ 🌱';
    } else {
      return 'Ready to spread some love? 💚';
    }
  }

  Map<String, int> getCategoryDistribution() {
    final distribution = <String, int>{};
    for (var act in _myKindnessActs) {
      distribution[act.category] = (distribution[act.category] ?? 0) + 1;
    }
    return distribution;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _myActsSubscription?.cancel();
    _communitySubscription?.cancel();
    super.dispose();
  }
}