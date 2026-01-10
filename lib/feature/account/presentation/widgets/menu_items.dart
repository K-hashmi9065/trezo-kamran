import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';

class MenuItem extends StatelessWidget {
  const MenuItem({
    super.key,
    this.iconPath,
    required this.title,
    this.subtitle = '',
    this.trailing,
    this.islogout = false,
    this.onTap,
  });
  final String? iconPath;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final bool islogout;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textcolor = islogout ? AppColors.error : context.textPrimaryClr;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(left: 28.w, right: 31.w, bottom: 25.h),
        child: Row(
          children: [
            if (iconPath != null) ...[
              Image.asset(iconPath!, width: 24.w, height: 24.h),
              SizedBox(width: 24.w),
            ],
            Text(title, style: AppFonts.sb19(color: textcolor)),
            Spacer(flex: 3),
            Text(subtitle, style: AppFonts.m16(color: textcolor)),
            Spacer(),
            if (trailing != null)
              trailing!
            else if (!islogout)
              Image.asset(
                AppAssets.forwardArrowIcon,
                width: 14.w,
                height: 17.h,
              ),
          ],
        ),
      ),
    );
  }
}
