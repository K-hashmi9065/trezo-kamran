import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories_impl/goal_repository_provider.dart';
import '../../domain/entities/goal.dart';
import '../../domain/usecases/create_goal_usecase.dart';
import '../../domain/usecases/delete_goal_usecase.dart';
import '../../domain/usecases/get_all_goals_usecase.dart';
import '../../domain/usecases/get_goal_by_id_usecase.dart';
import '../../domain/usecases/update_goal_progress_usecase.dart';
import '../../domain/usecases/update_goal_usecase.dart';
import 'goal_state.dart';

import '../../data/repositories_impl/transaction_repository_provider.dart';
import '../../data/repositories_impl/transaction_repository.dart';

/// Goal ViewModel managing goal state and operations
class GoalViewModel extends Notifier<GoalState> {
  late final GetAllGoalsUseCase _getAllGoalsUseCase;
  late final GetGoalByIdUseCase _getGoalByIdUseCase;
  late final CreateGoalUseCase _createGoalUseCase;
  late final UpdateGoalUseCase _updateGoalUseCase;
  late final DeleteGoalUseCase _deleteGoalUseCase;
  late final UpdateGoalProgressUseCase _updateGoalProgressUseCase;
  late final TransactionRepository _transactionRepository;

  @override
  GoalState build() {
    // Initialize use cases with the new repository (includes remote data source)
    final repository = ref.read(goalRepositoryProvider);
    _transactionRepository = ref.read(transactionRepositoryProvider);

    _getAllGoalsUseCase = GetAllGoalsUseCase(repository);
    _getGoalByIdUseCase = GetGoalByIdUseCase(repository);
    _createGoalUseCase = CreateGoalUseCase(repository);
    _updateGoalUseCase = UpdateGoalUseCase(repository);
    _deleteGoalUseCase = DeleteGoalUseCase(repository);
    _updateGoalProgressUseCase = UpdateGoalProgressUseCase(repository);

    // Load goals on initialization
    loadGoals();

    return const GoalInitial();
  }

  /// Load all goals
  Future<void> loadGoals() async {
    state = const GoalLoading();
    try {
      final goals = await _getAllGoalsUseCase();
      if (goals.isEmpty) {
        state = const GoalEmpty();
      } else {
        state = GoalLoaded(goals);
      }
    } catch (e) {
      state = GoalError('Failed to load goals: $e');
    }
  }

  /// Get a specific goal by ID
  Future<Goal?> getGoalById(String id) async {
    try {
      return await _getGoalByIdUseCase(id);
    } catch (e) {
      state = GoalError('Failed to fetch goal: $e');
      return null;
    }
  }

  /// Create a new goal
  Future<bool> createGoal(Goal goal) async {
    state = const GoalLoading();
    try {
      await _createGoalUseCase(goal);
      await loadGoals();
      return true;
    } catch (e) {
      state = GoalError('Failed to create goal: $e');
      return false;
    }
  }

  /// Update an existing goal
  Future<bool> updateGoal(Goal goal) async {
    state = const GoalLoading();
    try {
      await _updateGoalUseCase(goal);
      await loadGoals();
      return true;
    } catch (e) {
      state = GoalError('Failed to update goal: $e');
      return false;
    }
  }

  /// Delete a goal
  Future<bool> deleteGoal(String id) async {
    state = const GoalLoading();
    try {
      await _deleteGoalUseCase(id);
      await loadGoals();
      return true;
    } catch (e) {
      state = GoalError('Failed to delete goal: $e');
      return false;
    }
  }

  /// Update goal progress (add to current amount)
  Future<bool> updateProgress(String id, double amount) async {
    state = const GoalLoading();
    try {
      await _updateGoalProgressUseCase(id, amount);
      await loadGoals();
      return true;
    } catch (e) {
      state = GoalError('Failed to update progress: $e');
      return false;
    }
  }

  /// Add a transaction record and refresh goals
  Future<bool> addTransactionRecord(
    String goalId,
    double amount,
    String? note,
  ) async {
    state = const GoalLoading();
    try {
      await _transactionRepository.addTransaction(
        goalId: goalId,
        amount: amount.abs(),
        type: amount < 0 ? 'withdrawal' : 'deposit',
        date: DateTime.now(),
        note: note,
      );
      await loadGoals();
      return true;
    } catch (e) {
      state = GoalError('Failed to add transaction: $e');
      return false;
    }
  }

  /// Reset state to initial
  void resetState() {
    state = const GoalInitial();
  }
}

// Providers

/// Goal ViewModel Provider
final goalViewModelProvider = NotifierProvider<GoalViewModel, GoalState>(() {
  return GoalViewModel();
});
