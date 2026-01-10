import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/transaction_model.dart';

/// Remote data source for transaction operations
class TransactionRemoteDataSource {
  final Dio _dio;

  TransactionRemoteDataSource(this._dio);

  /// Get all transactions for a specific goal
  Future<List<TransactionModel>> getGoalTransactions(String goalId) async {
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
          .map(
            (json) => TransactionModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Get a specific transaction
  Future<TransactionModel> getTransactionById(
    String goalId,
    String transactionId,
  ) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.transactionById(goalId, transactionId),
      );

      final data = response.data;
      Map<String, dynamic> transactionJson;

      if (data is Map && data.containsKey('transaction')) {
        transactionJson = data['transaction'] as Map<String, dynamic>;
      } else if (data is Map) {
        transactionJson = data as Map<String, dynamic>;
      } else {
        throw ServerException(
          'Invalid response format',
          statusCode: response.statusCode,
        );
      }

      return TransactionModel.fromJson(transactionJson);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Add a new transaction (deposit or withdrawal)
  /// Returns the created transaction and updated goal data
  Future<Map<String, dynamic>> addTransaction({
    required String goalId,
    required double amount,
    required String type,
    required DateTime date,
    String? note,
    String? category,
    String? paymentMethod,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.addGoalTransaction(goalId),
        data: {
          'amount': amount,
          'type': type,
          'date': date.toIso8601String(),
          if (note != null) 'note': note,
          if (category != null) 'category': category,
          if (paymentMethod != null) 'paymentMethod': paymentMethod,
        },
      );

      final data = response.data as Map<String, dynamic>;

      return {
        'transaction': data['transaction'] != null
            ? TransactionModel.fromJson(
                data['transaction'] as Map<String, dynamic>,
              )
            : null,
        'goal': data['goal'], // Will be parsed by GoalRemoteDataSource
      };
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Update an existing transaction
  Future<TransactionModel> updateTransaction({
    required String goalId,
    required String transactionId,
    double? amount,
    String? type,
    DateTime? date,
    String? note,
    String? category,
    String? paymentMethod,
  }) async {
    try {
      final updateData = <String, dynamic>{
        if (amount != null) 'amount': amount,
        if (type != null) 'type': type,
        if (date != null) 'date': date.toIso8601String(),
        if (note != null) 'note': note,
        if (category != null) 'category': category,
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
      };

      final response = await _dio.put(
        '${ApiEndpoints.goalTransactions(goalId)}/$transactionId',
        data: updateData,
      );

      final data = response.data;
      Map<String, dynamic> transactionJson;

      if (data is Map && data.containsKey('transaction')) {
        transactionJson = data['transaction'] as Map<String, dynamic>;
      } else if (data is Map) {
        transactionJson = data as Map<String, dynamic>;
      } else {
        throw ServerException(
          'Invalid response format',
          statusCode: response.statusCode,
        );
      }

      return TransactionModel.fromJson(transactionJson);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Delete a transaction
  /// Returns updated goal data
  Future<Map<String, dynamic>?> deleteTransaction(
    String goalId,
    String transactionId,
  ) async {
    try {
      final response = await _dio.delete(
        ApiEndpoints.deleteTransaction(goalId, transactionId),
      );

      final data = response.data;

      if (data is Map && data.containsKey('goal')) {
        return data['goal'] as Map<String, dynamic>;
      }

      return null;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Get transaction statistics for a goal
  Future<Map<String, dynamic>> getTransactionStats(String goalId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.goalTransactions(goalId)}/stats',
      );

      final data = response.data;

      if (data is Map && data.containsKey('stats')) {
        return data['stats'] as Map<String, dynamic>;
      } else if (data is Map) {
        return data as Map<String, dynamic>;
      } else {
        return {};
      }
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Handle Dio errors and convert to custom exceptions
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
            throw NotFoundException(message ?? 'Transaction not found');
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
