import '../entities/onboarding_page.dart';
import '../repositories/onboarding_repository.dart';

/// Use case for getting onboarding pages
class GetOnboardingPagesUseCase {
  final OnboardingRepository _repository;

  GetOnboardingPagesUseCase(this._repository);

  List<OnboardingPage> call() {
    return _repository.getOnboardingPages();
  }
}
