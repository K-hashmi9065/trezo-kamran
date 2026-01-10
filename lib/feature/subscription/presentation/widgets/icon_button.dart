import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';

class IconElevatedButton extends StatelessWidget {
  const IconElevatedButton({
    super.key,
    required this.text,
    required this.assetPath,
    required this.onTap,
    this.backgroundColor = AppColors.primaryBlue,
  });
  final String text;
  final String assetPath;
  final Color? backgroundColor;

  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(Size(double.infinity, 64.h)),
        backgroundColor: WidgetStatePropertyAll(AppColors.primaryBlue),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            side: BorderSide(color: AppColors.primaryBlue),
            borderRadius: BorderRadiusGeometry.circular(50),
          ),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(text, style: AppFonts.m16(color: context.whiteClr)),
          ),
          Padding(
            padding: EdgeInsets.only(left: 45.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                assetPath,
                height: 24,
                width: 24,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
