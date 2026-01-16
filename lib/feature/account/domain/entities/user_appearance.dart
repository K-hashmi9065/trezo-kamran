class UserAppearance {
  final String language;
  final String themeMode;
  final String savingsView;
  final String firstDayOfWeek;
  final String dateFormat;
  final String currency;
  final DateTime? lastCacheCleared;
  final DateTime updatedAt;

  const UserAppearance({
    required this.language,
    required this.themeMode,
    this.savingsView = 'bar_chart',
    this.firstDayOfWeek = 'Sunday',
    this.dateFormat = 'System Default',
    this.currency = 'USD',
    this.lastCacheCleared,
    required this.updatedAt,
  });

  UserAppearance copyWith({
    String? language,
    String? themeMode,
    String? savingsView,
    String? firstDayOfWeek,
    String? dateFormat,
    String? currency,
    DateTime? lastCacheCleared,
    DateTime? updatedAt,
  }) {
    return UserAppearance(
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      savingsView: savingsView ?? this.savingsView,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      dateFormat: dateFormat ?? this.dateFormat,
      currency: currency ?? this.currency,
      lastCacheCleared: lastCacheCleared ?? this.lastCacheCleared,
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
          savingsView == other.savingsView &&
          firstDayOfWeek == other.firstDayOfWeek &&
          dateFormat == other.dateFormat &&
          currency == other.currency &&
          lastCacheCleared == other.lastCacheCleared &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      language.hashCode ^
      themeMode.hashCode ^
      savingsView.hashCode ^
      firstDayOfWeek.hashCode ^
      dateFormat.hashCode ^
      currency.hashCode ^
      lastCacheCleared.hashCode ^
      updatedAt.hashCode;
}
