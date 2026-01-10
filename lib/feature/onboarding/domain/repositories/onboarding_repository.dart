import '../entities/onboarding_page.dart';

/// Abstract repository for onboarding
abstract class OnboardingRepository {
  /// Get list of onboarding pages
  List<OnboardingPage> getOnboardingPages();

  /// Check if onboarding has been completed
  Future<bool> isOnboardingCompleted();

  /// Mark onboarding as completed
  Future<void> setOnboardingCompleted();
}
