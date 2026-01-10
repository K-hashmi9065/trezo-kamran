import '../../domain/entities/plan_entity.dart';
import '../../domain/repositories/plan_repository.dart';
import '../datasources/plan_local_datasource.dart';
import '../datasources/plan_remote_datasource.dart';

class PlanRepositoryImpl implements PlanRepository {
  final PlanRemoteDataSource remoteDataSource;
  final PlanLocalDataSource localDataSource;

  PlanRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<PlanEntity>> getPlans() async {
    try {
      final plans = await remoteDataSource.getPlans();
      await localDataSource.cachePlans(plans);
      return plans;
    } catch (e) {
      // Try to get from cache if remote fails
      final cachedPlans = await localDataSource.getCachedPlans();
      if (cachedPlans.isNotEmpty) {
        return cachedPlans;
      }
      rethrow;
    }
  }

  @override
  Future<PlanEntity?> getPlanByBillingCycle(String billingCycle) async {
    try {
      return await remoteDataSource.getPlanByBillingCycle(billingCycle);
    } catch (e) {
      rethrow;
    }
  }
}
