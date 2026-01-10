import '../entities/goal.dart';
import '../repositories/goal_repository.dart';

/// Use case for updating an existing goal
class UpdateGoalUseCase {
  final GoalRepository _repository;

  UpdateGoalUseCase(this._repository);

  Future<void> call(Goal goal) {
    return _repository.updateGoal(goal);
  }
}
