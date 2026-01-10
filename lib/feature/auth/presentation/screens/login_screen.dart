// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/fonts.dart';
import '../../../../core/utils/app_large_elevated_button.dart';
import '../../../../core/utils/app_snack_bar.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_button.dart';

final isCheckedProvider = StateProvider<bool>((ref) => false);
final isPasswordVisibleProvider = StateProvider<bool>((ref) => false);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isChecked = ref.watch(isCheckedProvider);
    final isPasswordVisible = ref.watch(isPasswordVisibleProvider);

    return Scaffold(
      backgroundColor: context.backgroundClr,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.backgroundClr,
        automaticallyImplyLeading: false,
        leadingWidth: 50.h,
        // Back button
        leading: GestureDetector(
          onTap: () {
            context.pop();
          },
          child: Icon(
            Icons.arrow_back,
            color: context.textPrimaryClr,
            size: 32.h,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(18.w),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10.h),

                      /// Heading
                      Text(
                        "Welcome Back!  👋",
                        style: AppFonts.b34(color: context.textPrimaryClr),
                      ),
                      SizedBox(height: 15.h),

                      Text(
                        "Sign in to continue saving.",
                        style: AppFonts.m18(color: context.textSecondaryClr),
                      ),
                      SizedBox(height: 35.h),

                      /// Email field
                      CustomTextField(
                        label: "Email",
                        hint: "Email",
                        controller: emailController,
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18.w),
                          child: Image.asset(
                            AppAssets.emailIcon,
                            width: 18.w,
                            height: 18.h,
                          ),
                        ),
                      ),
                      SizedBox(height: 35.h),

                      /// Password field
                      CustomTextField(
                        label: "Password",
                        hint: "Password",
                        obscure: !isPasswordVisible,
                        controller: passwordController,
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18.w),
                          child: Image.asset(
                            AppAssets.lockIcon,
                            width: 18.w,
                            height: 18.h,
                          ),
                        ),
                        suffixIcon: Padding(
                          padding: EdgeInsets.all(15.w),
                          child: InkWell(
                            onTap: () {
                              final notifier = ref.read(
                                isPasswordVisibleProvider.notifier,
                              );
                              notifier.state = !notifier.state;
                            },
                            child: Image.asset(
                              AppAssets.eyeIcon,
                              width: 20.w,
                              height: 20.h,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      /// Remember me (left) / Forgot Password? (right)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  final notifier = ref.read(
                                    isCheckedProvider.notifier,
                                  );
                                  notifier.state = !notifier.state;
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Image.asset(
                                    isChecked
                                        ? AppAssets.checkBoxIcon
                                        : AppAssets.fillCheckBoxIcon,
                                    width: 26.w,
                                    height: 24.h,
                                  ),
                                ),
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                "Remember me",
                                style: AppFonts.sb18(
                                  color: context.textPrimaryClr,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              context.pushNamed(RouteNames.forgotPasswdScreen);
                            },
                            child: Text(
                              "Forgot Password?",
                              style: AppFonts.sb18(
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 25.h),

                      /// Continue with
                      Center(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                context.pushNamed(RouteNames.signUpScreen);
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: "Already have an account? ",
                                  style: AppFonts.m16(
                                    color: context.textPrimaryClr,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Sign Up",
                                      style: AppFonts.b16(
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 35.h),
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: context.textSecondaryClr,
                                    thickness: 1.h,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  "or continue with",
                                  style: TextStyle(
                                    fontSize: 16.9.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Divider(
                                    color: context.textSecondaryClr,
                                    thickness: 1.h,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 25.h),
                      Center(
                        child: SocialButton(
                          assetPath: AppAssets.googleLogo,
                          onTap: () {
                            ref
                                .read(authViewModelProvider.notifier)
                                .googleSignIn(context);
                          },
                        ),
                      ),
                      SizedBox(height: 17.h),

                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),

              /// Sign Up Button - Fixed at bottom
              AppLargeElevatedButton(
                text: "Login",
                onPressed: () {
                  final email = emailController.text.trim();
                  final password = passwordController.text.trim();

                  if (email.isEmpty || password.isEmpty) {
                    AppSnackBar.showWarning(
                      context,
                      message: "Email & password required",
                      title: "Missing Information",
                    );
                    return;
                  }

                  ref
                      .read(authViewModelProvider.notifier)
                      .login(context, email, password);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
