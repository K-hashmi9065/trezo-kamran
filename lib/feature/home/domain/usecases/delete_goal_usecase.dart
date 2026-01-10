import '../repositories/goal_repository.dart';

/// Use case for deleting a goal
class DeleteGoalUseCase {
  final GoalRepository _repository;

  DeleteGoalUseCase(this._repository);

  Future<void> call(String id) {
    return _repository.deleteGoal(id);
  }
}
