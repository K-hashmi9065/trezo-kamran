import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toastification/toastification.dart';
import 'package:trezo_saving_ai_app/core/l10n/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/storage/hive_manager.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_service.dart';
import 'core/theme/theme_viewmodel.dart';
import 'firebase_options.dart';
import 'feature/account/presentation/provider/user_appearance_viewmodel.dart';
import 'feature/account/presentation/screens/app_appearance/app_language.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await HiveManager.init(); // Initialize Hive before running the app
  await ThemeService.init(); // Initialize Theme Service
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the theme state
    final themeState = ref.watch(themeViewModelProvider);

    return ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ToastificationWrapper(
          child: MaterialApp.router(
            title: 'Trezo',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeState.themeMode.toThemeMode(),
            routerConfig: appRouter,

            // Localization
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLanguageScreen.languages
                .map((e) => Locale(e.code))
                .toList(),
            locale: Locale(ref.watch(userAppearanceViewModelProvider).language),
          ),
        );
      },
    );
  }
}
