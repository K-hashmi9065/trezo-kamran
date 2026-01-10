import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/datasources/plan_local_datasource.dart';
import '../../data/datasources/plan_remote_datasource.dart';
import '../../data/repositories/plan_repository_impl.dart';
import '../../domain/entities/plan_entity.dart';
import '../../domain/usecases/get_plans_usecase.dart';
import 'plan_state.dart';

// Provider for Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Provider for remote datasource
final planRemoteDataSourceProvider = Provider<PlanRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return PlanRemoteDataSourceImpl(firestore);
});

// Provider for local datasource
final planLocalDataSourceProvider = Provider<PlanLocalDataSource>((ref) {
  return PlanLocalDataSourceImpl();
});

// Provider for repository
final planRepositoryProvider = Provider((ref) {
  final remoteDataSource = ref.watch(planRemoteDataSourceProvider);
  final localDataSource = ref.watch(planLocalDataSourceProvider);
  return PlanRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

// Provider for use case
final getPlansUseCaseProvider = Provider((ref) {
  final repository = ref.watch(planRepositoryProvider);
  return GetPlansUseCase(repository);
});

// ViewModel Provider
final planViewModelProvider = StateNotifierProvider<PlanViewModel, PlanState>((
  ref,
) {
  final getPlansUseCase = ref.watch(getPlansUseCaseProvider);
  return PlanViewModel(getPlansUseCase);
});

class PlanViewModel extends StateNotifier<PlanState> {
  final GetPlansUseCase _getPlansUseCase;

  PlanViewModel(this._getPlansUseCase) : super(const PlanInitial()) {
    loadPlans();
  }

  Future<void> loadPlans() async {
    state = const PlanLoading();
    try {
      final plans = await _getPlansUseCase.call();

      // Separate monthly and yearly plans
      PlanEntity? monthlyPlan;
      PlanEntity? yearlyPlan;

      try {
        monthlyPlan = plans.firstWhere((plan) => plan.billingCycle == 'month');
      } catch (e) {
        // No monthly plan found
      }

      try {
        yearlyPlan = plans.firstWhere((plan) => plan.billingCycle == 'year');
      } catch (e) {
        // No yearly plan found
      }

      state = PlanLoaded(
        plans: plans,
        monthlyPlan: monthlyPlan,
        yearlyPlan: yearlyPlan,
      );
    } catch (e) {
      state = PlanError(e.toString());
    }
  }

  PlanEntity? getPlanByBillingCycle(bool isYearly) {
    if (state is PlanLoaded) {
      final loadedState = state as PlanLoaded;
      return isYearly ? loadedState.yearlyPlan : loadedState.monthlyPlan;
    }
    return null;
  }
}
