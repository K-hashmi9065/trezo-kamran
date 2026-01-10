// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/fonts.dart';
import '../../../models/language_model.dart';
import '../../provider/language_provider.dart';

// -------------------- SCREEN --------------------
class AppLanguageScreen extends ConsumerWidget {
  const AppLanguageScreen({super.key});

  static const List<AppLanguage> languages = [
    AppLanguage(name: "English", code: "en"),
    AppLanguage(name: "Spanish", code: "es"),
    AppLanguage(name: "Mandarin Chinese", code: "zh"),
    AppLanguage(name: "Hindi", code: "hi"),
    AppLanguage(name: "Arabic", code: "ar"),
    AppLanguage(name: "Bengali", code: "bn"),
    AppLanguage(name: "Portuguese", code: "pt"),
    AppLanguage(name: "Russian", code: "ru"),
    AppLanguage(name: "Japanese", code: "ja"),
    AppLanguage(name: "German", code: "de"),
    AppLanguage(name: "French", code: "fr"),
    AppLanguage(name: "Urdu", code: "ur"),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLang = ref.watch(appLanguageProvider);

    return Scaffold(
      backgroundColor: context.backgroundClr,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.backgroundClr,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.pop(),
          child: Icon(
            Icons.arrow_back,
            size: 28.h,
            color: context.textPrimaryClr,
          ),
        ),
        title: Text(
          "App Language",
          style: AppFonts.sb26(color: context.textPrimaryClr),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Container(
          decoration: BoxDecoration(
            color: context.boxClr,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: ListView.separated(
            itemCount: languages.length,
            separatorBuilder: (_, _) =>
                Divider(height: 1, color: context.borderClr),
            itemBuilder: (context, index) {
              final lang = languages[index];
              final isSelected = selectedLang == lang.code;

              return InkWell(
                onTap: () {
                  ref.read(appLanguageProvider.notifier).state = lang.code;
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  child: Row(
                    children: [
                      Text(
                        lang.name,
                        style: AppFonts.sb20(color: context.textPrimaryClr),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Icon(
                          Icons.check,
                          size: 22.h,
                          color: AppColors.primaryBlue,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
