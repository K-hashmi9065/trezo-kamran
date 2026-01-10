import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/goal_model.dart';

/// Remote data source for goal-related API operations
class GoalRemoteDataSource {
  final Dio _dio;

  GoalRemoteDataSource(this._dio);

  /// Get all goals for the current user
  /// Throws [ServerException], [UnauthorizedException], [NetworkException], etc.
  Future<List<GoalModel>> getAllGoals() async {
    try {
      final response = await _dio.get(ApiEndpoints.goals);

      // Handle different response structures
      final data = response.data;
      List<dynamic> goalsJson;

      if (data is Map && data.containsKey('goals')) {
        goalsJson = data['goals'] as List<dynamic>;
      } else if (data is List) {
        goalsJson = data;
      } else {
        throw ServerException(
          'Invalid response format',
          statusCode: response.statusCode,
        );
      }

      return goalsJson
          .map((json) => GoalModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Get a specific goal by ID
  /// Throws [NotFoundException] if goal not found
  Future<GoalModel> getGoalById(String goalId) async {
    try {
      final response = await _dio.get(ApiEndpoints.goalById(goalId));

      final data = response.data;
      Map<String, dynamic> goalJson;

      if (data is Map && data.containsKey('goal')) {
        goalJson = data['goal'] as Map<String, dynamic>;
      } else if (data is Map) {
        goalJson = data as Map<String, dynamic>;
      } else {
        throw ServerException(
          'Invalid response format',
          statusCode: response.statusCode,
        );
      }

      return GoalModel.fromJson(goalJson);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Create a new goal
  /// Returns the created [GoalModel]
  Future<GoalModel> createGoal(GoalModel goal) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.createGoal,
        data: goal.toJson(),
      );

      final data = response.data;
      Map<String, dynamic> goalJson;

      if (data is Map && data.containsKey('goal')) {
        goalJson = data['goal'] as Map<String, dynamic>;
      } else if (data is Map) {
        goalJson = data as Map<String, dynamic>;
      } else {
        throw ServerException(
          'Invalid response format',
          statusCode: response.statusCode,
        );
      }

      return GoalModel.fromJson(goalJson);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Update an existing goal
  /// Returns the updated [GoalModel]
  Future<GoalModel> updateGoal(GoalModel goal) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.updateGoal(goal.hiveId),
        data: goal.toJson(),
      );

      final data = response.data;
      Map<String, dynamic> goalJson;

      if (data is Map && data.containsKey('goal')) {
        goalJson = data['goal'] as Map<String, dynamic>;
      } else if (data is Map) {
        goalJson = data as Map<String, dynamic>;
      } else {
        throw ServerException(
          'Invalid response format',
          statusCode: response.statusCode,
        );
      }

      return GoalModel.fromJson(goalJson);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Delete a goal by ID
  Future<void> deleteGoal(String goalId) async {
    try {
      await _dio.delete(ApiEndpoints.deleteGoal(goalId));
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Update goal progress (add to current amount)
  /// Returns the updated [GoalModel]
  Future<GoalModel> updateGoalProgress(String goalId, double amount) async {
    try {
      final response = await _dio.patch(
        ApiEndpoints.updateGoalProgress(goalId),
        data: {'amount': amount},
      );

      final data = response.data;
      Map<String, dynamic> goalJson;

      if (data is Map && data.containsKey('goal')) {
        goalJson = data['goal'] as Map<String, dynamic>;
      } else if (data is Map) {
        goalJson = data as Map<String, dynamic>;
      } else {
        throw ServerException(
          'Invalid response format',
          statusCode: response.statusCode,
        );
      }

      return GoalModel.fromJson(goalJson);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Add a transaction to a goal (deposit/withdrawal)
  /// Returns both the transaction and updated goal
  Future<Map<String, dynamic>> addTransaction({
    required String goalId,
    required double amount,
    required String type, // 'deposit' or 'withdrawal'
    required DateTime date,
    String? note,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.addGoalTransaction(goalId),
        data: {
          'amount': amount,
          'type': type,
          'date': date.toIso8601String(),
          'note': note,
        },
      );

      final data = response.data as Map<String, dynamic>;

      return {
        'transaction': data['transaction'],
        'goal': data.containsKey('goal')
            ? GoalModel.fromJson(data['goal'] as Map<String, dynamic>)
            : null,
      };
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Get all transactions for a specific goal
  Future<List<Map<String, dynamic>>> getGoalTransactions(String goalId) async {
    try {
      final response = await _dio.get(ApiEndpoints.goalTransactions(goalId));

      final data = response.data;
      List<dynamic> transactionsJson;

      if (data is Map && data.containsKey('transactions')) {
        transactionsJson = data['transactions'] as List<dynamic>;
      } else if (data is List) {
        transactionsJson = data;
      } else {
        throw ServerException(
          'Invalid response format',
          statusCode: response.statusCode,
        );
      }

      return transactionsJson
          .map((json) => json as Map<String, dynamic>)
          .toList();
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Delete a transaction
  /// Returns the updated goal
  Future<GoalModel?> deleteTransaction(
    String goalId,
    String transactionId,
  ) async {
    try {
      final response = await _dio.delete(
        ApiEndpoints.deleteTransaction(goalId, transactionId),
      );

      final data = response.data;

      if (data is Map && data.containsKey('goal')) {
        return GoalModel.fromJson(data['goal'] as Map<String, dynamic>);
      }

      return null;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Sync local goals with server
  /// Useful for offline-first functionality
  Future<Map<String, dynamic>> syncGoals(List<GoalModel> localGoals) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.syncData,
        data: {'goals': localGoals.map((g) => g.toJson()).toList()},
      );

      final data = response.data as Map<String, dynamic>;

      // Parse synced goals
      List<GoalModel> syncedGoals = [];
      if (data.containsKey('syncedGoals')) {
        syncedGoals = (data['syncedGoals'] as List)
            .map((json) => GoalModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return {'syncedGoals': syncedGoals, 'conflicts': data['conflicts'] ?? []};
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Handle Dio errors and convert to custom exceptions
  /// The ErrorInterceptor should handle most of this, but this is a fallback
  Never _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw TimeoutException('Request timed out');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] as String?;

        switch (statusCode) {
          case 401:
            throw UnauthorizedException(message ?? 'Unauthorized');
          case 403:
            throw ForbiddenException(message ?? 'Forbidden');
          case 404:
            throw NotFoundException(message ?? 'Goal not found');
          case 409:
            throw ConflictException(message ?? 'Conflict occurred');
          case 422:
            throw ValidationException(message ?? 'Validation failed');
          default:
            throw ServerException(
              message ?? 'Server error',
              statusCode: statusCode,
            );
        }

      case DioExceptionType.cancel:
        throw NetworkException('Request was cancelled');

      case DioExceptionType.connectionError:
        throw NoInternetException();

      default:
        throw NetworkException(error.message ?? 'Unknown error');
    }
  }
}
