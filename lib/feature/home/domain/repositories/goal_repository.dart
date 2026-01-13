import '../entities/goal.dart';

/// Abstract repository defining goal operations
abstract class GoalRepository {
  /// Get all goals
  Future<List<Goal>> getAllGoals();

  /// Check if user has any goals
  Future<bool> hasAnyGoals();

  /// Get a specific goal by ID
  Future<Goal?> getGoalById(String id);

  /// Create a new goal
  Future<void> createGoal(Goal goal);

  /// Update an existing goal
  Future<void> updateGoal(Goal goal);

  /// Delete a goal by ID
  Future<void> deleteGoal(String id);

  /// Update goal progress (add to current amount)
  Future<void> updateProgress(String id, double amount);
}
