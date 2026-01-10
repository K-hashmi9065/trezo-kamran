import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/onboarding_local_data_source.dart';
import '../../data/repositories_impl/onboarding_repository_impl.dart';
import '../../domain/usecases/check_onboarding_status_usecase.dart';
import '../../domain/usecases/complete_onboarding_usecase.dart';
import '../../domain/usecases/get_onboarding_pages_usecase.dart';
import 'onboarding_state.dart';

/// Onboarding ViewModel managing onboarding state
class OnboardingViewModel extends Notifier<OnboardingState> {
  late final GetOnboardingPagesUseCase _getOnboardingPagesUseCase;
  late final CompleteOnboardingUseCase _completeOnboardingUseCase;
  late final CheckOnboardingStatusUseCase _checkOnboardingStatusUseCase;

  @override
  OnboardingState build() {
    // Initialize use cases
    final repository = ref.read(onboardingRepositoryProvider);
    _getOnboardingPagesUseCase = GetOnboardingPagesUseCase(repository);
    _completeOnboardingUseCase = CompleteOnboardingUseCase(repository);
    _checkOnboardingStatusUseCase = CheckOnboardingStatusUseCase(repository);

    return const OnboardingInitial();
  }

  /// Load onboarding pages
  void loadOnboardingPages() {
    state = const OnboardingLoading();
    try {
      final pages = _getOnboardingPagesUseCase();
      state = OnboardingPagesLoaded(pages);
    } catch (e) {
      state = OnboardingError(e.toString());
    }
  }

  /// Navigate to next page
  void nextPage() {
    if (state is OnboardingPagesLoaded) {
      final currentState = state as OnboardingPagesLoaded;
      if (currentState.currentPageIndex < currentState.pages.length - 1) {
        state = currentState.copyWith(
          currentPageIndex: currentState.currentPageIndex + 1,
        );
      } else {
        completeOnboarding();
      }
    }
  }

  /// Navigate to previous page
  void previousPage() {
    if (state is OnboardingPagesLoaded) {
      final currentState = state as OnboardingPagesLoaded;
      if (currentState.currentPageIndex > 0) {
        state = currentState.copyWith(
          currentPageIndex: currentState.currentPageIndex - 1,
        );
      }
    }
  }

  /// Go to specific page
  void goToPage(int index) {
    if (state is OnboardingPagesLoaded) {
      final currentState = state as OnboardingPagesLoaded;
      if (index >= 0 && index < currentState.pages.length) {
        state = currentState.copyWith(currentPageIndex: index);
      }
    }
  }

  /// Complete onboarding
  Future<void> completeOnboarding() async {
    state = const OnboardingLoading();
    try {
      await _completeOnboardingUseCase();
      state = const OnboardingCompleted();
    } catch (e) {
      state = OnboardingError(e.toString());
    }
  }

  /// Check onboarding status
  Future<bool> checkOnboardingStatus() async {
    try {
      return await _checkOnboardingStatusUseCase();
    } catch (e) {
      return false;
    }
  }
}

// Providers

/// Onboarding Local Data Source Provider
final onboardingLocalDataSourceProvider = Provider<OnboardingLocalDataSource>((
  ref,
) {
  return OnboardingLocalDataSource();
});

/// Onboarding Repository Provider
final onboardingRepositoryProvider = Provider<OnboardingRepositoryImpl>((ref) {
  final localDataSource = ref.watch(onboardingLocalDataSourceProvider);
  return OnboardingRepositoryImpl(localDataSource);
});

/// Onboarding ViewModel Provider
final onboardingViewModelProvider =
    NotifierProvider<OnboardingViewModel, OnboardingState>(() {
      return OnboardingViewModel();
    });
