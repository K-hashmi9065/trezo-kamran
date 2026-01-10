import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../../../../core/router/route_names.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';

final splashTimerProvider = FutureProvider<void>((ref) async {
  await Future.delayed(const Duration(seconds: 8));
});

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  @override
  void initState() {
    super.initState();
    // Kick off the splash timer via Riverpod and navigate on completion
    Future.microtask(() async {
      await ref.read(splashTimerProvider.future);
      if (mounted) {
        // Check if user is logged in
        final authService = ref.read(authServiceProvider);
        final isLoggedIn = authService.isLoggedIn;

        if (isLoggedIn) {
          // User is logged in, navigate to home screen
          context.go(RouteNames.emptyHomeScreen);
        } else {
          // User is not logged in, navigate to welcome screen
          context.go(RouteNames.welcomeScreen);
        }
      }
    });
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        child: Stack(
          // alignment: Alignment.center,
          children: [
            Center(
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    AppAssets.splashLogo,
                    width: 155.h,
                    height: 155.h,
                  ),
                  SizedBox(height: 18.h),
                  Text('Trezo', style: AppFonts.b38(color: AppColors.white)),
                  SizedBox(height: 18.h),
                ],
              ),
            ),

            Positioned(
              bottom: 110.h,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value * 2 * 3.14159,
                    child: Image.asset(
                      AppAssets.circulerWhiteLogo,
                      width: 75.h,
                      height: 75.h,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
