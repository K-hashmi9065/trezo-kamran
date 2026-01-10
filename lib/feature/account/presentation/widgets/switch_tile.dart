import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fonts.dart';

class SwitchTile extends StatelessWidget {
  final String title;
  final bool value;
  final Function(bool) onChanged;
  final String? subtitle;

  const SwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle = "",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    title,
                    style: AppFonts.sb19(color: context.textPrimaryClr),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  subtitle!,
                  style: AppFonts.m16(color: context.textSecondaryClr),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primaryBlue,
            inactiveTrackColor: context.textSecondaryClr,
            thumbColor: context.whiteClr,
            // size: 20.h,
          ),
        ],
      ),
    );
  }
}
