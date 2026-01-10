import '../entities/goal.dart';
import '../repositories/goal_repository.dart';

/// Use case for retrieving a specific goal by ID
class GetGoalByIdUseCase {
  final GoalRepository _repository;

  GetGoalByIdUseCase(this._repository);

  Future<Goal?> call(String id) {
    return _repository.getGoalById(id);
  }
}
