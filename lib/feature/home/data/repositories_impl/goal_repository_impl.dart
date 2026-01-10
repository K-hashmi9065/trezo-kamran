import 'package:logger/logger.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_checker.dart';
import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/goal_local_data_source.dart';
import '../datasources/goal_remote_data_source.dart';
import '../models/goal_model.dart';

/// Enhanced repository implementation with offline-first strategy
///
/// Strategy:
/// - Always read from local cache first (fast access)
/// - Fetch from remote in background when online
/// - Update local cache with fresh data
/// - Queue operations when offline for later sync
class GoalRepositoryImpl implements GoalRepository {
  final GoalLocalDataSource _localDataSource;
  final GoalRemoteDataSource _remoteDataSource;
  final NetworkChecker _networkChecker;
  final Logger _logger = Logger();

  GoalRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
    this._networkChecker,
  );

  @override
  Future<List<Goal>> getAllGoals() async {
    // Try to fetch from remote if online
    final isConnected = await _networkChecker.isConnected;

    if (isConnected) {
      try {
        _logger.i('Fetching goals from remote API');
        final remoteGoals = await _remoteDataSource.getAllGoals();

        // Update local cache
        _logger.d('Updating local cache with ${remoteGoals.length} goals');
        for (final goal in remoteGoals) {
          await _localDataSource.createGoal(goal);
        }

        return remoteGoals.map((model) => model.toEntity()).toList();
      } on NetworkException catch (e) {
        _logger.w('Network error while fetching goals: $e');
        // Fall through to local data
      } on ServerException catch (e) {
        _logger.w('Server error while fetching goals: $e');
        // Fall through to local data
      } catch (e) {
        _logger.e('Unexpected error while fetching goals: $e');
        // Fall through to local data
      }
    }

    // Return from local cache
    _logger.i('Fetching goals from local cache');
    final localGoals = await _localDataSource.getAllGoals();
    return localGoals.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Goal?> getGoalById(String id) async {
    // Try remote first if online
    final isConnected = await _networkChecker.isConnected;

    if (isConnected) {
      try {
        _logger.i('Fetching goal $id from remote API');
        final remoteGoal = await _remoteDataSource.getGoalById(id);

        // Update local cache
        await _localDataSource.createGoal(remoteGoal);

        return remoteGoal.toEntity();
      } on NotFoundException catch (e) {
        _logger.w('Goal $id not found remotely: $e');
        // Fall through to local data
      } on NetworkException catch (e) {
        _logger.w('Network error while fetching goal: $e');
        // Fall through to local data
      } catch (e) {
        _logger.e('Unexpected error while fetching goal: $e');
        // Fall through to local data
      }
    }

    // Return from local cache
    _logger.i('Fetching goal $id from local cache');
    final localGoal = await _localDataSource.getGoalById(id);
    return localGoal?.toEntity();
  }

  @override
  Future<void> createGoal(Goal goal) async {
    final goalModel = GoalModel.fromEntity(goal);

    // Always save locally first
    _logger.i('Creating goal locally: ${goal.title}');
    await _localDataSource.createGoal(goalModel);

    // Try to sync to remote if online
    final isConnected = await _networkChecker.isConnected;
    if (isConnected) {
      try {
        _logger.i('Syncing goal to remote API: ${goal.title}');
        final remoteGoal = await _remoteDataSource.createGoal(goalModel);

        // Update local cache with server response (may have server-generated fields)
        await _localDataSource.updateGoal(remoteGoal);
      } on NetworkException catch (e) {
        _logger.w('Failed to sync goal to remote (will retry later): $e');
        // TODO: Add to sync queue
      } catch (e) {
        _logger.e('Error syncing goal to remote: $e');
        // Goal is saved locally, sync can be retried
      }
    } else {
      _logger.w('Offline: Goal will be synced when online');
      // TODO: Add to sync queue
    }
  }

  @override
  Future<void> updateGoal(Goal goal) async {
    final goalModel = GoalModel.fromEntity(goal);

    // Always update locally first
    _logger.i('Updating goal locally: ${goal.title}');
    await _localDataSource.updateGoal(goalModel);

    // Try to sync to remote if online
    final isConnected = await _networkChecker.isConnected;
    if (isConnected) {
      try {
        _logger.i('Syncing goal update to remote API: ${goal.title}');
        final remoteGoal = await _remoteDataSource.updateGoal(goalModel);

        // Update local cache with server response
        await _localDataSource.updateGoal(remoteGoal);
      } on NetworkException catch (e) {
        _logger.w('Failed to sync goal update to remote: $e');
        // TODO: Add to sync queue
      } catch (e) {
        _logger.e('Error syncing goal update to remote: $e');
        // Goal is updated locally, sync can be retried
      }
    } else {
      _logger.w('Offline: Goal update will be synced when online');
      // TODO: Add to sync queue
    }
  }

  @override
  Future<void> deleteGoal(String id) async {
    // Always delete locally first
    _logger.i('Deleting goal locally: $id');
    await _localDataSource.deleteGoal(id);

    // Try to sync to remote if online
    final isConnected = await _networkChecker.isConnected;
    if (isConnected) {
      try {
        _logger.i('Syncing goal deletion to remote API: $id');
        await _remoteDataSource.deleteGoal(id);
      } on NotFoundException catch (e) {
        _logger.w('Goal $id not found on remote (already deleted?): $e');
        // Goal is deleted locally anyway
      } on NetworkException catch (e) {
        _logger.w('Failed to sync goal deletion to remote: $e');
        // TODO: Add to sync queue
      } catch (e) {
        _logger.e('Error syncing goal deletion to remote: $e');
        // Goal is deleted locally, sync can be retried
      }
    } else {
      _logger.w('Offline: Goal deletion will be synced when online');
      // TODO: Add to sync queue
    }
  }

  @override
  Future<void> updateProgress(String id, double amount) async {
    // Get current goal
    final goalModel = await _localDataSource.getGoalById(id);
    if (goalModel == null) {
      throw Exception('Goal with ID $id not found');
    }

    // Calculate updates
    final updatedAmount = goalModel.hiveCurrentAmount + amount;
    final isCompleted = updatedAmount >= goalModel.hiveTargetAmount;

    final updatedGoal = goalModel.copyWith(
      currentAmount: updatedAmount,
      isCompleted: isCompleted,
      updatedAt: DateTime.now(),
    );

    // Update locally first
    _logger.i('Updating goal progress locally: $id (+$amount)');
    await _localDataSource.updateGoal(updatedGoal);

    // Try to sync to remote if online
    final isConnected = await _networkChecker.isConnected;
    if (isConnected) {
      try {
        _logger.i('Syncing progress update to remote API: $id');
        final remoteGoal = await _remoteDataSource.updateGoalProgress(
          id,
          amount,
        );

        // Update local cache with server response
        await _localDataSource.updateGoal(remoteGoal);
      } on NetworkException catch (e) {
        _logger.w('Failed to sync progress update to remote: $e');
        // TODO: Add to sync queue
      } catch (e) {
        _logger.e('Error syncing progress update to remote: $e');
        // Progress is updated locally, sync can be retried
      }
    } else {
      _logger.w('Offline: Progress update will be synced when online');
      // TODO: Add to sync queue
    }
  }

  /// Manually sync all local goals with remote server
  /// Useful when connection is restored
  Future<void> syncWithRemote() async {
    final isConnected = await _networkChecker.isConnected;
    if (!isConnected) {
      _logger.w('Cannot sync: No internet connection');
      throw NoInternetException();
    }

    try {
      _logger.i('Starting manual sync with remote');
      final localGoals = await _localDataSource.getAllGoals();

      final result = await _remoteDataSource.syncGoals(localGoals);
      final syncedGoals = result['syncedGoals'] as List<GoalModel>;
      final conflicts = result['conflicts'] as List;

      if (conflicts.isNotEmpty) {
        _logger.w('Sync completed with ${conflicts.length} conflicts');
        // TODO: Handle conflicts
      } else {
        _logger.i('Sync completed successfully');
      }

      // Update local cache with synced goals
      for (final goal in syncedGoals) {
        await _localDataSource.updateGoal(goal);
      }
    } catch (e) {
      _logger.e('Sync failed: $e');
      rethrow;
    }
  }
}
