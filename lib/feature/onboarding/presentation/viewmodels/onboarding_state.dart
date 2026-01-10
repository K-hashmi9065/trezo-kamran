import '../../domain/entities/onboarding_page.dart';

/// Base class for onboarding states
sealed class OnboardingState {
  const OnboardingState();
}

/// Initial state
class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

/// Loading state
class OnboardingLoading extends OnboardingState {
  const OnboardingLoading();
}

/// Pages loaded state
class OnboardingPagesLoaded extends OnboardingState {
  final List<OnboardingPage> pages;
  final int currentPageIndex;

  const OnboardingPagesLoaded(this.pages, {this.currentPageIndex = 0});

  OnboardingPagesLoaded copyWith({int? currentPageIndex}) {
    return OnboardingPagesLoaded(
      pages,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
    );
  }
}

/// Onboarding completed state
class OnboardingCompleted extends OnboardingState {
  const OnboardingCompleted();
}

/// Error state
class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError(this.message);
}
