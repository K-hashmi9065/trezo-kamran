import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../../../subscription/presentation/viewmodel/subscription_with_plan_provider.dart';

class SubscribedScreen extends ConsumerWidget {
  const SubscribedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionWithPlanAsync = ref.watch(subscriptionWithPlanProvider);

    return Scaffold(
      backgroundColor: context.backgroundClr,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.backgroundClr,
        automaticallyImplyLeading: false,
        title: Text(
          'Billing & Subscriptions',
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
        child: subscriptionWithPlanAsync.when(
          data: (subscriptionWithPlan) {
            if (subscriptionWithPlan == null) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.card_membership,
                        size: 64.h,
                        color: context.textDisabledClr,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No Active Subscription',
                        style: AppFonts.sb20(color: context.textPrimaryClr),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Subscribe to Trezo Pro to access premium features',
                        style: AppFonts.r14(color: context.textSecondaryClr),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final subscription = subscriptionWithPlan.subscription;
            final plan = subscriptionWithPlan.plan;

            // If plan data is not available, show error
            if (plan == null) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64.h,
                        color: AppColors.error,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Plan Details Not Found',
                        style: AppFonts.sb20(color: context.textPrimaryClr),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Unable to load plan details for: ${subscription.planId}',
                        style: AppFonts.r14(color: context.textSecondaryClr),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subscription Card - matching review_summary_screen style
                  SizedBox(height: 4.h),
                  Stack(
                    children: [
                      // Main Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 22.h,
                        ),
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
                                style: AppFonts.m18(
                                  color: context.textPrimaryClr,
                                ),
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
                                    '\$${plan.price.toStringAsFixed(2)}',
                                    style: AppFonts.b34(
                                      color: context.textPrimaryClr,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      '/ ${plan.billingCycle}',
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

                            // Features list with green checkmarks
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: plan.features
                                  .map(
                                    (feature) => Padding(
                                      padding: EdgeInsets.only(bottom: 12.h),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.check,
                                            color: AppColors.success,
                                            size: 20.h,
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: Text(
                                              feature,
                                              style: AppFonts.r16(
                                                color: context.textPrimaryClr,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),

                      // Save Badge (Top-Right) - Only show if discount exists
                      if (plan.discountBadge != null &&
                          plan.discountBadge!.isNotEmpty)
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
                              plan.discountBadge!,
                              style: AppFonts.m16(color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Current Plan Label
                  Center(
                    child: Text(
                      'Your current plan',
                      style: AppFonts.m16(color: context.textSecondaryClr),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Subscription Details
                  if (subscription.expiryDate != null)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: context.whiteClr,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: context.borderClr),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your subscription will expire on ${subscription.getFormattedExpiryDate()}',
                            style: AppFonts.r14(
                              color: context.textSecondaryClr,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Renew or cancel your subscription ',
                                style: AppFonts.r14(
                                  color: context.textSecondaryClr,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Open help/support page
                                  _launchUrl('https://trezo.com/help');
                                },
                                child: Text(
                                  'here',
                                  style: AppFonts.m14(
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                              Text(
                                '.',
                                style: AppFonts.r14(
                                  color: context.textSecondaryClr,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48.h, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    'Error loading subscription',
                    style: AppFonts.m16(color: Colors.red),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $urlString');
    }
  }
}
