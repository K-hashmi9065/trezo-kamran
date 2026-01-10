import 'package:hive/hive.dart';
import '../models/transaction_model.dart';

/// Local data source for transaction operations using Hive
class TransactionLocalDataSource {
  final Box<TransactionModel> _transactionsBox;

  TransactionLocalDataSource(this._transactionsBox);

  /// Get all transactions for a specific goal
  Future<List<TransactionModel>> getGoalTransactions(String goalId) async {
    try {
      return _transactionsBox.values
          .where((transaction) => transaction.goalId == goalId)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
    } catch (e) {
      throw Exception('Failed to fetch transactions from local storage: $e');
    }
  }

  /// Get all transactions
  Future<List<TransactionModel>> getAllTransactions() async {
    try {
      return _transactionsBox.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      throw Exception('Failed to fetch all transactions: $e');
    }
  }

  /// Get a specific transaction by ID
  Future<TransactionModel?> getTransactionById(String id) async {
    try {
      return _transactionsBox.get(id);
    } catch (e) {
      throw Exception('Failed to fetch transaction with ID $id: $e');
    }
  }

  /// Create/add a new transaction
  Future<void> createTransaction(TransactionModel transaction) async {
    try {
      await _transactionsBox.put(transaction.id, transaction);
    } catch (e) {
      throw Exception('Failed to create transaction: $e');
    }
  }

  /// Update an existing transaction
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      if (!_transactionsBox.containsKey(transaction.id)) {
        throw Exception('Transaction with ID ${transaction.id} not found');
      }
      await _transactionsBox.put(transaction.id, transaction);
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  /// Delete a transaction by ID
  Future<void> deleteTransaction(String id) async {
    try {
      if (!_transactionsBox.containsKey(id)) {
        throw Exception('Transaction with ID $id not found');
      }
      await _transactionsBox.delete(id);
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  /// Delete all transactions for a specific goal
  Future<void> deleteGoalTransactions(String goalId) async {
    try {
      final goalTransactions = await getGoalTransactions(goalId);
      for (final transaction in goalTransactions) {
        await _transactionsBox.delete(transaction.id);
      }
    } catch (e) {
      throw Exception('Failed to delete goal transactions: $e');
    }
  }

  /// Clear all transactions (for testing purposes)
  Future<void> clearAllTransactions() async {
    try {
      await _transactionsBox.clear();
    } catch (e) {
      throw Exception('Failed to clear all transactions: $e');
    }
  }

  /// Get transaction statistics for a goal
  Future<Map<String, dynamic>> getTransactionStats(String goalId) async {
    try {
      final transactions = await getGoalTransactions(goalId);

      double totalDeposits = 0;
      double totalWithdrawals = 0;
      int depositCount = 0;
      int withdrawalCount = 0;

      for (final transaction in transactions) {
        if (transaction.isDeposit) {
          totalDeposits += transaction.amount;
          depositCount++;
        } else if (transaction.isWithdrawal) {
          totalWithdrawals += transaction.amount;
          withdrawalCount++;
        }
      }

      return {
        'totalDeposits': totalDeposits,
        'totalWithdrawals': totalWithdrawals,
        'depositCount': depositCount,
        'withdrawalCount': withdrawalCount,
        'netAmount': totalDeposits - totalWithdrawals,
        'transactionCount': transactions.length,
      };
    } catch (e) {
      throw Exception('Failed to calculate transaction stats: $e');
    }
  }
}
