import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.text,
    required this.assetPath,
    required this.onTap,
    this.backgroundColor,
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
        minimumSize: WidgetStatePropertyAll(Size(double.infinity, 58.h)),
        backgroundColor: WidgetStatePropertyAll(
          backgroundColor ?? context.whiteClr,
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            side: BorderSide(color: context.borderClr),
            borderRadius: BorderRadiusGeometry.circular(35.h),
          ),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              text,
              style: AppFonts.sb18(color: context.textPrimaryClr),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 0.1.w),
              child: assetPath.endsWith('.svg')
                  ? SvgPicture.asset(assetPath, height: 24.w, width: 24.w)
                  : Image.asset(assetPath, height: 24.w, width: 24.w),
            ),
          ),
        ],
      ),
    );
  }
}
