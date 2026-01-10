import '../repositories/goal_repository.dart';

/// Use case for updating goal progress (current amount)
class UpdateGoalProgressUseCase {
  final GoalRepository _repository;

  UpdateGoalProgressUseCase(this._repository);

  Future<void> call(String id, double amount) {
    return _repository.updateProgress(id, amount);
  }
}
