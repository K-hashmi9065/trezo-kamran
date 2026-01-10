import '../entities/goal.dart';
import '../repositories/goal_repository.dart';

/// Use case for retrieving all goals
class GetAllGoalsUseCase {
  final GoalRepository _repository;

  GetAllGoalsUseCase(this._repository);

  Future<List<Goal>> call() {
    return _repository.getAllGoals();
  }
}
