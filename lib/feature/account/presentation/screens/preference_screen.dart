// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trezo_saving_ai_app/feature/account/presentation/widgets/settings_tile.dart'
    show SettingsTile;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../../../../core/router/route_names.dart';
import '../provider/user_appearance_viewmodel.dart';
import '../../../../../core/theme/theme_state.dart';
import 'app_appearance/app_language.dart';
import '../../models/language_model.dart';

class PreferenceScreen extends ConsumerWidget {
  const PreferenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.backgroundClr,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.backgroundClr,
        automaticallyImplyLeading: false,
        title: Text(
          'Preferences',
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
                        SettingsTile(
                          title: "Savings Goal View",
                          rowSubtitle: "Monday",
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.r),
                      color: context.boxClr,
                    ),
                    child: Column(
                      children: [
                        SettingsTile(
                          title: "Theme",
                          rowSubtitle: AppThemeMode.fromString(
                            ref
                                .watch(userAppearanceViewModelProvider)
                                .themeMode,
                          ).displayName,
                          onTap: () {
                            context.pushNamed(RouteNames.appAppearanceScreen);
                          },
                        ),
                        SettingsTile(
                          title: "App Language",
                          rowSubtitle: _getLanguageName(
                            ref.watch(userAppearanceViewModelProvider).language,
                          ),
                          onTap: () {
                            context.push(RouteNames.appLanguageScreen);
                          },
                        ),
                        SettingsTile(
                          title: "First Day of Week",
                          rowSubtitle: "Sunday",
                          onTap: () {},
                        ),
                        SettingsTile(
                          title: "Date Format",
                          rowSubtitle: "System Default",
                          onTap: () {},
                        ),
                        SizedBox(height: 5.h),
                      ],
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.r),
                      color: context.boxClr,
                    ),
                    child: Column(
                      children: [
                        SettingsTile(
                          title: "Clear Cache",
                          rowSubtitle: "45.8 MB",
                          onTap: () {},
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

  String _getLanguageName(String code) {
    return AppLanguageScreen.languages
        .firstWhere(
          (l) => l.code == code,
          orElse: () => AppLanguage(name: code, code: code),
        )
        .name;
  }
}
