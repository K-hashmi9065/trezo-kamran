import 'dart:io';
import 'package:logger/logger.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_checker.dart';
import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/goal_local_data_source.dart';
import '../datasources/goal_remote_data_source.dart';
import '../models/goal_model.dart';

/// Enhanced repository implementation with offline-first strategy
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
  Future<bool> hasAnyGoals() async {
    // Try remote first if online
    final isConnected = await _networkChecker.isConnected;
    if (isConnected) {
      try {
        await _remoteDataSource.ensureUserDocumentExists();
        return await _remoteDataSource.hasAnyGoals();
      } catch (e) {
        _logger.w('Failed to check remote goals: $e');
      }
    }
    // Fallback to local
    final localGoals = await _localDataSource.getAllGoals();
    return localGoals.isNotEmpty;
  }

  @override
  Future<List<Goal>> getAllGoals() async {
    // Try to fetch from remote if online
    final isConnected = await _networkChecker.isConnected;

    if (isConnected) {
      try {
        _logger.i('Fetching goals from Firebase');

        // Ensure user document exists (creates 'users' collection if needed)
        await _remoteDataSource.ensureUserDocumentExists();

        final remoteGoals = await _remoteDataSource.getAllGoals();
        final localGoals = await _localDataSource.getAllGoals();

        // If remote is empty but local has data, sync local to remote (Initial Sync)
        if (remoteGoals.isEmpty && localGoals.isNotEmpty) {
          _logger.i(
            'Remote is empty but local has data. Syncing local to remote...',
          );
          await _remoteDataSource.syncGoals(localGoals);
          // Return local goals as they are now the source of truth
          return localGoals.map((model) => model.toEntity()).toList();
        }

        // Standard Sync: Remote -> Local
        // Update local cache
        _logger.d('Updating local cache with ${remoteGoals.length} goals');
        for (final goal in remoteGoals) {
          await _localDataSource.createGoal(goal);
        }

        // Fall through to return merged local data.
      } on NetworkException catch (e) {
        _logger.w('Network error while fetching goals: $e');
      } on ServerException catch (e) {
        _logger.w('Firebase error while fetching goals: $e');
      } catch (e) {
        _logger.e('Unexpected error while fetching goals: $e');
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
        _logger.i('Fetching goal $id from Firebase');
        final remoteGoal = await _remoteDataSource.getGoalById(id);

        // Update local cache
        await _localDataSource.createGoal(remoteGoal);

        return remoteGoal.toEntity();
      } on NotFoundException catch (e) {
        _logger.w('Goal $id not found remotely: $e');
      } on NetworkException catch (e) {
        _logger.w('Network error while fetching goal: $e');
      } catch (e) {
        _logger.e('Unexpected error while fetching goal: $e');
      }
    }

    // Return from local cache
    _logger.i('Fetching goal $id from local cache');
    final localGoal = await _localDataSource.getGoalById(id);
    return localGoal?.toEntity();
  }

  @override
  Future<void> createGoal(Goal goal) async {
    var goalModel = GoalModel.fromEntity(goal);

    // Always save locally first
    _logger.i('Creating goal locally: ${goal.title}');
    await _localDataSource.createGoal(goalModel);

    // Sync to remote (Firestore handles offline queueing)
    try {
      _logger.i('Syncing goal to Firebase: ${goal.title}');

      // Ensure user document exists (creates 'users' collection if needed)
      await _remoteDataSource.ensureUserDocumentExists();

      // Check if cover image needs upload
      if (goalModel.coverImagePath != null &&
          !goalModel.coverImagePath!.startsWith('http') &&
          !goalModel.coverImagePath!.startsWith('data:')) {
        try {
          final file = File(goalModel.coverImagePath!);
          if (file.existsSync()) {
            _logger.i('Uploading goal cover image...');
            final url = await _remoteDataSource.uploadGoalImage(file);
            goalModel = goalModel.copyWith(coverImagePath: url);

            // Update local with the new URL so we don't upload again
            await _localDataSource.updateGoal(goalModel);
          }
        } catch (e) {
          _logger.w(
            'Failed to upload goal image, continuing with local path: $e',
          );
        }
      }

      final remoteGoal = await _remoteDataSource.createGoal(goalModel);

      // Update local cache with server response (if any changes)
      await _localDataSource.updateGoal(remoteGoal);
    } catch (e) {
      _logger.e('Error syncing goal to remote: $e');
      // Goal is saved locally, sync is handled by Firestore SDK or next app restart
    }
  }

  @override
  Future<void> updateGoal(Goal goal) async {
    var goalModel = GoalModel.fromEntity(goal);

    // Always update locally first
    _logger.i('Updating goal locally: ${goal.title}');
    await _localDataSource.updateGoal(goalModel);

    // Sync to remote
    try {
      _logger.i('Syncing goal update to Firebase: ${goal.title}');

      // Ensure user document exists
      await _remoteDataSource.ensureUserDocumentExists();

      // Check if cover image needs upload
      if (goalModel.coverImagePath != null &&
          !goalModel.coverImagePath!.startsWith('http') &&
          !goalModel.coverImagePath!.startsWith('data:')) {
        try {
          final file = File(goalModel.coverImagePath!);
          if (file.existsSync()) {
            _logger.i('Uploading goal cover image...');
            final url = await _remoteDataSource.uploadGoalImage(file);
            goalModel = goalModel.copyWith(coverImagePath: url);

            // Update local with the new URL so we don't upload again
            await _localDataSource.updateGoal(goalModel);
          }
        } catch (e) {
          _logger.w(
            'Failed to upload goal image, continuing with local path: $e',
          );
        }
      }

      final remoteGoal = await _remoteDataSource.updateGoal(goalModel);

      // Update local cache with server response
      await _localDataSource.updateGoal(remoteGoal);
    } catch (e) {
      _logger.e('Error syncing goal update to remote: $e');
    }
  }

  @override
  Future<void> deleteGoal(String id) async {
    // Always delete locally first
    _logger.i('Deleting goal locally: $id');
    await _localDataSource.deleteGoal(id);

    // Sync to remote
    try {
      _logger.i('Syncing goal deletion to remote API: $id');
      await _remoteDataSource.deleteGoal(id);
    } catch (e) {
      if (e is NotFoundException) {
        _logger.w('Goal $id not found on remote (already deleted?): $e');
      } else {
        _logger.e('Error syncing goal deletion to remote: $e');
      }
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

    // Sync to remote
    try {
      _logger.i('Syncing progress update to remote API: $id');
      final remoteGoal = await _remoteDataSource.updateGoalProgress(id, amount);

      // Update local cache with server response
      await _localDataSource.updateGoal(remoteGoal);
    } catch (e) {
      _logger.e('Error syncing progress update to remote: $e');
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
