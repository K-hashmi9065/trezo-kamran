import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/user_appearance.dart';
import '../../data/models/user_appearance_model.dart';
import '../../data/repositories/user_appearance_providers.dart';

import '../../presentation/provider/user_provider.dart';

class UserAppearanceViewModel extends Notifier<UserAppearance> {
  @override
  UserAppearance build() {
    // Listen for auth changes to reload appearance
    ref.listen(authStateProvider, (previous, next) {
      next.whenData((user) {
        if (user != null) {
          // User logged in or changed, load their appearance
          // Avoid reloading if it's the same user?
          // Simplest is to just load.
          _loadAppearance();
        } else {
          // User logged out
          state = UserAppearanceModel.initial();
        }
      });
    });

    // Check initial auth state (for app restart with persisted session)
    // We use read here to get the current value without setting up a watch
    // that would trigger rebuilds of this notifier
    final authState = ref.read(authStateProvider);
    if (authState.value != null) {
      Future.microtask(() => _loadAppearance());
    }

    return UserAppearanceModel.initial();
  }

  Future<void> _loadAppearance() async {
    final repository = ref.read(userAppearanceRepositoryProvider);

    // 1. First load potentially from local/last user for quick startup
    final initial = await repository.loadInitialAppearance();
    state = initial;
    Intl.defaultLocale = initial.language;

    // 2. Then try to fetch fresh (remote/local specific to current auth)
    final result = await repository.getUserAppearance();
    result.fold(
      (failure) {
        // Log error but keep showing initial/cached prefs
      },
      (appearance) {
        state = appearance;
        Intl.defaultLocale = appearance.language;
      },
    );
  }

  Future<void> updateLanguage(String languageCode) async {
    Intl.defaultLocale = languageCode;
    final newAppearance = state.copyWith(
      language: languageCode,
      updatedAt: DateTime.now(),
    );
    await _updateAppearance(newAppearance);
  }

  Future<void> updateThemeMode(String themeMode) async {
    final newAppearance = state.copyWith(
      themeMode: themeMode,
      updatedAt: DateTime.now(),
    );
    await _updateAppearance(newAppearance);
  }

  Future<void> _updateAppearance(UserAppearance appearance) async {
    // Optimistic update
    state = appearance;

    final repository = ref.read(userAppearanceRepositoryProvider);
    final result = await repository.updateUserAppearance(appearance);

    result.fold(
      (failure) {
        // Revert on failure logic could go here,
        // but typically for prefs we might just retry or silent fail
      },
      (savedAppearance) {
        state = savedAppearance;
      },
    );
  }
}

final userAppearanceViewModelProvider =
    NotifierProvider<UserAppearanceViewModel, UserAppearance>(() {
      return UserAppearanceViewModel();
    });
