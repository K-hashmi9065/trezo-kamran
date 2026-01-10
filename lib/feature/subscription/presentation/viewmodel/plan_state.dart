import '../../domain/entities/plan_entity.dart';

abstract class PlanState {
  const PlanState();
}

class PlanInitial extends PlanState {
  const PlanInitial();
}

class PlanLoading extends PlanState {
  const PlanLoading();
}

class PlanLoaded extends PlanState {
  final List<PlanEntity> plans;
  final PlanEntity? monthlyPlan;
  final PlanEntity? yearlyPlan;

  const PlanLoaded({required this.plans, this.monthlyPlan, this.yearlyPlan});
}

class PlanError extends PlanState {
  final String message;

  const PlanError(this.message);
}
