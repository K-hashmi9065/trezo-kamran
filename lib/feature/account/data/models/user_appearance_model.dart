import '../../domain/entities/user_appearance.dart';

class UserAppearanceModel extends UserAppearance {
  const UserAppearanceModel({
    required super.language,
    required super.themeMode,
    super.savingsView = 'bar_chart',
    super.firstDayOfWeek = 'Sunday',
    super.dateFormat = 'System Default',
    super.currency = 'USD', // Default currency
    super.lastCacheCleared,
    required super.updatedAt,
  });

  factory UserAppearanceModel.fromJson(Map<String, dynamic> json) {
    return UserAppearanceModel(
      language: json['language'] as String? ?? 'en',
      themeMode: json['themeMode'] as String? ?? 'system',
      savingsView: json['savingsView'] as String? ?? 'bar_chart',
      firstDayOfWeek: json['firstDayOfWeek'] as String? ?? 'Sunday',
      dateFormat: json['dateFormat'] as String? ?? 'System Default',
      currency: json['currency'] as String? ?? 'USD',
      lastCacheCleared: json['lastCacheCleared'] != null
          ? DateTime.parse(json['lastCacheCleared'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  factory UserAppearanceModel.fromEntity(UserAppearance appearance) {
    return UserAppearanceModel(
      language: appearance.language,
      themeMode: appearance.themeMode,
      savingsView: appearance.savingsView,
      firstDayOfWeek: appearance.firstDayOfWeek,
      dateFormat: appearance.dateFormat,
      currency: appearance.currency,
      lastCacheCleared: appearance.lastCacheCleared,
      updatedAt: appearance.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'themeMode': themeMode,
      'savingsView': savingsView,
      'firstDayOfWeek': firstDayOfWeek,
      'dateFormat': dateFormat,
      'currency': currency,
      'lastCacheCleared': lastCacheCleared?.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserAppearanceModel.initial() {
    return UserAppearanceModel(
      language: 'en',
      themeMode: 'system',
      savingsView: 'bar_chart',
      firstDayOfWeek: 'Sunday',
      dateFormat: 'System Default',
      currency: 'USD',
      lastCacheCleared: null,
      updatedAt: DateTime.now(),
    );
  }
}
