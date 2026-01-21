import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_subscription_model.dart';
import '../../data/repositories/user_subscription_repository.dart';

// Stream provider for user subscription
final userSubscriptionProvider = StreamProvider<UserSubscription?>((ref) {
  final repository = ref.watch(userSubscriptionRepositoryProvider);
  return repository.getUserSubscription();
});

// ViewModel for managing subscription operations
class UserSubscriptionViewModel {
  final UserSubscriptionRepository _repository;

  UserSubscriptionViewModel(this._repository);

  // Get user subscription once
  Future<UserSubscription?> getUserSubscription() async {
    try {
      return await _repository.getUserSubscriptionOnce();
    } catch (e) {
      rethrow;
    }
  }

  // Cancel subscription
  Future<void> cancelSubscription() async {
    try {
      await _repository.cancelSubscription();
    } catch (e) {
      rethrow;
    }
  }

  // Check if user has active subscription
  Future<bool> hasActiveSubscription() async {
    try {
      return await _repository.hasActiveSubscription();
    } catch (e) {
      return false;
    }
  }
}

// Provider for UserSubscriptionViewModel
final userSubscriptionViewModelProvider = Provider<UserSubscriptionViewModel>((
  ref,
) {
  final repository = ref.watch(userSubscriptionRepositoryProvider);
  return UserSubscriptionViewModel(repository);
});
