import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../../../../core/theme/theme_state.dart';
import '../../../../core/theme/theme_viewmodel.dart';

class ThemeOption extends ConsumerWidget {
  const ThemeOption({super.key, required this.title, required this.value});

  final String title;
  final AppThemeMode value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeViewModelProvider);
    final selectedTheme = themeState.themeMode;

    return RadioListTile<AppThemeMode>(
      value: value,
      // ignore: deprecated_member_use
      groupValue: selectedTheme,
      // ignore: deprecated_member_use
      onChanged: (mode) {
        if (mode != null) {
          ref.read(themeViewModelProvider.notifier).changeTheme(mode);
        }
      },
      title: Text(title, style: AppFonts.sb18(color: AppColors.textPrimary)),
      activeColor: AppColors.primaryBlue,
      contentPadding: EdgeInsets.zero,
    );
  }
}
