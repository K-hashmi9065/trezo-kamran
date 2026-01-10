// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trezo_saving_ai_app/feature/account/presentation/widgets/settings_tile.dart'
    show SettingsTile;

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/fonts.dart';
import '../../../../../core/router/route_names.dart';
import '../../../../../core/utils/app_large_elevated_button.dart';
import '../../../../../core/theme/theme_state.dart';
import '../../../../../core/theme/theme_viewmodel.dart';

class AppAppearanceScreen extends ConsumerStatefulWidget {
  const AppAppearanceScreen({super.key});

  @override
  ConsumerState<AppAppearanceScreen> createState() =>
      _AppAppearanceScreenState();
}

class _AppAppearanceScreenState extends ConsumerState<AppAppearanceScreen> {
  // Temporary selected theme for the bottom sheet
  AppThemeMode? _tempSelectedTheme;

  // bottom sheet for theme
  void showThemeBottomSheet(BuildContext context) {
    final currentTheme = ref.read(themeViewModelProvider).themeMode;
    _tempSelectedTheme = currentTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: context.whiteClr,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Choose Theme",
                      style: AppFonts.sb24(color: context.textPrimaryClr),
                    ),
                  ),

                  SizedBox(height: 14.h),
                  Divider(color: context.textDisabledClr),

                  // System Default option
                  RadioListTile<AppThemeMode>(
                    value: AppThemeMode.system,
                    // ignore: deprecated_member_use
                    groupValue: _tempSelectedTheme,
                    // ignore: deprecated_member_use
                    onChanged: (mode) {
                      setModalState(() {
                        _tempSelectedTheme = mode;
                      });
                    },
                    title: Text(
                      "System Default",
                      style: AppFonts.sb18(color: context.textPrimaryClr),
                    ),
                    activeColor: AppColors.primaryBlue,
                    contentPadding: EdgeInsets.zero,
                  ),

                  // Light theme option
                  RadioListTile<AppThemeMode>(
                    value: AppThemeMode.light,
                    // ignore: deprecated_member_use
                    groupValue: _tempSelectedTheme,
                    // ignore: deprecated_member_use
                    onChanged: (mode) {
                      setModalState(() {
                        _tempSelectedTheme = mode;
                      });
                    },
                    title: Text(
                      "Light",
                      style: AppFonts.sb18(color: context.textPrimaryClr),
                    ),
                    activeColor: AppColors.primaryBlue,
                    contentPadding: EdgeInsets.zero,
                  ),

                  // Dark theme option
                  RadioListTile<AppThemeMode>(
                    value: AppThemeMode.dark,
                    // ignore: deprecated_member_use
                    groupValue: _tempSelectedTheme,
                    // ignore: deprecated_member_use
                    onChanged: (mode) {
                      setModalState(() {
                        _tempSelectedTheme = mode;
                      });
                    },
                    title: Text(
                      "Dark",
                      style: AppFonts.sb18(color: context.textPrimaryClr),
                    ),
                    activeColor: AppColors.primaryBlue,
                    contentPadding: EdgeInsets.zero,
                  ),

                  SizedBox(height: 24.h),

                  Row(
                    children: [
                      Expanded(
                        child: AppLargeElevatedButton(
                          text: "Cancel",
                          backgroundColor: AppColors.lightBlue,
                          textColor: AppColors.primaryBlue,
                          onPressed: () => context.pop(),
                        ),
                      ),

                      SizedBox(width: 12.w),

                      Expanded(
                        child: AppLargeElevatedButton(
                          text: "Save",
                          onPressed: () {
                            // Save theme here
                            if (_tempSelectedTheme != null) {
                              ref
                                  .read(themeViewModelProvider.notifier)
                                  .changeTheme(_tempSelectedTheme!);
                            }
                            context.pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeViewModelProvider);
    final currentThemeMode = themeState.themeMode;

    return Scaffold(
      backgroundColor: context.backgroundClr,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.backgroundClr,
        automaticallyImplyLeading: false,
        title: Text(
          'App Appearance',
          style: AppFonts.sb26(color: context.textPrimaryClr),
        ),
        centerTitle: true,
        leadingWidth: 50.h,
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.pop(),
          child: Icon(
            Icons.arrow_back,
            color: context.textPrimaryClr,
            size: 32.h,
          ),
        ),
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: Padding(
            padding: EdgeInsets.only(left: 5.w, top: 8.h),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.r),
                      color: context.boxClr,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 5.h),
                        SettingsTile(
                          title: "Theme",
                          rowSubtitle: currentThemeMode.displayName,
                          onTap: () {
                            showThemeBottomSheet(context);
                          },
                        ),
                        SettingsTile(
                          title: "App Language",
                          rowSubtitle: "English",
                          onTap: () {
                            context.push(RouteNames.appLanguageScreen);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
