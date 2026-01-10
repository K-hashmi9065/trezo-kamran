import '../entities/plan_entity.dart';

abstract class PlanRepository {
  Future<List<PlanEntity>> getPlans();
  Future<PlanEntity?> getPlanByBillingCycle(String billingCycle);
}
