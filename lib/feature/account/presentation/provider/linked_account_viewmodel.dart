import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/linked_account_model.dart';
import '../../data/repositories/linked_account_repository.dart';

// Stream provider for linked accounts
final linkedAccountsProvider = StreamProvider<List<LinkedAccount>>((ref) {
  final repository = ref.watch(linkedAccountRepositoryProvider);
  return repository.getLinkedAccounts();
});

// ViewModel for managing linked account operations
class LinkedAccountViewModel {
  final LinkedAccountRepository _repository;

  LinkedAccountViewModel(this._repository);

  // Link an account
  Future<void> linkAccount({
    required String accountName,
    required String username,
    required String logo,
  }) async {
    try {
      await _repository.linkAccount(
        accountName: accountName,
        username: username,
        logo: logo,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Unlink an account
  Future<void> unlinkAccount(String accountId) async {
    try {
      await _repository.unlinkAccount(accountId);
    } catch (e) {
      rethrow;
    }
  }

  // Check if account is linked
  Future<bool> isAccountLinked(String accountName) async {
    try {
      return await _repository.isAccountLinked(accountName);
    } catch (e) {
      return false;
    }
  }
}

// Provider for LinkedAccountViewModel
final linkedAccountViewModelProvider = Provider<LinkedAccountViewModel>((ref) {
  final repository = ref.watch(linkedAccountRepositoryProvider);
  return LinkedAccountViewModel(repository);
});
