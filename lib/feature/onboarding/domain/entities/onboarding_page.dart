/// Onboarding page entity
class OnboardingPage {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingPage &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          description == other.description &&
          imagePath == other.imagePath;

  @override
  int get hashCode =>
      title.hashCode ^ description.hashCode ^ imagePath.hashCode;

  @override
  String toString() {
    return 'OnboardingPage{title: $title, description: $description, imagePath: $imagePath}';
  }
}
