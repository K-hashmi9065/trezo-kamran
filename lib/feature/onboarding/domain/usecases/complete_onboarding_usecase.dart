import '../repositories/onboarding_repository.dart';

/// Use case for completing onboarding
class CompleteOnboardingUseCase {
  final OnboardingRepository _repository;

  CompleteOnboardingUseCase(this._repository);

  Future<void> call() {
    return _repository.setOnboardingCompleted();
  }
}
