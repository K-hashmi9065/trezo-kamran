import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../../../../core/utils/app_large_elevated_button.dart';
import '../../../../core/utils/app_snack_bar.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundClr,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.backgroundClr,
        automaticallyImplyLeading: false,
        leadingWidth: 50.h,
        // Back button
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            context.pop();
          },
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
                      SizedBox(height: 20.h),
                      // Heading
                      Text(
                        "Forgot Your Password? 🔑",
                        style: AppFonts.b28(color: context.textPrimaryClr),
                      ),
                      SizedBox(height: 15.h),

                      Text(
                        "Enter your registered email address, and we'll send you a code to reset your password.",
                        style: AppFonts.m18(color: context.textSecondaryClr),
                      ),
                      SizedBox(height: 35.h),

                      // Email field
                      CustomTextField(
                        label: "Your Registered Email",
                        hint: "andrew.ainsley@yourdomain.com",
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
                    ],
                  ),
                ),
              ),

              // Send Reset Link Button - Fixed at bottom
              AppLargeElevatedButton(
                text: "Send Reset Link",
                onPressed: () {
                  final email = emailController.text.trim();

                  if (email.isEmpty) {
                    AppSnackBar.showWarning(
                      context,
                      message: "Email required",
                      title: "Missing Information",
                    );
                    return;
                  }

                  ref
                      .read(authViewModelProvider.notifier)
                      .resetPassword(context, email);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
