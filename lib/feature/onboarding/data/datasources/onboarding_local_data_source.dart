import 'package:hive/hive.dart';
import '../models/onboarding_page_model.dart';

/// Local data source for onboarding
class OnboardingLocalDataSource {
  static const String _boxName = 'onboarding';
  static const String _keyOnboardingCompleted = 'onboarding_completed';

  /// Get hardcoded onboarding pages
  List<OnboardingPageModel> getOnboardingPages() {
    return const [
      OnboardingPageModel(
        title: 'Track Your Sleep',
        description: 'Monitor your sleep patterns and get detailed insights',
        imagePath: 'assets/images/onboarding1.png',
      ),
      OnboardingPageModel(
        title: 'Personalized Tips',
        description:
            'Receive customized recommendations to improve sleep quality',
        imagePath: 'assets/images/onboarding2.png',
      ),
      OnboardingPageModel(
        title: 'Sleep Better',
        description: 'Achieve your health goals with better sleep habits',
        imagePath: 'assets/images/onboarding3.png',
      ),
    ];
  }

  /// Check if onboarding is completed
  Future<bool> isOnboardingCompleted() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_keyOnboardingCompleted, defaultValue: false) as bool;
  }

  /// Mark onboarding as completed
  Future<void> setOnboardingCompleted() async {
    final box = await Hive.openBox(_boxName);
    await box.put(_keyOnboardingCompleted, true);
  }
}
