import 'package:hive/hive.dart';
import '../models/goal_model.dart';

/// Local data source for goal operations using Hive
class GoalLocalDataSource {
  final Box<GoalModel> _goalsBox;

  GoalLocalDataSource(this._goalsBox);

  /// Get all goals from local storage
  Future<List<GoalModel>> getAllGoals() async {
    try {
      return _goalsBox.values.toList();
    } catch (e) {
      throw Exception('Failed to fetch goals from local storage: $e');
    }
  }

  /// Get a specific goal by ID
  Future<GoalModel?> getGoalById(String id) async {
    try {
      return _goalsBox.get(id);
    } catch (e) {
      throw Exception('Failed to fetch goal with ID $id: $e');
    }
  }

  /// Create a new goal
  Future<void> createGoal(GoalModel goal) async {
    try {
      await _goalsBox.put(goal.hiveId, goal);
    } catch (e) {
      throw Exception('Failed to create goal: $e');
    }
  }

  /// Update an existing goal
  Future<void> updateGoal(GoalModel goal) async {
    try {
      if (!_goalsBox.containsKey(goal.hiveId)) {
        throw Exception('Goal with ID ${goal.hiveId} not found');
      }
      await _goalsBox.put(goal.hiveId, goal);
    } catch (e) {
      throw Exception('Failed to update goal: $e');
    }
  }

  /// Delete a goal by ID
  Future<void> deleteGoal(String id) async {
    try {
      if (!_goalsBox.containsKey(id)) {
        throw Exception('Goal with ID $id not found');
      }
      await _goalsBox.delete(id);
    } catch (e) {
      throw Exception('Failed to delete goal: $e');
    }
  }

  /// Clear all goals (for testing purposes)
  Future<void> clearAllGoals() async {
    try {
      await _goalsBox.clear();
    } catch (e) {
      throw Exception('Failed to clear all goals: $e');
    }
  }
}
