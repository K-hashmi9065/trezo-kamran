import 'package:logger/logger.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_checker.dart';
import '../datasources/transaction_local_data_source.dart';
import '../datasources/transaction_remote_data_source.dart';
import '../models/transaction_model.dart';

/// Transaction repository with offline-first strategy
class TransactionRepository {
  final TransactionLocalDataSource _localDataSource;
  final TransactionRemoteDataSource _remoteDataSource;
  final NetworkChecker _networkChecker;
  final Logger _logger = Logger();

  TransactionRepository(
    this._localDataSource,
    this._remoteDataSource,
    this._networkChecker,
  );

  /// Get all transactions for a specific goal - offline-first
  Future<List<TransactionModel>> getGoalTransactions(String goalId) async {
    // Try remote first if online
    final isConnected = await _networkChecker.isConnected;

    if (isConnected) {
      try {
        _logger.i('Fetching transactions for goal $goalId from remote API');
        final remoteTransactions = await _remoteDataSource.getGoalTransactions(
          goalId,
        );

        // Update local cache
        _logger.d('Caching ${remoteTransactions.length} transactions locally');
        for (final transaction in remoteTransactions) {
          await _localDataSource.createTransaction(transaction);
        }

        // Don't return here; fall through to return merged local data
      } on NetworkException catch (e) {
        _logger.w('Network error while fetching transactions: $e');
      } on ServerException catch (e) {
        _logger.w('Server error while fetching transactions: $e');
      } catch (e) {
        _logger.e('Unexpected error while fetching transactions: $e');
      }
    }

    // Return from local cache
    _logger.i('Fetching transactions for goal $goalId from local cache');
    return await _localDataSource.getGoalTransactions(goalId);
  }

  /// Get a specific transaction by ID
  Future<TransactionModel?> getTransactionById(
    String goalId,
    String transactionId,
  ) async {
    // Try remote first if online
    final isConnected = await _networkChecker.isConnected;

    if (isConnected) {
      try {
        _logger.i('Fetching transaction $transactionId from remote API');
        final remoteTransaction = await _remoteDataSource.getTransactionById(
          goalId,
          transactionId,
        );

        // Update local cache
        await _localDataSource.createTransaction(remoteTransaction);

        return remoteTransaction;
      } catch (e) {
        _logger.w('Error fetching remote transaction: $e');
      }
    }

    // Return from local cache
    _logger.i('Fetching transaction $transactionId from local cache');
    return await _localDataSource.getTransactionById(transactionId);
  }

  /// Add a new transaction
  Future<TransactionModel> addTransaction({
    required String goalId,
    required double amount,
    required String type,
    required DateTime date,
    String? note,
    String? category,
    String? paymentMethod,
  }) async {
    // Create transaction model
    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      goalId: goalId,
      amount: amount,
      type: type,
      date: date,
      note: note,
      createdAt: DateTime.now(),
      category: category,
      paymentMethod: paymentMethod,
    );

    // Always save locally first
    _logger.i('Creating transaction locally for goal $goalId');
    await _localDataSource.createTransaction(transaction);

    // Sync to remote (Firestore handles offline queueing)
    try {
      _logger.i('Syncing transaction to remote API');
      final result = await _remoteDataSource.addTransaction(
        goalId: goalId,
        amount: amount,
        type: type,
        date: date,
        id: transaction.id, // Pass the local ID to remote
        note: note,
        category: category,
        paymentMethod: paymentMethod,
      );

      final remoteTransaction = result['transaction'] as TransactionModel?;
      if (remoteTransaction != null) {
        // Update local cache with server response
        await _localDataSource.updateTransaction(remoteTransaction);
        return remoteTransaction;
      }
    } catch (e) {
      _logger.e('Error syncing transaction to remote: $e');
    }

    return transaction;
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
    // Get current transaction
    final currentTransaction = await _localDataSource.getTransactionById(
      transactionId,
    );
    if (currentTransaction == null) {
      throw Exception('Transaction with ID $transactionId not found');
    }

    // Create updated transaction
    final updatedTransaction = currentTransaction.copyWith(
      amount: amount,
      type: type,
      date: date,
      note: note,
      category: category,
      paymentMethod: paymentMethod,
    );

    // Update locally first
    _logger.i('Updating transaction locally: $transactionId');
    await _localDataSource.updateTransaction(updatedTransaction);

    // Sync to remote
    try {
      _logger.i('Syncing transaction update to remote API');
      final remoteTransaction = await _remoteDataSource.updateTransaction(
        goalId: goalId,
        transactionId: transactionId,
        amount: amount,
        type: type,
        date: date,
        note: note,
        category: category,
        paymentMethod: paymentMethod,
      );

      // Update local cache with server response
      await _localDataSource.updateTransaction(remoteTransaction);
      return remoteTransaction;
    } catch (e) {
      _logger.e('Error syncing transaction update to remote: $e');
    }

    return updatedTransaction;
  }

  /// Delete a transaction
  Future<void> deleteTransaction(String goalId, String transactionId) async {
    // Delete locally first
    _logger.i('Deleting transaction locally: $transactionId');
    await _localDataSource.deleteTransaction(transactionId);

    // Sync to remote
    try {
      _logger.i('Syncing transaction deletion to remote API');
      await _remoteDataSource.deleteTransaction(goalId, transactionId);
    } catch (e) {
      if (e is NotFoundException) {
        _logger.w(
          'Transaction $transactionId not found on remote (already deleted?): $e',
        );
      } else {
        _logger.e('Error syncing transaction deletion to remote: $e');
      }
    }
  }

  /// Delete all transactions for a goal
  Future<void> deleteGoalTransactions(String goalId) async {
    _logger.i('Deleting all transactions for goal $goalId');
    await _localDataSource.deleteGoalTransactions(goalId);

    // Note: This would typically be handled by the backend when a goal is deleted
  }

  /// Get transaction statistics for a goal
  Future<Map<String, dynamic>> getTransactionStats(String goalId) async {
    // Try remote first if online
    final isConnected = await _networkChecker.isConnected;

    if (isConnected) {
      try {
        _logger.i('Fetching transaction stats from remote API');
        return await _remoteDataSource.getTransactionStats(goalId);
      } catch (e) {
        _logger.w('Error fetching remote stats: $e');
      }
    }

    // Calculate from local cache
    _logger.i('Calculating transaction stats from local cache');
    return await _localDataSource.getTransactionStats(goalId);
  }

  /// Get all transactions (across all goals)
  Future<List<TransactionModel>> getAllTransactions() async {
    return await _localDataSource.getAllTransactions();
  }
}
