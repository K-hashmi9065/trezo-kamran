// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/app_large_elevated_button.dart';
import '../../../../core/utils/app_snack_bar.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_button.dart';

final isCheckedProvider = StateProvider<bool>((ref) => false);
final isPasswordVisibleProvider = StateProvider<bool>((ref) => false);

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
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
                        "Join Trezo Today 🚀",
                        style: AppFonts.b34(color: context.textPrimaryClr),
                      ),
                      SizedBox(height: 15.h),
                      Text(
                        "Start your savings journey.",
                        style: AppFonts.m18(color: context.textSecondaryClr),
                      ),
                      SizedBox(height: 35.h),

                      /// Email
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

                      /// Password
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
                              ref
                                      .read(isPasswordVisibleProvider.notifier)
                                      .state =
                                  !isPasswordVisible;
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

                      /// Terms & Privacy
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              ref.read(isCheckedProvider.notifier).state =
                                  !isChecked;
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Image.asset(
                                isChecked
                                    ? AppAssets.fillCheckBoxIcon
                                    : AppAssets.checkBoxIcon,
                                width: 26.w,
                                height: 24.h,
                              ),
                            ),
                          ),
                          SizedBox(width: 5.w),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                text: "I agree to Trezo ",
                                style: AppFonts.m16(
                                  color: context.textPrimaryClr,
                                ),
                                children: [
                                  TextSpan(
                                    text: "Terms & Conditions.",
                                    style: AppFonts.m16(
                                      color: context.textPrimaryClr,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40.h),

                      /// Already account
                      Center(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                context.pushNamed(RouteNames.loginScreen);
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: "Already have an account? ",
                                  style: AppFonts.m16(
                                    color: context.textPrimaryClr,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Sign in",
                                      style: AppFonts.sb18(
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 30.h),

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
                                  style: AppFonts.m16(
                                    color: context.textPrimaryClr,
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

                      /// Google Login
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
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),

              /// Sign Up Button (Fixed Bottom)
              AppLargeElevatedButton(
                text: "Sign up",
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
                      .signUp(context, email, password);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
