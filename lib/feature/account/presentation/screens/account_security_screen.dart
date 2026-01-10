// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../../../../core/router/route_names.dart';
import '../widgets/settings_tile.dart';
import '../widgets/switch_tile.dart';

final chargingReminderProvider = StateProvider<bool>((ref) => false);
final wakeUpMoodProvider = StateProvider<bool>((ref) => false);

class AccountSecurityScreen extends ConsumerWidget {
  const AccountSecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read Riverpod states
    final isChargingReminderEnabled = ref.watch(chargingReminderProvider);

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
                          value: isChargingReminderEnabled,
                          onChanged: (bool newValue) {
                            ref.read(chargingReminderProvider.notifier).state =
                                newValue;
                          },
                        ),
                        SwitchTile(
                          title: "Face ID",
                          value: isChargingReminderEnabled,
                          onChanged: (bool newValue) {
                            ref.read(chargingReminderProvider.notifier).state =
                                newValue;
                          },
                        ),
                        SwitchTile(
                          title: "SMS Authenticator",
                          value: isChargingReminderEnabled,
                          onChanged: (bool newValue) {
                            ref.read(chargingReminderProvider.notifier).state =
                                newValue;
                          },
                        ),
                        SwitchTile(
                          title: "Google Authenticator",
                          value: isChargingReminderEnabled,
                          onChanged: (bool newValue) {
                            ref.read(chargingReminderProvider.notifier).state =
                                newValue;
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
                          onTap: () {},
                          subtitle:
                              "Manage your account on the various devices you own.",
                        ),
                        SettingsTile(
                          title: "Deactivate Account",
                          onTap: () {},
                          subtitle:
                              "Temporarily deactivate your account Easily reactivate when you are ready.",
                        ),
                        SettingsTile(
                          title: "Delete Account",
                          titleColor: AppColors.error,
                          onTap: () {},
                          subtitle:
                              "Permanently delete your account and data Proceed with caution.",
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
