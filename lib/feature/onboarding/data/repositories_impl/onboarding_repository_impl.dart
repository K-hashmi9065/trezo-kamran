import '../../domain/entities/onboarding_page.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_data_source.dart';

/// Implementation of onboarding repository
class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource _localDataSource;

  OnboardingRepositoryImpl(this._localDataSource);

  @override
  List<OnboardingPage> getOnboardingPages() {
    final models = _localDataSource.getOnboardingPages();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<bool> isOnboardingCompleted() {
    return _localDataSource.isOnboardingCompleted();
  }

  @override
  Future<void> setOnboardingCompleted() {
    return _localDataSource.setOnboardingCompleted();
  }
}
