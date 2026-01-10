import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../constants/fonts.dart';

class AppLargeElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;

  const AppLargeElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,

    this.backgroundColor = AppColors.primaryBlue,
    this.textColor = AppColors.background,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,

      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        minimumSize: Size(double.infinity, 58.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
      ),
      child: Text(text, style: AppFonts.b18(color: textColor)),
    );
  }
}
