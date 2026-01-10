import '../repositories/onboarding_repository.dart';

/// Use case for checking onboarding status
class CheckOnboardingStatusUseCase {
  final OnboardingRepository _repository;

  CheckOnboardingStatusUseCase(this._repository);

  Future<bool> call() {
    return _repository.isOnboardingCompleted();
  }
}
