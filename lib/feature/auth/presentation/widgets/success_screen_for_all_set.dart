import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/app_large_elevated_button.dart';

class AllSetScreen extends StatelessWidget {
  const AllSetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // show all set logo
                      Image.asset("", height: 135.w, width: 135.w),
                      SizedBox(height: 25.h),
                      // Heading
                      Text(
                        "You're All Set!",
                        style: AppFonts.m24(color: context.textPrimaryClr),
                      ),
                      SizedBox(height: 18.h),
                      // message
                      Center(
                        child: Text(
                          "Your password has been successfully updated.",
                          style: AppFonts.r16(color: context.textSecondaryClr),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Sign In Button - Fixed at bottom
            AppLargeElevatedButton(
              text: "Go to Sign In",
              onPressed: () {
                context.pushNamed(RouteNames.loginScreen);
              },
            ),
          ],
        ),
      ),
    );
  }
}
