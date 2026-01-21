import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/plan_entity.dart';
import '../models/user_subscription_model.dart';

class SubscriptionService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SubscriptionService(this._firestore, this._auth);

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Process subscription (set isPro and create subscription document with planId reference)
  Future<void> processSubscription(PlanEntity plan) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      // Calculate expiry date based on billing cycle
      final now = DateTime.now();
      DateTime expiryDate;
      if (plan.isYearly) {
        expiryDate = DateTime(now.year + 1, now.month, now.day);
      } else {
        // Monthly subscription
        expiryDate = DateTime(now.year, now.month + 1, now.day);
      }

      // Create subscription object with only planId reference
      final subscription = UserSubscription(
        id: 'current',
        planId: plan.planId, // Store only the plan ID
        subscriptionDate: now,
        expiryDate: expiryDate,
        isActive: true,
      );

      // Batch write to:
      // 1. Set user's isPro status (use set with merge to create if doesn't exist)
      // 2. Create subscription document (with planId reference only)
      final batch = _firestore.batch();

      // Set user document with merge (creates if doesn't exist)
      final userDocRef = _firestore.collection('users').doc(_userId);
      batch.set(userDocRef, {'isPro': true}, SetOptions(merge: true));

      // Create subscription document
      final subscriptionDocRef = userDocRef
          .collection('subscription')
          .doc('current');
      batch.set(subscriptionDocRef, subscription.toFirestore());

      // Commit batch
      await batch.commit();

      print(
        'Subscription processed successfully for user $_userId with planId: ${plan.planId}',
      );
    } catch (e) {
      print('Error processing subscription: $e');
      throw Exception('Failed to process subscription: $e');
    }
  }

  // Cancel subscription (set isPro to false and mark subscription as inactive)
  Future<void> cancelSubscription() async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      final batch = _firestore.batch();

      // Update user document
      final userDocRef = _firestore.collection('users').doc(_userId);
      batch.update(userDocRef, {'isPro': false});

      // Update subscription document
      final subscriptionDocRef = userDocRef
          .collection('subscription')
          .doc('current');
      batch.update(subscriptionDocRef, {'isActive': false});

      // Commit batch
      await batch.commit();

      print('Subscription cancelled successfully for user $_userId');
    } catch (e) {
      print('Error cancelling subscription: $e');
      throw Exception('Failed to cancel subscription: $e');
    }
  }
}

// Provider for SubscriptionService
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService(FirebaseFirestore.instance, FirebaseAuth.instance);
});
