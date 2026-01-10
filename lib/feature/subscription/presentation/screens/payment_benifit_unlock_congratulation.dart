import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/app_large_elevated_button.dart';
import '../viewmodel/plan_viewmodel.dart';
import '../viewmodel/plan_state.dart';
import '../widgets/custom_premium_feature.dart';
import 'upgrade_plan_screen.dart';

class BenifitUnlockScreen extends ConsumerWidget {
  const BenifitUnlockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planState = ref.watch(planViewModelProvider);
    final isYearly = ref.watch(subscriptionTypeProvider);

    return Scaffold(
      backgroundColor: context.backgroundClr,
      body: SafeArea(
        child: planState is PlanLoading
            ? const Center(child: CircularProgressIndicator())
            : planState is PlanError
            ? Center(
                child: Text(
                  'Failed to load plan details',
                  style: AppFonts.r16(color: context.textSecondaryClr),
                ),
              )
            : _buildCongratulationsContent(context, ref, isYearly, planState),
      ),
    );
  }

  Widget _buildCongratulationsContent(
    BuildContext context,
    WidgetRef ref,
    bool isYearly,
    PlanState planState,
  ) {
    if (planState is! PlanLoaded) {
      return const SizedBox.shrink();
    }

    final plan = isYearly ? planState.yearlyPlan : planState.monthlyPlan;

    if (plan == null) {
      return Center(
        child: Text(
          'No plan available',
          style: AppFonts.r16(color: context.textSecondaryClr),
        ),
      );
    }

    final subscriptionType = plan.isYearly ? 'Yearly' : 'Monthly';
    final renewalPeriod = plan.isYearly ? 'annually' : 'monthly';

    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 15.h),
          // Congratulation image
          Image.asset(
            AppAssets.googleLogo,
            width: double.infinity,
            height: 150.h,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 15.h),
          // Congratulation text
          Center(
            child: Text(
              "Congratulations!",
              style: AppFonts.b32(color: context.textPrimaryClr),
            ),
          ),
          // subtext
          SizedBox(height: 10.h),
          Center(
            child: Text(
              "You've Upgraded to the $subscriptionType Subscription.",
              style: AppFonts.m16(color: context.textSecondaryClr),
            ),
          ),
          // divider
          SizedBox(height: 15.h),
          SizedBox(height: 6.h),
          Divider(color: context.borderClr),

          SizedBox(height: 8.h),

          // Features list
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(13.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Benefits Unlocked:",
                        style: AppFonts.b20(color: context.textPrimaryClr),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    ...plan.features.map(
                      (feature) => PremiumFeature(text: feature),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // divider
          SizedBox(height: 15.h),
          Divider(color: context.borderClr),
          SizedBox(height: 15.h),
          // text for go to settings for manage subscription
          Center(
            child: Text(
              "Your subscription will automatically renew \n$renewalPeriod unless cancelled. Manage your \n subscription in the account settings.",
              textAlign: TextAlign.center,
              style: AppFonts.r16(color: context.textSecondaryClr),
            ),
          ),

          // spacer
          SizedBox(height: 15.h),
          // confirm button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AppLargeElevatedButton(
              text: "Start Exploring Premium Features",
              onPressed: () {
                context.push(RouteNames.accountScreen); // navigate
              },
            ),
          ),
          SizedBox(height: 15.h),
        ],
      ),
    );
  }
}
