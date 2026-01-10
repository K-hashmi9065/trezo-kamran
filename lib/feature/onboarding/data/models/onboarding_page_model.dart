import '../../domain/entities/onboarding_page.dart';

/// Onboarding page data model
class OnboardingPageModel extends OnboardingPage {
  const OnboardingPageModel({
    required super.title,
    required super.description,
    required super.imagePath,
  });

  /// Convert to entity
  OnboardingPage toEntity() {
    return OnboardingPage(
      title: title,
      description: description,
      imagePath: imagePath,
    );
  }

  /// Create from JSON
  factory OnboardingPageModel.fromJson(Map<String, dynamic> json) {
    return OnboardingPageModel(
      title: json['title'] as String,
      description: json['description'] as String,
      imagePath: json['imagePath'] as String,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'title': title, 'description': description, 'imagePath': imagePath};
  }
}
