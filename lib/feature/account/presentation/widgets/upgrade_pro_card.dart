import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';

class UpgradeProCard extends StatelessWidget {
  final VoidCallback? onTap;

  const UpgradeProCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            Container(
              // height: 95.h,
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 15.w),
              padding: EdgeInsets.all(10.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(4.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Crown icon container
                  Center(
                    child: Image.asset(
                      AppAssets.upgradePlanIcon,
                      width: 75.w,
                      height: 75.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 1.w),
                  // Text content
                  Expanded(
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 1.h),
                          Text(
                            'Upgrade Plan Now!',
                            style: AppFonts.sb20(color: context.whiteClr),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            'Enjoy all the benefits and explore more possibilities',
                            style: AppFonts.m14(color: context.whiteClr),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
