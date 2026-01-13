class UserAppearance {
  final String language;
  final String themeMode;
  final DateTime updatedAt;

  const UserAppearance({
    required this.language,
    required this.themeMode,
    required this.updatedAt,
  });

  UserAppearance copyWith({
    String? language,
    String? themeMode,
    DateTime? updatedAt,
  }) {
    return UserAppearance(
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAppearance &&
          runtimeType == other.runtimeType &&
          language == other.language &&
          themeMode == other.themeMode &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      language.hashCode ^ themeMode.hashCode ^ updatedAt.hashCode;
}
