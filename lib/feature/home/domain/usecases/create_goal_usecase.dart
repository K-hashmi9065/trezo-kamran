import '../entities/goal.dart';
import '../repositories/goal_repository.dart';

/// Use case for creating a new goal
class CreateGoalUseCase {
  final GoalRepository _repository;

  CreateGoalUseCase(this._repository);

  Future<void> call(Goal goal) {
    return _repository.createGoal(goal);
  }
}
