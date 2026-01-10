import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';

class SocialButton extends StatelessWidget {
  const SocialButton({super.key, required this.assetPath, required this.onTap});

  final String assetPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30.r),
      child: Container(
        height: 50.h,
        width: 80.w,
        decoration: BoxDecoration(
          color: context.whiteClr,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(color: context.borderClr, width: 1),
        ),
        child: Center(
          child: Image.asset(assetPath, height: 24.h, width: 24.h),
        ),
      ),
    );
  }
}
