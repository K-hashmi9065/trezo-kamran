import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_subscription_model.dart';
import '../../data/repositories/user_subscription_repository.dart';
import '../../../subscription/data/models/plan_model.dart';

// Combined model with subscription and plan details
class SubscriptionWithPlan {
  final UserSubscription subscription;
  final PlanModel? plan;

  SubscriptionWithPlan({required this.subscription, this.plan});
}

// Provider to get subscription with plan details
final subscriptionWithPlanProvider = StreamProvider<SubscriptionWithPlan?>((
  ref,
) async* {
  final repository = ref.watch(userSubscriptionRepositoryProvider);

  await for (final subscription in repository.getUserSubscription()) {
    if (subscription == null || !subscription.isActive) {
      yield null;
      continue;
    }

    // Fetch plan details from subscription_plans collection
    try {
      final planDoc = await FirebaseFirestore.instance
          .collection('subscription_plans')
          .doc(subscription.planId)
          .get();

      if (planDoc.exists) {
        final plan = PlanModel.fromFirestore(planDoc);
        yield SubscriptionWithPlan(subscription: subscription, plan: plan);
      } else {
        // Plan not found, return subscription without plan details
        yield SubscriptionWithPlan(subscription: subscription, plan: null);
      }
    } catch (e) {
      print('Error fetching plan details: $e');
      // Return subscription without plan details on error
      yield SubscriptionWithPlan(subscription: subscription, plan: null);
    }
  }
});
