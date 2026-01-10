import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plan_model.dart';

abstract class PlanRemoteDataSource {
  Future<List<PlanModel>> getPlans();
  Future<PlanModel?> getPlanByBillingCycle(String billingCycle);
}

class PlanRemoteDataSourceImpl implements PlanRemoteDataSource {
  final FirebaseFirestore firestore;

  PlanRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<PlanModel>> getPlans() async {
    try {
      final querySnapshot = await firestore
          .collection('subscription_plans')
          .where('is_active', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PlanModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch plans: $e');
    }
  }

  @override
  Future<PlanModel?> getPlanByBillingCycle(String billingCycle) async {
    try {
      final querySnapshot = await firestore
          .collection('subscription_plans')
          .where('billing_cycle', isEqualTo: billingCycle)
          .where('is_active', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return PlanModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      throw Exception('Failed to fetch plan by billing cycle: $e');
    }
  }
}
