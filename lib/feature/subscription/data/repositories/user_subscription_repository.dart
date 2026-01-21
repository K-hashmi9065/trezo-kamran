import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_subscription_model.dart';

class UserSubscriptionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UserSubscriptionRepository(this._firestore, this._auth);

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Get reference to user's subscription document
  DocumentReference _userSubscriptionDoc() {
    if (_userId == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('subscription')
        .doc('current');
  }

  // Get user's current subscription
  Stream<UserSubscription?> getUserSubscription() {
    try {
      return _userSubscriptionDoc().snapshots().map((doc) {
        if (doc.exists) {
          return UserSubscription.fromFirestore(doc);
        }
        return null;
      });
    } catch (e) {
      print('Error fetching user subscription: $e');
      return Stream.value(null);
    }
  }

  // Get user's subscription as Future
  Future<UserSubscription?> getUserSubscriptionOnce() async {
    try {
      final doc = await _userSubscriptionDoc().get();
      if (doc.exists) {
        return UserSubscription.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching user subscription: $e');
      return null;
    }
  }

  // Save or update user subscription
  Future<void> saveUserSubscription(UserSubscription subscription) async {
    try {
      await _userSubscriptionDoc().set(
        subscription.toFirestore(),
        SetOptions(merge: true),
      );
    } catch (e) {
      print('Error saving subscription: $e');
      throw Exception('Failed to save subscription: $e');
    }
  }

  // Cancel user subscription
  Future<void> cancelSubscription() async {
    try {
      await _userSubscriptionDoc().update({'isActive': false});
    } catch (e) {
      print('Error canceling subscription: $e');
      throw Exception('Failed to cancel subscription: $e');
    }
  }

  // Check if user has active subscription
  Future<bool> hasActiveSubscription() async {
    try {
      final subscription = await getUserSubscriptionOnce();
      return subscription != null && subscription.isActive;
    } catch (e) {
      print('Error checking subscription status: $e');
      return false;
    }
  }
}

// Provider for UserSubscriptionRepository
final userSubscriptionRepositoryProvider = Provider<UserSubscriptionRepository>(
  (ref) {
    return UserSubscriptionRepository(
      FirebaseFirestore.instance,
      FirebaseAuth.instance,
    );
  },
);
