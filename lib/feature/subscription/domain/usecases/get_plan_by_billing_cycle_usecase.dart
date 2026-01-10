import '../entities/plan_entity.dart';
import '../repositories/plan_repository.dart';

class GetPlanByBillingCycleUseCase {
  final PlanRepository repository;

  GetPlanByBillingCycleUseCase(this.repository);

  Future<PlanEntity?> call(String billingCycle) async {
    return await repository.getPlanByBillingCycle(billingCycle);
  }
}
