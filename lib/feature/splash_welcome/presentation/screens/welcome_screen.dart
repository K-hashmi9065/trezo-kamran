// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/app_large_elevated_button.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../widgets/social_login_button.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => WelcomeScreenState();
}

class WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundClr,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,

          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 90.h),
            Image.asset(AppAssets.wellcomeLogo, height: 100.h, width: 100.w),
            SizedBox(height: 40.h),
            Text(
              "Let's Get Started!",
              style: AppFonts.b36(color: context.textPrimaryClr),
            ),
            SizedBox(height: 14.h),
            Text(
              "Let's dive in into your account",

              style: AppFonts.m18(color: context.textSecondaryClr),
            ),
            SizedBox(height: 65.h),
            SocialLoginButton(
              text: 'Continue with Google',
              assetPath: AppAssets.googleLogo,
              backgroundColor: context.boxClr,
              onTap: () {
                ref.read(authViewModelProvider.notifier).googleSignIn(context);
              },
            ),

            SizedBox(height: 85.h),
            AppLargeElevatedButton(
              text: "Sign up",
              onPressed: () {
                context.push(RouteNames.signUpScreen);
              },
            ),
            SizedBox(height: 35.h),
            AppLargeElevatedButton(
              text: "Sign in",
              onPressed: () {
                context.push(RouteNames.loginScreen);
              },
              textColor: AppColors.primaryBlue,
              backgroundColor: AppColors.lightBlue,
            ),
            SizedBox(height: 65.h),
            InkWell(
              onTap: () {
                // Handle privacy policy and terms of service tap
              },
              child: Text(
                "Privacy PolicyTerms of Service",
                style: AppFonts.r16(color: context.textSecondaryClr),
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }
}
