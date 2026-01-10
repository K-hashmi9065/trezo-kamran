import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/app_snack_bar.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../provider/user_provider.dart';
import '../widgets/menu_items.dart';
import '../widgets/upgrade_pro_card.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundClr,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.whiteClr,
        title: Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: Text(
            "Account",
            style: AppFonts.sb26(color: context.textPrimaryClr),
          ),
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
          padding: EdgeInsets.only(top: 7.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UpgradeProCard(
                  onTap: () {
                    context.push(RouteNames.upgradePlanScreen);
                  },
                ),
                SizedBox(height: 15.h),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r),
                    color: context.boxClr,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 15.w,
                      top: 15.h,
                      bottom: 15.h,
                    ),
                    child: Column(
                      children: [
                        Consumer(
                          builder: (context, ref, child) {
                            final userAsyncValue = ref.watch(
                              currentUserProvider,
                            );
                            return userAsyncValue.when(
                              data: (user) => Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage:
                                        (user?.photoUrl != null &&
                                            user!.photoUrl!.isNotEmpty)
                                        ? NetworkImage(user.photoUrl!)
                                              as ImageProvider
                                        : AssetImage(AppAssets.profilePicIcon),
                                    radius: 40.r,
                                  ),
                                  SizedBox(width: 22.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user?.name ?? 'No name available',
                                          style: AppFonts.sb20(
                                            color: context.textPrimaryClr,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 5.h),
                                        Text(
                                          user?.email ?? 'No email available',
                                          style: AppFonts.m16(
                                            color: context.textSecondaryClr,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      context.push(
                                        RouteNames.accountProfileScreen,
                                      );
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 15.h,
                                      ),
                                      child: Image.asset(
                                        AppAssets.forwardArrowIcon,
                                        height: 22.h,
                                        width: 20.h,
                                        color: context.textPrimaryClr,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (error, stack) => Center(
                                child: Text(
                                  'Error Loading Profile',
                                  style: AppFonts.m14(color: AppColors.error),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15.h),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3.r),
                    color: context.boxClr,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 5.w, top: 20.h),
                    child: Column(
                      children: [
                        MenuItem(
                          iconPath: AppAssets.appearanceIcon,
                          title: 'Archive',
                          onTap: () {
                            // context.push(RouteName.preference);
                          },
                        ),
                        MenuItem(
                          iconPath: AppAssets.settingIcon,
                          title: 'Preferences',
                          onTap: () {
                            context.push(RouteNames.accountPreferenceScreen);
                          },
                        ),
                        MenuItem(
                          iconPath: AppAssets.securityIcon,
                          title: 'Account & Security',
                          onTap: () {
                            context.push(RouteNames.accountSecurityScreen);
                          },
                        ),
                        MenuItem(
                          iconPath: AppAssets.paymentIcon,
                          title: 'Billing & Subscriptions',
                          onTap: () {
                            context.push(RouteNames.upgradePlanScreen);
                          },
                        ),

                        MenuItem(
                          iconPath: AppAssets.linkedAccountIcon,
                          title: 'Linked Accounts',
                          onTap: () {
                            context.push(RouteNames.accountsLinkedScreen);
                          },
                        ),
                        MenuItem(
                          iconPath: AppAssets.appearanceIcon,
                          title: 'App Appearance',
                          onTap: () {
                            context.push(RouteNames.appAppearanceScreen);
                          },
                        ),
                        MenuItem(
                          iconPath: AppAssets.helpSupportIcon,
                          title: 'Help & Support',
                          onTap: () {
                            context.push(RouteNames.helpSupportScreen);
                          },
                        ),
                        MenuItem(
                          iconPath: AppAssets.profilePicIcon,
                          title: 'Rate us',
                          onTap: () {},
                        ),
                        MenuItem(
                          iconPath: AppAssets.logoutIcon,
                          title: 'Logout',
                          islogout: true,
                          onTap: () async {
                            try {
                              // Call logout from AuthViewModel
                              await ref
                                  .read(authViewModelProvider.notifier)
                                  .logout();

                              if (!context.mounted) return;

                              // Show success message
                              AppSnackBar.showSuccess(
                                context,
                                message:
                                    'You have been logged out successfully',
                                title: 'Logged Out',
                              );

                              // Navigate to welcome screen
                              context.go(RouteNames.welcomeScreen);
                            } catch (e) {
                              if (!context.mounted) return;
                              AppSnackBar.showError(
                                context,
                                message: 'Error logging out: $e',
                                title: 'Logout Failed',
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
