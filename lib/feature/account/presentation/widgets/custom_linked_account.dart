import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';

class LinkedAccountCard extends StatelessWidget {
  final String iconPath;
  final String title;
  final String? username; // URL like https://facebook.com/username
  final bool isConnected;
  final VoidCallback? onTap;

  const LinkedAccountCard({
    super.key,
    required this.iconPath,
    required this.title,
    this.username,
    this.isConnected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: context.whiteClr,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ICON
            Image.asset(
              iconPath,
              height: 45.h,
              width: 45.h,
              fit: BoxFit.contain,
            ),

            SizedBox(width: 18.w),

            // TEXTS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.sb20(color: context.textPrimaryClr),
                  ),
                  if (isConnected && username != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      username!,
                      style: AppFonts.r14(color: context.textSecondaryClr),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(width: 5.w),

            // CONNECT / CONNECTED TEXT
            Text(
              isConnected ? "Linked" : "Link",
              style: isConnected
                  ? AppFonts.sb18(color: context.textDisabledClr)
                  : AppFonts.sb18(color: AppColors.primaryBlue),
            ),
          ],
        ),
      ),
    );
  }
}
