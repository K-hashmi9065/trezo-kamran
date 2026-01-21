import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/linked_account_model.dart';

class LinkedAccountRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  LinkedAccountRepository(this._firestore, this._auth);

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Get reference to linked accounts collection
  CollectionReference _linkedAccountsCollection() {
    if (_userId == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('settings')
        .doc('linkedAccounts')
        .collection('accounts');
  }

  // Fetch all linked accounts
  Stream<List<LinkedAccount>> getLinkedAccounts() {
    try {
      return _linkedAccountsCollection().snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => LinkedAccount.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      print('Error fetching linked accounts: $e');
      return Stream.value([]);
    }
  }

  // Add or update a linked account
  Future<void> saveLinkedAccount(LinkedAccount account) async {
    try {
      final docRef = account.id.isEmpty
          ? _linkedAccountsCollection().doc()
          : _linkedAccountsCollection().doc(account.id);

      await docRef.set(account.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      print('Error saving linked account: $e');
      throw Exception('Failed to save linked account: $e');
    }
  }

  // Link an account (connect)
  Future<void> linkAccount({
    required String accountName,
    required String username,
    required String logo,
  }) async {
    try {
      final account = LinkedAccount(
        id: accountName.toLowerCase(), // Use account name as ID
        accountName: accountName,
        username: username,
        logo: logo,
        isConnected: true,
        connectedAt: DateTime.now(),
      );

      await saveLinkedAccount(account);
    } catch (e) {
      print('Error linking account: $e');
      throw Exception('Failed to link account: $e');
    }
  }

  // Unlink an account
  Future<void> unlinkAccount(String accountId) async {
    try {
      await _linkedAccountsCollection().doc(accountId).delete();
    } catch (e) {
      print('Error unlinking account: $e');
      throw Exception('Failed to unlink account: $e');
    }
  }

  // Check if an account is linked
  Future<bool> isAccountLinked(String accountName) async {
    try {
      final doc = await _linkedAccountsCollection()
          .doc(accountName.toLowerCase())
          .get();
      return doc.exists &&
          (doc.data() as Map<String, dynamic>?)?['isConnected'] == true;
    } catch (e) {
      print('Error checking account status: $e');
      return false;
    }
  }

  // Get a specific linked account
  Future<LinkedAccount?> getLinkedAccount(String accountId) async {
    try {
      final doc = await _linkedAccountsCollection().doc(accountId).get();
      if (doc.exists) {
        return LinkedAccount.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting linked account: $e');
      return null;
    }
  }
}

// Provider for LinkedAccountRepository
final linkedAccountRepositoryProvider = Provider<LinkedAccountRepository>((
  ref,
) {
  return LinkedAccountRepository(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});
