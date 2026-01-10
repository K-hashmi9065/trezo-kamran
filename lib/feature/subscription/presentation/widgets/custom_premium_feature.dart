import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';

class PremiumFeature extends StatelessWidget {
  final String text;

  const PremiumFeature({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check, size: 25.h, color: context.textPrimaryClr),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: AppFonts.r16(color: context.textPrimaryClr),
            ),
          ),
        ],
      ),
    );
  }
}
