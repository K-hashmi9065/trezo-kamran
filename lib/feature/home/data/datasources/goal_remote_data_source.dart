import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/error/exceptions.dart';
import '../models/goal_model.dart';

/// Remote data source for goal-related operations using Firebase Firestore
class GoalRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  GoalRemoteDataSource(this._firestore, this._auth);

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw UnauthorizedException('User not authenticated');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _goalsCollection =>
      _firestore.collection('users').doc(_uid).collection('goals');

  /// Ensure the user document exists in 'users' collection
  Future<void> ensureUserDocumentExists() async {
    final user = _auth.currentUser;
    if (user == null) {
      // Cannot sync if not logged in
      return;
    }

    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      final snapshot = await userDoc.get();
      if (!snapshot.exists) {
        await userDoc.set({
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          'email': user.email,
          'uid': user.uid,
          'name': user.displayName,
          'photoUrl': user.photoURL,
          'phoneNumber': user.phoneNumber,
          'isVerified': user.emailVerified,
          'isPro': false,
          'gender': null,
          'address': null,
        }, SetOptions(merge: true));
      }

      // Ensure preferences document exists
      final prefsDoc = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('preferences');

      final prefsSnapshot = await prefsDoc.get();
      if (!prefsSnapshot.exists) {
        await prefsDoc.set({
          'themeMode': 'system',
          'language': 'en',
          'updatedAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      throw ServerException('Failed to ensure user document: $e');
    }
  }

  /// Check if the user has any goals (efficiently)
  Future<bool> hasAnyGoals() async {
    try {
      final snapshot = await _goalsCollection.limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Get all goals for the current user
  Future<List<GoalModel>> getAllGoals() async {
    try {
      final snapshot = await _goalsCollection.get();
      return snapshot.docs
          .map((doc) => GoalModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Get a specific goal by ID
  Future<GoalModel> getGoalById(String goalId) async {
    try {
      final doc = await _goalsCollection.doc(goalId).get();
      if (!doc.exists || doc.data() == null) {
        throw NotFoundException('Goal not found');
      }
      return GoalModel.fromJson(doc.data()!);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException(e.toString());
    }
  }

  /// Create a new goal
  Future<GoalModel> createGoal(GoalModel goal) async {
    try {
      // Use set with specific ID to keep IDs consistent
      await _goalsCollection.doc(goal.hiveId).set(goal.toJson());
      return goal;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Update an existing goal
  Future<GoalModel> updateGoal(GoalModel goal) async {
    try {
      await _goalsCollection.doc(goal.hiveId).update(goal.toJson());
      return goal;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Delete a goal by ID
  Future<void> deleteGoal(String goalId) async {
    try {
      await _goalsCollection.doc(goalId).delete();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Update goal progress (add to current amount)
  Future<GoalModel> updateGoalProgress(String goalId, double amount) async {
    try {
      final docRef = _goalsCollection.doc(goalId);

      // using transaction to ensure consistency
      return await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists || snapshot.data() == null) {
          throw NotFoundException('Goal not found');
        }

        final goal = GoalModel.fromJson(snapshot.data()!);

        transaction.update(docRef, {
          'currentAmount': FieldValue.increment(amount),
          'updatedAt': DateTime.now().toIso8601String(),
        });

        return goal.copyWith(
          currentAmount: goal.hiveCurrentAmount + amount,
          updatedAt: DateTime.now(),
        );
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Add a transaction to a goal (Note: actively used via TransactionRemoteDataSource, keeping this for potential direct usage or legacy support)
  Future<Map<String, dynamic>> addTransaction({
    required String goalId,
    required double amount,
    required String type,
    required DateTime date,
    String? id,
    String? note,
    String? category,
    String? paymentMethod,
  }) async {
    try {
      final txId = id ?? _firestore.collection('tmp').doc().id;

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

      await _firestore.runTransaction((transaction) async {
        final goalRef = _goalsCollection.doc(goalId);
        final txRef = goalRef.collection('transactions').doc(txId);

        transaction.set(txRef, transactionData);

        transaction.update(goalRef, {
          'currentAmount': FieldValue.increment(
            type == 'deposit' ? amount : -amount,
          ),
          'updatedAt': DateTime.now().toIso8601String(),
        });
      });

      final goal = await getGoalById(goalId);

      return {'transaction': transactionData, 'goal': goal};
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Get all transactions for a specific goal
  Future<List<Map<String, dynamic>>> getGoalTransactions(String goalId) async {
    try {
      final snapshot = await _goalsCollection
          .doc(goalId)
          .collection('transactions')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Delete a transaction
  Future<GoalModel?> deleteTransaction(
    String goalId,
    String transactionId,
  ) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final txRef = _goalsCollection
            .doc(goalId)
            .collection('transactions')
            .doc(transactionId);
        final txDoc = await transaction.get(txRef);
        if (!txDoc.exists) return;

        final data = txDoc.data();
        if (data != null) {
          final double amount = (data['amount'] as num).toDouble();
          final String type = data['type'] as String;

          final goalRef = _goalsCollection.doc(goalId);
          transaction.update(goalRef, {
            'currentAmount': FieldValue.increment(
              type == 'deposit' ? -amount : amount,
            ),
            'updatedAt': DateTime.now().toIso8601String(),
          });
        }

        transaction.delete(txRef);
      });

      return await getGoalById(goalId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Upload goal image to Firebase Storage
  Future<String> uploadGoalImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(
        'users/$_uid/goals/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}',
      );

      final uploadTask = await storageRef.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw ServerException('Failed to upload image: $e');
    }
  }

  /// Sync local goals with server
  Future<Map<String, dynamic>> syncGoals(List<GoalModel> localGoals) async {
    try {
      List<GoalModel> syncedGoals = [];
      for (var goal in localGoals) {
        await _goalsCollection
            .doc(goal.hiveId)
            .set(goal.toJson(), SetOptions(merge: true));
        syncedGoals.add(goal);
      }
      return {'syncedGoals': syncedGoals, 'conflicts': []};
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
