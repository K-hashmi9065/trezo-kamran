import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/exceptions.dart';
import '../models/transaction_model.dart';
import '../models/goal_model.dart';

/// Remote data source for transaction operations using Firebase Firestore
class TransactionRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  TransactionRemoteDataSource(this._firestore, this._auth);

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw UnauthorizedException('User not authenticated');
    }
    return user.uid;
  }

  DocumentReference<Map<String, dynamic>> _getGoalRef(String goalId) {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('goals')
        .doc(goalId);
  }

  CollectionReference<Map<String, dynamic>> _getTransactionsCollection(
    String goalId,
  ) {
    return _getGoalRef(goalId).collection('transactions');
  }

  /// Get all transactions for a specific goal
  Future<List<TransactionModel>> getGoalTransactions(String goalId) async {
    try {
      final snapshot = await _getTransactionsCollection(
        goalId,
      ).orderBy('date', descending: true).get();

      return snapshot.docs
          .map((doc) => TransactionModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Get a specific transaction
  Future<TransactionModel> getTransactionById(
    String goalId,
    String transactionId,
  ) async {
    try {
      final doc = await _getTransactionsCollection(
        goalId,
      ).doc(transactionId).get();

      if (!doc.exists || doc.data() == null) {
        throw NotFoundException('Transaction not found');
      }

      return TransactionModel.fromJson(doc.data()!);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException(e.toString());
    }
  }

  /// Add a new transaction (deposit or withdrawal)
  /// Returns the created transaction and updated goal data
  Future<Map<String, dynamic>> addTransaction({
    required String goalId,
    required double amount,
    required String type,
    required DateTime date,
    String? id, // Added optional ID to allow syncing local ID
    String? note,
    String? category,
    String? paymentMethod,
  }) async {
    try {
      final txId = id ?? _getTransactionsCollection(goalId).doc().id;

      final transactionData = {
        'id': txId,
        'goalId': goalId,
        'amount': amount,
        'type': type,
        'date': date.toIso8601String(),
        'note': note,
        'createdAt': DateTime.now().toIso8601String(),
        'category': category,
        'paymentMethod': paymentMethod,
      };

      return await _firestore.runTransaction((transaction) async {
        final goalRef = _getGoalRef(goalId);
        final txRef = _getTransactionsCollection(goalId).doc(txId);

        // Get current goal to ensure it exists
        final goalSnapshot = await transaction.get(goalRef);
        if (!goalSnapshot.exists) {
          throw NotFoundException('Goal not found');
        }

        // Save transaction
        transaction.set(txRef, transactionData);

        // Update goal balance
        double change = 0;
        if (type == 'deposit') {
          change = amount;
        } else if (type == 'withdrawal') {
          change = -amount;
        }

        transaction.update(goalRef, {
          'currentAmount': FieldValue.increment(change),
          'updatedAt': DateTime.now().toIso8601String(),
        });

        final currentGoalData = goalSnapshot.data()!;
        final currentAmount = (currentGoalData['currentAmount'] as num)
            .toDouble();

        final updatedGoalData = Map<String, dynamic>.from(currentGoalData);
        updatedGoalData['currentAmount'] = currentAmount + change;

        return {
          'transaction': TransactionModel.fromJson(transactionData),
          'goal': GoalModel.fromJson(updatedGoalData),
        };
      });
    } catch (e) {
      throw ServerException(e.toString());
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
      return await _firestore.runTransaction((transaction) async {
        final txRef = _getTransactionsCollection(goalId).doc(transactionId);
        final goalRef = _getGoalRef(goalId);

        final txSnapshot = await transaction.get(txRef);
        if (!txSnapshot.exists) {
          throw NotFoundException('Transaction not found');
        }

        final oldData = txSnapshot.data()!;
        final double oldAmount = (oldData['amount'] as num).toDouble();
        final String oldType = oldData['type'] as String;

        // Calculate balance adjustment needed
        double adjustment = 0;

        // Revert old effect
        if (oldType == 'deposit') adjustment -= oldAmount;
        if (oldType == 'withdrawal') adjustment += oldAmount;

        // Apply new effect
        final newAmount = amount ?? oldAmount;
        final newType = type ?? oldType;

        if (newType == 'deposit') adjustment += newAmount;
        if (newType == 'withdrawal') adjustment -= newAmount;

        final updateData = <String, dynamic>{
          if (amount != null) 'amount': amount,
          if (type != null) 'type': type,
          if (date != null) 'date': date.toIso8601String(),
          if (note != null) 'note': note,
          if (category != null) 'category': category,
          if (paymentMethod != null) 'paymentMethod': paymentMethod,
        };

        transaction.update(txRef, updateData);

        if (adjustment != 0) {
          transaction.update(goalRef, {
            'currentAmount': FieldValue.increment(adjustment),
            'updatedAt': DateTime.now().toIso8601String(),
          });
        }

        final mergedData = Map<String, dynamic>.from(oldData)
          ..addAll(updateData);
        return TransactionModel.fromJson(mergedData);
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Delete a transaction
  /// Returns updated goal data
  Future<Map<String, dynamic>?> deleteTransaction(
    String goalId,
    String transactionId,
  ) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        final txRef = _getTransactionsCollection(goalId).doc(transactionId);
        final goalRef = _getGoalRef(goalId);

        final txSnapshot = await transaction.get(txRef);
        if (!txSnapshot.exists) return null;

        final txData = txSnapshot.data()!;
        final double amount = (txData['amount'] as num).toDouble();
        final String type = txData['type'] as String;

        // Revert balance
        double change = 0;
        if (type == 'deposit') change = -amount;
        if (type == 'withdrawal') change = amount;

        transaction.delete(txRef);
        transaction.update(goalRef, {
          'currentAmount': FieldValue.increment(change),
          'updatedAt': DateTime.now().toIso8601String(),
        });

        final goalSnapshot = await transaction.get(goalRef);
        if (goalSnapshot.exists) {
          final goalData = goalSnapshot.data()!;
          final currentVal = (goalData['currentAmount'] as num).toDouble();
          final updatedGoal = Map<String, dynamic>.from(goalData);
          updatedGoal['currentAmount'] = currentVal + change;
          return updatedGoal;
        }
        return null;
      });
    } catch (e) {
      throw ServerException(e.toString());
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
        if (transaction.type == 'deposit') {
          totalDeposits += transaction.amount;
          depositCount++;
        } else if (transaction.type == 'withdrawal') {
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
      throw ServerException(e.toString());
    }
  }
}
