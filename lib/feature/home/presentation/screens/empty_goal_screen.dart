import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'dart:io' show File;
import 'package:cached_network_image/cached_network_image.dart';
import '../../../account/presentation/provider/user_profile_viewmodel.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../../../../core/router/route_names.dart';
import '../viewmodels/goal_viewmodel.dart';
import '../viewmodels/goal_state.dart';
import 'home_screen.dart';

class EmptyGoalScreen extends ConsumerWidget {
  const EmptyGoalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalState = ref.watch(goalViewModelProvider);

    // Show loading indicator while checking for goals
    if (goalState is GoalLoading || goalState is GoalInitial) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Show error state
    if (goalState is GoalError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(goalState.message),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(goalViewModelProvider.notifier).loadGoals(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // If goals exist, show home screen with goal list
    if (goalState is GoalLoaded && goalState.isNotEmpty) {
      return const HomeScreen();
    }

    // Show empty state (no goals)
    return _buildEmptyState(context, ref);
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.backgroundClr,
      appBar: AppBar(
        backgroundColor: context.whiteClr,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(8.w),
          child: InkWell(
            onTap: () {
              context.push(RouteNames.accountScreen);
            },
            child: Consumer(
              builder: (context, ref, _) {
                final userState = ref.watch(userProfileViewModelProvider);
                ImageProvider? backgroundImage;

                if (userState is UserProfileLoaded &&
                    userState.user.photoUrl != null &&
                    userState.user.photoUrl!.isNotEmpty) {
                  final url = userState.user.photoUrl!;
                  if (url.startsWith('http') || url.startsWith('https')) {
                    backgroundImage = CachedNetworkImageProvider(
                      url,
                      errorListener: (_) {
                        // Handle error or evict if needed
                      },
                    );
                  } else {
                    // Handle local file path
                    try {
                      final file = File(url);
                      if (file.existsSync()) {
                        backgroundImage = FileImage(file);
                      }
                    } catch (_) {}
                  }
                }

                return CircleAvatar(
                  backgroundColor: AppColors.lightBlue,
                  backgroundImage: backgroundImage,
                  radius: 20.r,
                  child: backgroundImage == null
                      ? Icon(
                          Icons.person,
                          color: AppColors.primaryBlue,
                          size: 22.sp,
                        )
                      : null,
                );
              },
            ),
          ),
        ),
        title: Text(
          'Trezo',
          style: AppFonts.sb24(color: context.textPrimaryClr),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: AppColors.white, size: 14.sp),
                  SizedBox(width: 4.w),
                  Text('PRO', style: AppFonts.sb12(color: AppColors.white)),
                ],
              ),
            ),
          ),
        ],
      ),

      // Floating + button (bottom right)
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        onPressed: () {
          context.pushNamed(RouteNames.createGoalScreen);
        },
        child: const Icon(Icons.add, color: AppColors.white),
      ),

      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🎯 Target Icon
                Container(
                  height: 100.w,
                  width: 100.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryBlue.withValues(alpha: 0.15),
                        AppColors.lightBlue,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer ring
                        Container(
                          height: 52.w,
                          width: 52.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFE84D8A),
                              width: 6.w,
                            ),
                          ),
                        ),
                        // Inner ring
                        Container(
                          height: 32.w,
                          width: 32.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFE84D8A),
                              width: 4.w,
                            ),
                          ),
                        ),
                        // Center dot
                        Container(
                          height: 10.w,
                          width: 10.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE84D8A),
                            shape: BoxShape.circle,
                          ),
                        ),
                        // Dart arrow
                        Positioned(
                          top: 0,
                          right: 10.w,
                          child: Transform.rotate(
                            angle: -0.5,
                            child: Icon(
                              Icons.navigation,
                              color: const Color(0xFF5BA3E8),
                              size: 32.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // Title
                Text(
                  'Ready to start saving?',
                  style: AppFonts.sb20(color: context.textPrimaryClr),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 8.h),

                // Subtitle
                Text(
                  "You haven't set any savings goals yet.",
                  style: AppFonts.r14(color: context.textSecondaryClr),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 28.h),

                // Create First Goal Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.pushNamed(RouteNames.createGoalScreen);
                    },
                    icon: const Icon(Icons.add),
                    label: Text(
                      'Create Your First Goal',
                      style: AppFonts.m16(color: AppColors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
