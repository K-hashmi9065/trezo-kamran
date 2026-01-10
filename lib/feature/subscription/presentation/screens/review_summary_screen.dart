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
import '../widgets/custom_confirm_payment_card.dart';
import '../widgets/custom_premium_feature.dart';
import 'upgrade_plan_screen.dart';

class ReviewSummaryScreen extends ConsumerWidget {
  const ReviewSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planState = ref.watch(planViewModelProvider);
    final isYearly = ref.watch(subscriptionTypeProvider);

    return Scaffold(
      backgroundColor: context.backgroundClr,
      appBar: AppBar(
        backgroundColor: context.backgroundClr,
        elevation: 0,
        title: Text(
          "Review Summary",
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
                child: Text(
                  'Failed to load plan details',
                  style: AppFonts.r16(color: context.textSecondaryClr),
                ),
              )
            : _buildReviewContent(context, ref, isYearly, planState),
      ),
    );
  }

  Widget _buildReviewContent(
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
        // review card for upgradation
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
                        style: AppFonts.m18(color: context.textPrimaryClr),
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
                              style: AppFonts.r16(
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
                      color: const Color(0xFF6D5DFB),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(16.r),
                        bottomLeft: Radius.circular(15.r),
                      ),
                    ),
                    child: Text(
                      plan.discountText!,
                      style: AppFonts.m16(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // selected payment method display
        SizedBox(height: 24.h),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            'Selected Payment Method',
            style: AppFonts.b20(color: context.textPrimaryClr),
          ),
        ),
        ConfirmPaymentCard(
          iconPath: AppAssets.googleLogo,
          title: "Google Pay",
          subtitle: "Google Pay",
        ),
        // spacer
        Spacer(),
        // confirm button
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: AppLargeElevatedButton(
            text: "Confirm Payment - ${plan.displayPrice}",
            onPressed: () {
              context.push(RouteNames.benifitUnlockScreen); // navigate
            },
          ),
        ),
        SizedBox(height: 15.h),
      ],
    );
  }
}
