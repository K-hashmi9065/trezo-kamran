import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final String? subtitle;
  final String? rowSubtitle;
  final Color? titleColor;

  const SettingsTile({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle = "",
    this.rowSubtitle = "",
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 18.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: context.borderClr, width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppFonts.sb18(
                        color: titleColor ?? context.textPrimaryClr,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    if (subtitle != null && subtitle!.isNotEmpty)
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.m16(color: context.textPrimaryClr),
                      ),
                  ],
                ),
              ),
              if (rowSubtitle != null && rowSubtitle!.isNotEmpty)
                Text(
                  rowSubtitle!,
                  style: AppFonts.m16(color: context.textSecondaryClr),
                ),
              SizedBox(width: 10.w),
              Icon(
                Icons.arrow_forward_ios,
                size: 22.sp,
                color: context.textPrimaryClr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
