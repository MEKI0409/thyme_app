// services/firebase_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;

  FirebaseService._internal() {
    _configureFirestore();
  }

  void _configureFirestore() {
    _firestore.settings = const Settings(
      persistenceEnabled: true, // Enable offline persistence
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    _log('Firestore configured with offline persistence');
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('🔥 FirebaseService: $message');
    }
  }

  void _logError(String message, [dynamic error]) {
    if (kDebugMode) {
      debugPrint('❌ FirebaseService Error: $message');
      if (error != null) {
        debugPrint('Error details: $error');
      }
    }
  }

  // AUTH

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail(String email, String password) async {
    _log('Signing in user: $email');
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    _log('Creating user: $email');
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    _log('Signing out user');
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _log('Sending password reset email to: $email');
    await _auth.sendPasswordResetEmail(email: email);
  }

  // USERS

  Future<void> createUserDocument(String uid, Map<String, dynamic> data) async {
    _log('Creating user document: $uid');
    await _firestore.collection('users').doc(uid).set(data);
  }

  Stream<DocumentSnapshot> getUserDocument(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  Future<void> updateUserDocument(String uid, Map<String, dynamic> data) async {
    _log('Updating user document: $uid');
    await _firestore.collection('users').doc(uid).update(data);
  }

  Future<void> deleteUserData(String uid) async {
    _log('Deleting all user data: $uid');

    const batchLimit = 450; // 留余量
    var batch = _firestore.batch();
    var operationCount = 0;

    Future<void> addDeleteToBatch(DocumentReference ref) async {
      batch.delete(ref);
      operationCount++;
      if (operationCount >= batchLimit) {
        await batch.commit();
        batch = _firestore.batch();
        operationCount = 0;
      }
    }

    await addDeleteToBatch(_firestore.collection('users').doc(uid));

    final habits = await _firestore
        .collection('habits')
        .where('userId', isEqualTo: uid)
        .get();
    for (var doc in habits.docs) {
      await addDeleteToBatch(doc.reference);
    }

    final moods = await _firestore
        .collection('moods')
        .where('userId', isEqualTo: uid)
        .get();
    for (var doc in moods.docs) {
      await addDeleteToBatch(doc.reference);
    }

    await addDeleteToBatch(_firestore.collection('gardens').doc(uid));

    final kindness = await _firestore
        .collection('kindness')
        .where('userId', isEqualTo: uid)
        .get();
    for (var doc in kindness.docs) {
      await addDeleteToBatch(doc.reference);
    }

    if (operationCount > 0) {
      await batch.commit();
    }
    _log('All user data deleted');
  }

  // HABITS

  Future<String> createHabit(Map<String, dynamic> habitData) async {
    _log('Creating habit: ${habitData['title']}');
    try {
      final docRef = await _firestore.collection('habits').add(habitData);
      _log('Habit created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      _logError('Failed to create habit', e);
      rethrow;
    }
  }

  Stream<QuerySnapshot> getHabitsForUser(String userId) {
    _log('Fetching habits for user: $userId');

    try {
      return _firestore
          .collection('habits')
          .where('userId', isEqualTo: userId)
          .snapshots();
    } catch (e) {
      _logError('Failed to fetch habits', e);
      rethrow;
    }
  }

  Future<void> updateHabit(String habitId, Map<String, dynamic> data) async {
    _log('Updating habit: $habitId');
    await _firestore.collection('habits').doc(habitId).update(data);
  }

  Future<void> deleteHabit(String habitId) async {
    _log('Deleting habit: $habitId');
    await _firestore.collection('habits').doc(habitId).delete();
  }

  Future<void> batchUpdateHabits(Map<String, Map<String, dynamic>> updates) async {
    _log('Batch updating ${updates.length} habits');
    final batch = _firestore.batch();

    updates.forEach((habitId, data) {
      batch.update(_firestore.collection('habits').doc(habitId), data);
    });

    await batch.commit();
  }

  // MOOD ENTRIES

  Future<String> createMoodEntry(Map<String, dynamic> moodData) async {
    _log('Creating mood entry');
    final docRef = await _firestore.collection('moods').add(moodData);
    return docRef.id;
  }

  Stream<QuerySnapshot> getMoodEntriesForUser(String userId) {
    return _firestore
        .collection('moods')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots();
  }

  Future<List<QueryDocumentSnapshot>> getMoodEntriesForDateRange(
      String userId,
      DateTime start,
      DateTime end,
      ) async {
    _log('Fetching mood entries from $start to $end');
    final snapshot = await _firestore
        .collection('moods')
        .where('userId', isEqualTo: userId)
        .where('createdAt', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('createdAt', isLessThanOrEqualTo: end.toIso8601String())
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs;
  }

  Future<void> deleteMoodEntry(String entryId) async {
    _log('Deleting mood entry: $entryId');
    await _firestore.collection('moods').doc(entryId).delete();
  }

  Future<void> updateMoodEntry(String entryId, Map<String, dynamic> data) async {
    _log('Updating mood entry: $entryId');
    await _firestore.collection('moods').doc(entryId).update(data);
  }

  // GARDEN

  Future<void> saveGardenState(
      String userId, Map<String, dynamic> gardenData) async {
    _log('Saving garden state for user: $userId');
    await _firestore.collection('gardens').doc(userId).set(gardenData);
  }

  Stream<DocumentSnapshot> getGardenState(String userId) {
    return _firestore.collection('gardens').doc(userId).snapshots();
  }

  Future<DocumentSnapshot> getGardenStateOnce(String userId) async {
    return await _firestore.collection('gardens').doc(userId).get();
  }

  Future<void> updateGardenState(
      String userId, Map<String, dynamic> data) async {
    _log('Updating garden state for user: $userId');
    await _firestore.collection('gardens').doc(userId).update(data);
  }

  // KINDNESS
  Future<String> createKindnessAct(Map<String, dynamic> data) async {
    _log('Creating kindness act');
    final docRef = await _firestore.collection('kindness').add(data);
    return docRef.id;
  }

  Stream<QuerySnapshot> getKindnessActsForUser(String userId) {
    return _firestore
        .collection('kindness')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  Stream<QuerySnapshot> getPublicKindnessActs() {
    return _firestore
        .collection('kindness')
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots();
  }

  // UTILITIES

  Future<bool> isOnline() async {
    try {
      await _firestore
          .collection('_health')
          .doc('check')
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 3));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> clearCache() async {
    _log('Clearing Firestore cache');
    await _firestore.clearPersistence();
  }

  FieldValue get serverTimestamp => FieldValue.serverTimestamp();
}