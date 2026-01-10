import '../../domain/entities/goal.dart';

/// Sealed class representing different states of goal operations
sealed class GoalState {
  const GoalState();
}

/// Initial state before any operation
class GoalInitial extends GoalState {
  const GoalInitial();
}

/// Loading state during async operations
class GoalLoading extends GoalState {
  const GoalLoading();
}

/// State when goals are successfully loaded
class GoalLoaded extends GoalState {
  final List<Goal> goals;

  const GoalLoaded(this.goals);

  bool get isEmpty => goals.isEmpty;
  bool get isNotEmpty => goals.isNotEmpty;
}

/// State when no goals are available
class GoalEmpty extends GoalState {
  const GoalEmpty();
}

/// State when a goal operation is successful
class GoalSuccess extends GoalState {
  final String message;
  final List<Goal> goals;

  const GoalSuccess(this.message, {this.goals = const []});
}

/// Error state with error message
class GoalError extends GoalState {
  final String message;

  const GoalError(this.message);

  @override
  String toString() => 'GoalError{message: $message}';
}
