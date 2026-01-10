import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/app_large_elevated_button.dart';
import '../../../../core/utils/app_tab_button.dart';

import '../viewmodel/plan_viewmodel.dart';
import '../viewmodel/plan_state.dart';
import '../widgets/custom_premium_feature.dart';

// State provider for subscription type
final subscriptionTypeProvider = StateProvider<bool>(
  (ref) => false,
); // false = Monthly, true = Yearly

class UpgradePlanScreen extends ConsumerWidget {
  const UpgradePlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isYearly = ref.watch(subscriptionTypeProvider);
    final planState = ref.watch(planViewModelProvider);

    return Scaffold(
      backgroundColor: context.backgroundClr,
      appBar: AppBar(
        backgroundColor: context.backgroundClr,
        elevation: 0,
        title: Text(
          "Upgrade Plan",
          style: AppFonts.sb26(color: context.textPrimaryClr),
        ),
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
        child: planState is PlanLoading
            ? const Center(child: CircularProgressIndicator())
            : planState is PlanError
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64.h, color: Colors.red),
                    SizedBox(height: 16.h),
                    Text(
                      'Failed to load plans',
                      style: AppFonts.sb20(color: context.textPrimaryClr),
                    ),
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.w),
                      child: Text(
                        planState.message,
                        textAlign: TextAlign.center,
                        style: AppFonts.r14(color: context.textSecondaryClr),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(planViewModelProvider.notifier).loadPlans(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : _buildPlanContent(context, ref, isYearly, planState),
      ),
    );
  }

  Widget _buildPlanContent(
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle buttons for Monthly/Yearly
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Container(
            height: 50.h,
            decoration: BoxDecoration(
              color: context.borderClr,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: AppTabButton(
              tabs: const ['Monthly', 'Yearly'],
              selectedIndex: isYearly ? 1 : 0,
              onTabChanged: (index) {
                ref.read(subscriptionTypeProvider.notifier).state = index == 1;
              },
            ),
          ),
        ),
        SizedBox(height: 24.h),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Stack(
            children: [
              // Main Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
                decoration: BoxDecoration(
                  color: context.whiteClr,
                  borderRadius: BorderRadius.circular(18.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5.h),

                    // Title
                    Center(
                      child: Text(
                        plan.name,
                        style: AppFonts.sb24(color: context.textPrimaryClr),
                      ),
                    ),

                    SizedBox(height: 15.h),

                    // Price Row
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            plan.displayPrice,
                            style: AppFonts.b34(color: context.textPrimaryClr),
                          ),
                          SizedBox(width: 8.w),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              plan.displayPeriod,
                              style: AppFonts.r18(
                                color: context.textSecondaryClr,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 15.h),

                    Divider(color: context.borderClr),

                    SizedBox(height: 15.h),

                    // Features list
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: plan.features
                          .map((feature) => PremiumFeature(text: feature))
                          .toList(),
                    ),
                  ],
                ),
              ),

              // Save Badge (Top-Right) - Only show if discount exists
              if (plan.discountText != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(16.r),
                        bottomLeft: Radius.circular(15.r),
                      ),
                    ),
                    child: Text(
                      plan.discountText!,
                      style: AppFonts.sb16(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // spacer
        Spacer(),
        // confirm button
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: AppLargeElevatedButton(
            text: "Continue - ${plan.displayPrice}",
            onPressed: () {
              context.push(RouteNames.reviewSummaryScreen); // navigate
            },
          ),
        ),
        SizedBox(height: 15.h),
      ],
    );
  }
}
