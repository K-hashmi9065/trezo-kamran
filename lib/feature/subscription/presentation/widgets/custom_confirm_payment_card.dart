import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';

class ConfirmPaymentCard extends StatelessWidget {
  final String iconPath;
  final String title;
  final String subtitle;
  final bool isCard; // true for Mastercard / Visa numbers
  final String status; // "Connected"

  const ConfirmPaymentCard({
    super.key,
    required this.iconPath,
    required this.title,
    required this.subtitle,
    this.isCard = false,
    this.status = "Change",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: context.whiteClr,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Image.asset(iconPath, height: 45.h, width: 45.h, fit: BoxFit.contain),

          SizedBox(width: 14.w),

          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppFonts.m18(color: context.textPrimaryClr)),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: AppFonts.r16(color: context.textSecondaryClr),
                ),
              ],
            ),
          ),
          SizedBox(width: 5.w),
          // Status
          InkWell(
            onTap: () {
              // Handle change payment method
            },
            child: Text(
              status,
              style: AppFonts.m18(color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }
}
