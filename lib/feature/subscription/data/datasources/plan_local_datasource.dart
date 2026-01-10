import '../models/plan_model.dart';

abstract class PlanLocalDataSource {
  Future<List<PlanModel>> getCachedPlans();
  Future<void> cachePlans(List<PlanModel> plans);
}

class PlanLocalDataSourceImpl implements PlanLocalDataSource {
  // This is a stub implementation for now
  // Can be enhanced with SharedPreferences or Hive later

  @override
  Future<List<PlanModel>> getCachedPlans() async {
    // Return empty list for now
    return [];
  }

  @override
  Future<void> cachePlans(List<PlanModel> plans) async {
    // No-op for now
  }
}
