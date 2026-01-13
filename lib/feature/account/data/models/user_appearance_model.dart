import '../../domain/entities/user_appearance.dart';

class UserAppearanceModel extends UserAppearance {
  const UserAppearanceModel({
    required super.language,
    required super.themeMode,
    required super.updatedAt,
  });

  factory UserAppearanceModel.fromJson(Map<String, dynamic> json) {
    return UserAppearanceModel(
      language: json['language'] as String? ?? 'en',
      themeMode: json['themeMode'] as String? ?? 'system',
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  factory UserAppearanceModel.fromEntity(UserAppearance appearance) {
    return UserAppearanceModel(
      language: appearance.language,
      themeMode: appearance.themeMode,
      updatedAt: appearance.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'themeMode': themeMode,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserAppearanceModel.initial() {
    return UserAppearanceModel(
      language: 'en',
      themeMode: 'system',
      updatedAt: DateTime.now(),
    );
  }
}
