// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trezo_saving_ai_app/core/utils/app_large_elevated_button.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../../../../core/router/route_names.dart';
import '../widgets/settings_tile.dart';
import '../widgets/switch_tile.dart';
import '../provider/user_security_viewmodel.dart';

class AccountSecurityScreen extends ConsumerWidget {
  const AccountSecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final securityState = ref.watch(userSecurityViewModelProvider);

    return Scaffold(
      backgroundColor: context.backgroundClr,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.backgroundClr,
        automaticallyImplyLeading: false,
        title: Text(
          'Account & Security',
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
                        SizedBox(height: 15.h),
                        SwitchTile(
                          title: "Biometric ID",
                          value: securityState.isBiometricIdEnabled,
                          onChanged: (bool newValue) {
                            ref
                                .read(userSecurityViewModelProvider.notifier)
                                .toggleBiometricId(newValue);
                          },
                        ),
                        SwitchTile(
                          title: "Face ID",
                          value: securityState.isFaceIdEnabled,
                          onChanged: (bool newValue) {
                            ref
                                .read(userSecurityViewModelProvider.notifier)
                                .toggleFaceId(newValue);
                          },
                        ),
                        SwitchTile(
                          title: "SMS Authenticator",
                          value: securityState.isSmsAuthenticatorEnabled,
                          onChanged: (bool newValue) {
                            ref
                                .read(userSecurityViewModelProvider.notifier)
                                .toggleSmsAuthenticator(newValue);
                          },
                        ),
                        SwitchTile(
                          title: "Google Authenticator",
                          value: securityState.isGoogleAuthenticatorEnabled,
                          onChanged: (bool newValue) {
                            ref
                                .read(userSecurityViewModelProvider.notifier)
                                .toggleGoogleAuthenticator(newValue);
                          },
                        ),

                        SettingsTile(
                          title: "Change Password",
                          onTap: () {
                            context.push(RouteNames.forgotPasswdScreen);
                          },
                        ),
                        SettingsTile(
                          title: "Device Management",
                          onTap: () {
                            ref
                                .read(userSecurityViewModelProvider.notifier)
                                .deviceManagement(context);
                          },
                          subtitle:
                              "Manage your account on the various devices you own.",
                        ),
                        SettingsTile(
                          title: "Deactivate Account",
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: context.backgroundClr,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24.r),
                                ),
                              ),
                              builder: (context) {
                                return Padding(
                                  padding: EdgeInsets.all(24.w),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Deactivate Account",
                                        style: AppFonts.sb24(
                                          color: context.textPrimaryClr,
                                        ),
                                      ),
                                      SizedBox(height: 12.h),
                                      Text(
                                        "Are you sure you want to deactivate your account? You can reactivate it by logging in again.",
                                        textAlign: TextAlign.center,
                                        style: AppFonts.m16(
                                          color: context.textSecondaryClr,
                                        ),
                                      ),
                                      SizedBox(height: 32.h),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: AppLargeElevatedButton(
                                              text: 'Cancel',
                                              backgroundColor: context.boxClr,
                                              textColor: context.textPrimaryClr,
                                              onPressed: () {
                                                context.pop();
                                              },
                                            ),
                                          ),
                                          SizedBox(width: 16.w),
                                          Expanded(
                                            child: AppLargeElevatedButton(
                                              text: 'Deactivate',
                                              backgroundColor:
                                                  AppColors.primaryBlue,
                                              textColor: Colors.white,
                                              onPressed: () {
                                                context.pop();
                                                ref
                                                    .read(
                                                      userSecurityViewModelProvider
                                                          .notifier,
                                                    )
                                                    .deactivateAccount(context);
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16.h),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          subtitle:
                              "Temporarily deactivate your account. Easily reactivate when you are ready.",
                        ),
                        SettingsTile(
                          title: "Delete Account",
                          titleColor: AppColors.error,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: context.backgroundClr,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24.r),
                                ),
                              ),
                              builder: (context) {
                                return Padding(
                                  padding: EdgeInsets.all(24.w),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Delete Account",
                                        style: AppFonts.sb24(
                                          color: context.textPrimaryClr,
                                        ),
                                      ),
                                      SizedBox(height: 12.h),
                                      Text(
                                        "Are you sure you want to permanently delete your account? This action cannot be undone.",
                                        textAlign: TextAlign.center,
                                        style: AppFonts.m16(
                                          color: context.textSecondaryClr,
                                        ),
                                      ),
                                      SizedBox(height: 32.h),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: AppLargeElevatedButton(
                                              text: 'Cancel',
                                              backgroundColor: context.boxClr,
                                              textColor: context.textPrimaryClr,
                                              onPressed: () {
                                                context.pop();
                                              },
                                            ),
                                          ),
                                          SizedBox(width: 16.w),
                                          Expanded(
                                            child: AppLargeElevatedButton(
                                              text: 'Delete',
                                              backgroundColor: AppColors.error,
                                              textColor: Colors.white,
                                              onPressed: () {
                                                context.pop();
                                                ref
                                                    .read(
                                                      userSecurityViewModelProvider
                                                          .notifier,
                                                    )
                                                    .deleteAccount(context);
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16.h),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          subtitle:
                              "Permanently delete your account and data. Proceed with caution.",
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
